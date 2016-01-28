#' benchDBReport
#' @description Uploads benchmarking/profiling results tp database
#' @usage benchDBReport(usr, pwd, con_str)
#' @param usr database usrname
#' @param psw database password
#' @param con_str database connection string jdbc:mysql:location/database/table
#' @import RMySQL MonetDB.R
#' @export
benchDBReport <- function(usr=NULL, pwd=NULL, con_str=NULL){
  
  # check if con info is provided
  if(is.null(usr) | is.null(pwd) | is.null(con_str)){
    cat("Can't write results to database. Missing connection information.\n")
    return(NULL)
  }
  
  # extract database type from connection string
  con_type <- unlist(strsplit(con_str, ":"))[2]
  con_type <- tolower(con_type)
  
  # Get benchmarking/profiling data
  cur_bmrk <- benchGetter(target = "benchmarks" )
  cur_prfl <- benchGetter( target = "profiles" )
  cur_meta <- benchGetter( target = "meta" )
  
  # No connection to database has been made
  CONNECTED <- FALSE
  
  
  if (con_type == "mysql"){
    # Connect to MySQL
    cat("Connecting to MySQL database.\n")
    require(RMySQL)
    conn <- dbConnect(RMySQL(), con_str, usr, pwd)
    CONNECTED <- TRUE
    cat("Connection to database established.\n")
    
#  } else if (con_type == "postgresql") {
#    # Connect to PostgreSQL
#    cat("Connecting to PostgreSQL database.\n")
#    require(RPostgreSQL)
#    conn <- dbConnect(RPostgreSQL(), con_str, usr, pwd)
#    CONNECTED <- TRUE
#    cat("Connection to database established.\n")
#    
  } else if (con_type == "monetdb") {
    # Connect to MonetDB
    cat("Connecting to MonetDB database.\n")
    require(MonetDB.R)
    conn <- dbConnect(MonetDB.R(), con_str, usr, pwd)
    CONNECTED <- TRUE
    cat("Connection to database established.\n")
    
#  } else if (con_type == "oracle"){
#    # Connect to Oracle
#    cat("Connecting to Oracle database.\n")
#    require(ROracle)
#    conn <- dbConnect(ROracle(), url=con_str, username=usr, password=pwd)
#    CONNECTED <- TRUE
#    cat("Connection to database established.\n")
#    
  } else {
    
    cat(sprintf("Database of type %s is not yet supported", con_type))
    CONNECTED <- FALSE
    return(NULL)
    
  }
  
  if (CONNECTED == TRUE) {
    cat("Start adding records to BENCHMARKS table\n")
    for (i in 1:nrow(cur_bmrk)){
      try(
        dbSendUpdate(conn,
                     sprintf(
                       "INSERT INTO BENCHMARKS VALUES 
                       ( \'%s\', \'%s\', \'%s\', \'%s\' );",
                       cur_bmrk[i,1], cur_bmrk[i,2], 
                       cur_bmrk[i,3], cur_bmrk[i,4]
                     )
        )
        , TRUE)
    }
    
    cat("Start adding records to PROFILES table\n")
    for (i in 1:nrow(cur_prfl)){
      try(
        dbSendUpdate(conn,
                     sprintf(
                       "INSERT INTO PROFILES VALUES 
                       ( \'%s\', \'%s\', \'%s\', \'%s\', 
                       \'%s\', \'%s\', \'%s\' );",
                       cur_prfl[i,1], cur_prfl[i,2], 
                       cur_prfl[i,3], cur_prfl[i,4], 
                       cur_prfl[i,5], cur_prfl[i,6], cur_prfl[i,7]
                     )
        )
        , TRUE)
    }
    
    cat("Start adding records to META table\n")
    for (i in 1:nrow(cur_meta)){
      try(
        dbSendUpdate(conn,
                     sprintf(
                       "INSERT INTO META VALUES 
                       ( \'%s\', \'%s\', \'%s\' );",
                       cur_meta[i,1], cur_meta[i,2], cur_meta[i,3]
                     )
        )
        , TRUE)
    }
    
    cat("Database updated!\nClosing database connection\n")
  } 
  
  dbDisconnect(conn)
  return(invisible("DB_UPDATED"))
}