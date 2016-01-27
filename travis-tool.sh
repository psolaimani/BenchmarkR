#!/bin/bash
# -*- sh-basic-offset: 4; sh-indentation: 4 -*-
# R/travis environment.

set -e
# Comment out this line for quieter output:
set -x

CRAN=${CRAN:-"http://cran.rstudio.com"}
BIOC=${BIOC:-"http://bioconductor.org/biocLite.R"}
BIOC_USE_DEVEL=${BIOC_USE_DEVEL:-"TRUE"}
OS=$(uname -s)

R_BUILD_ARGS=${R_BUILD_ARGS-"--no-build-vignettes --no-manual"}
#R_CHECK_ARGS=${R_CHECK_ARGS-"--no-build-vignettes --no-manual --as-cran"}
R_CHECK_ARGS=${R_CHECK_ARGS-"--no-build-vignettes --no-manual"}

R_USE_BIOC_CMDS="source('${BIOC}');"\
" tryCatch(useDevel(${BIOC_USE_DEVEL}),"\
" error=function(e) {if (!grepl('already in use', e$message)) {e}});"\
" options(repos=biocinstallRepos());"

EnsureDevtools() {
    if ! Rscript -e 'if (!("devtools" %in% rownames(installed.packages()))) q(status=1)' ; then
        # Install devtools and testthat.
        RBinaryInstall devtools testthat
    fi
}

EnsureDevtools() {
    if ! Rscript -e 'if (!("devtools" %in% rownames(installed.packages()))) q(status=1)' ; then
        # Install devtools and testthat.
        RBinaryInstall devtools testthat
    fi
}

AptGetInstall() {
    if [[ "Linux" != "${OS}" ]]; then
        echo "Wrong OS: ${OS}"
        exit 1
    fi

    if [[ "" == "$*" ]]; then
        echo "No arguments to aptget_install"
        exit 1
    fi

    echo "Installing apt package(s) $@"
    Retry sudo apt-get -y install "$@"
}

DpkgCurlInstall() {
    if [[ "Linux" != "${OS}" ]]; then
        echo "Wrong OS: ${OS}"
        exit 1
    fi

    if [[ "" == "$*" ]]; then
        echo "No arguments to dpkgcurl_install"
        exit 1
    fi

    echo "Installing remote package(s) $@"
    for rf in "$@"; do
        curl -OL ${rf}
        f=$(basename ${rf})
        sudo dpkg -i ${f}
        rm -v ${f}
    done
}

RInstall() {
    if [[ "" == "$*" ]]; then
        echo "No arguments to r_install"
        exit 1
    fi

    echo "Installing R package(s): $@"
    Rscript -e 'install.packages(commandArgs(TRUE), repos="'"${CRAN}"'")' "$@"
}

BiocInstall() {
    if [[ "" == "$*" ]]; then
        echo "No arguments to bioc_install"
        exit 1
    fi

    echo "Installing R Bioconductor package(s): $@"
    Rscript -e "${R_USE_BIOC_CMDS}"' biocLite(commandArgs(TRUE))' "$@"
}

RBinaryInstall() {
    if [[ -z "$#" ]]; then
        echo "No arguments to r_binary_install"
        exit 1
    fi

    if [[ "Linux" != "${OS}" ]] || [[ -n "${FORCE_SOURCE_INSTALL}" ]]; then
        echo "Fallback: Installing from source"
        RInstall "$@"
        return
    fi

    echo "Installing *binary* R packages: $*"
    r_packages=$(echo $* | tr '[:upper:]' '[:lower:]')
    r_debs=$(for r_package in ${r_packages}; do echo -n "r-cran-${r_package} "; done)

    AptGetInstall ${r_debs}
}

InstallGithub() {
    EnsureDevtools

    echo "Installing GitHub packages: $@"
    # Install the package.
    Rscript -e 'library(devtools); library(methods); options(repos=c(CRAN="'"${CRAN}"'")); install_github(commandArgs(TRUE), build_vignettes = FALSE)' "$@"
}

InstallDeps() {
    EnsureDevtools
    Rscript -e 'library(devtools); library(methods); options(repos=c(CRAN="'"${CRAN}"'")); install_deps(dependencies = TRUE)'
}

InstallBiocDeps() {
    EnsureDevtools
    Rscript -e "${R_USE_BIOC_CMDS}"' library(devtools); install_deps(dependencies = TRUE)'
}

DumpSysinfo() {
    echo "Dumping system information."
    R -e '.libPaths(); sessionInfo(); installed.packages()'
}

DumpLogsByExtension() {
    if [[ -z "$1" ]]; then
        echo "dump_logs_by_extension requires exactly one argument, got: $@"
        exit 1
    fi
    extension=$1
    shift
    package=$(find . -maxdepth 1 -name "*.Rcheck" -type d)
    if [[ ${#package[@]} -ne 1 ]]; then
        echo "Could not find package Rcheck directory, skipping log dump."
        exit 0
    fi
    for name in $(find "${package}" -type f -name "*${extension}"); do
        echo ">>> Filename: ${name} <<<"
        cat ${name}
    done
}

DumpLogs() {
    echo "Dumping test execution logs."
    DumpLogsByExtension "out"
    DumpLogsByExtension "log"
    DumpLogsByExtension "fail"
}

RunTests() {
    echo "Building with: R CMD build ${R_BUILD_ARGS}"
    R CMD build ${R_BUILD_ARGS} .
    # We want to grab the version we just built.
    FILE=$(ls -1t *.tar.gz | head -n 1)

    # Create binary package (currently Windows only)
    if [[ "${OS:0:5}" == "MINGW" ]]; then
        R_CHECK_INSTALL_ARGS="--install-args=--build"
    fi

    echo "Testing with: R CMD check \"${FILE}\" ${R_CHECK_ARGS} ${R_CHECK_INSTALL_ARGS}"
    _R_CHECK_CRAN_INCOMING_=${_R_CHECK_CRAN_INCOMING_:-FALSE}
    if [[ "$_R_CHECK_CRAN_INCOMING_" == "FALSE" ]]; then
        echo "(CRAN incoming checks are off)"
    fi
    _R_CHECK_CRAN_INCOMING_=${_R_CHECK_CRAN_INCOMING_} R CMD check "${FILE}" ${R_CHECK_ARGS} ${R_CHECK_INSTALL_ARGS}

    # Check reverse dependencies
    if [[ -n "$R_CHECK_REVDEP" ]]; then
        echo "Checking reverse dependencies"
        Rscript -e 'library(devtools); checkOutput <- unlist(revdep_check(as.package(".")$package));if (!is.null(checkOutput)) {print(data.frame(pkg = names(checkOutput), error = checkOutput));for(i in seq_along(checkOutput)){;cat("\n", names(checkOutput)[i], " Check Output:\n  ", paste(readLines(regmatches(checkOutput[i], regexec("/.*\\.out", checkOutput[i]))[[1]]), collapse = "\n  ", sep = ""), "\n", sep = "")};q(status = 1, save = "no")}'
    fi

    if [[ -n "${WARNINGS_ARE_ERRORS}" ]]; then
        if DumpLogsByExtension "00check.log" | grep -q WARNING; then
            echo "Found warnings, treated as errors."
            echo "Clear or unset the WARNINGS_ARE_ERRORS environment variable to ignore warnings."
            exit 1
        fi
    fi
}

Retry() {
    if "$@"; then
        return 0
    fi
    for wait_time in 5 20 30 60; do
        echo "Command failed, retrying in ${wait_time} ..."
        sleep ${wait_time}
        if "$@"; then
            return 0
        fi
    done
    echo "Failed all retries!"
    exit 1
}

COMMAND=$1
echo "Running command: ${COMMAND}"
shift
case $COMMAND in
    ##
    ## Ensure devtools is loaded (implicitly called)
    "install_devtools"|"devtools_install")
        EnsureDevtools
        ;;
    ##
    ## Install a binary deb package via apt-get
    "install_aptget"|"aptget_install")
        AptGetInstall "$@"
        ;;
    ##
    ## Install a binary deb package via a curl call and local dpkg -i
    "install_dpkgcurl"|"dpkgcurl_install")
        DpkgCurlInstall "$@"
        ;;
    ##
    ## Install an R dependency from CRAN
    "install_r"|"r_install")
        RInstall "$@"
        ;;
    ##
    ## Install an R dependency from Bioconductor
    "install_bioc"|"bioc_install")
        BiocInstall "$@"
        ;;
    ##
    ## Install an R dependency as a binary (via c2d4u PPA)
    "install_r_binary"|"r_binary_install")
        RBinaryInstall "$@"
        ;;
    ##
    ## Install a package from github sources (needs devtools)
    "install_github"|"github_package")
        InstallGithub "$@"
        ;;
    ##
    ## Install package dependencies from CRAN (needs devtools)
    "install_deps")
        InstallDeps
        ;;
    ##
    ## Install package dependencies from Bioconductor and CRAN (needs devtools)
    "install_bioc_deps")
        InstallBiocDeps
        ;;
    ##
    ## Run the actual tests, ie R CMD check
    "run_tests")
        RunTests
        ;;
    ##
    ## Dump information about installed packages
    "dump_sysinfo")
        DumpSysinfo
        ;;
    ##
    ## Dump build or check logs
    "dump_logs")
        DumpLogs
        ;;
    ##
    ## Dump selected build or check logs
    "dump_logs_by_extension")
        DumpLogsByExtension "$@"
        ;;
esac




