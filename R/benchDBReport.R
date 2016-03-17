#' benchDBReport
#' @description Uploads benchmarking/profiling results to a database. 
#' This function tries to connect to a MySQL or SQLite database using 
#' provided information. If connection is sucessfull, data frames BM 
#' and META from .BenchEnv environment to the database tables
#' BENCHMARKS and META. These tables should exist in the provided database.
#' The BENCHMARKS table can be created by using:
#' 
#' \code{CREATE TABLE "BENCHMARKS" (}
#' \code{`runId`	VARCHAR(18) NOT NULL,}
#' \code{`systemId`	VARCHAR(32) NOT NULL,}
#' \code{`file`	VARCHAR(64) NOT NULL,}
#' \code{`version`	VARCHAR(32) NOT NULL,}
#' \code{`process`	VARCHAR(16) NOT NULL,}
#' \code{`start_time`	DECIMAL NOT NULL,}
#' \code{`end_time`	DECIMAL NOT NULL,}
#' \code{`duration`	DECIMAL NOT NULL,}
#' \code{`runs`	INTEGER NOT NULL,}
#' \code{PRIMARY KEY(runId,process,end_time)}
#' \code{)}
#' 
#' and for META table use:
#' 
#' \code{CREATE TABLE META (}
#' \code{systemId VARCHAR(32), }
#' \code{variable VARCHAR(32), }
#' \code{value VARCHAR(32),}
#' \code{PRIMARY KEY(systemId,variable))}
#' 
#' @usage benchDBReport(usr, pwd, host_loc, conn_str, db_name, con_type, bench_log, warn_log)
#' @param usr database usrname. Default is \code{NULL}.
#' @param pwd database password. Default is \code{NULL}.
#' @param host_loc IP address of the MySQL server. Default is \code{NULL}.
#' @param conn_str a complete connection string (eg jdbc:mysql:127.0.0.1:36/myDatabase). Default is \code{NULL}.
#' @param db_name database name. Default is \code{NULL}.
#' @param con_type type of database (currently only mysql and sqlite supported)
#' @param bench_log filename to use to store message/warning/errors. Default is "benchmark.log"
#' @param warn_log level of logging to use (choose from -1, "INFO", "WARN", "STOP". Default value is -1.
#' @import RMySQL RSQLite
#' @export
benchDBReport <- function( usr = NULL, 
                           pwd = NULL, 
                           host_loc = NULL, 
                           conn_str = NULL, 
                           db_name = NULL,
                           con_type = c("mysql","sqlite"), 
                           bench_log = "benchmark.log",
                           warn_log = c(-1,"INFO","WARN","STOP")) {
  
  # configure logging of the benchmark progress
  SetLogFile(bench_log)
  log_arg <- match.arg(warn_log)
  switch(log_arg,
         "-1" = options(warn = -1),
         "INFO" = options(warn = "INFO"),
         "WARN" = options(warn = "WARN"),
         "STOP" = options(warn = "STOP"),
         options(warn = -1)
  )
  
  # Get benchmarking/profiling data
  cur_bmrk <- benchGetter(target = "benchmarks")
  cur_meta <- benchGetter(target = "meta")
  
  # Initiation database choice and connection state
  con_type <- tolower(con_type)
  con_type <- match.arg(con_type)
  CONNECTED <- FALSE
  
  conn <- switch(
    con_type,
    "mysql" = {
      # Connect to MySQL
      if (is.null(usr) | is.null(pwd) | is.null(db_name)) {
        warning("Missing username, password, or db_name.")
      } 
      if (is.null(c(host_loc, conn_str, db_name))) {
        warning("Missing connection information.")
      }
      
      message("Connecting to MySQL database.")
      db <- try(conn <- dbConnect(MySQL(), username = usr, 
                                  password = pwd, conn_str), TRUE)
      if (inherits(db, "try-error")) {
        warning(c("Could not connect to database.\n",
                  "MySQL() and RMySQL() resulted in error!"))
      }
      
      conn
    },
    
    "sqlite" = {
      # Connect to SQLite
      if (is.null(db_name)) {
        warning("SQLite database location not provided.")
      }
      
      message("Connecting to SQLite database.")
      db <- try(conn <- dbConnect(SQLite(), dbname = db_name), TRUE)
      if (inherits(db, "try-error")) {
        warning("MySQL() and RMySQL() resulted in error!")
      }
      
      conn
    }
  )
  
  message("Checking database connection")
  if (!exists("conn")) {
    warning("ERROR: Could not connect to database!")
    CONNECTED <- FALSE
  } else {
    CONNECTED <- TRUE
    message("Connection to database established!") 
  }
  
  if (CONNECTED) {
    
    if (con_type == "sqlite") { 
      # adapted from:
      # http://www.inside-r.org/packages/cran/RSQLite/docs/dbSendPreparedQuery
      #
      bulk_insert <- function(sql, key_counts) { 
        dbBegin(conn)
        dbSendPreparedQuery(conn, sql, bind.data = key_counts)
        dbCommit(conn)
      }
      
      message("Start adding records to BENCHMARKS table")
      bench_sql <- "INSERT INTO BENCHMARKS VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
      updated <- try(bulk_insert(bench_sql, cur_bmrk), TRUE)
      if (inherits(updated, "try-error")){
        warning("Error occured during writing benchmarks to SQLite database!")
      } else {
        message("Database benchmarks table updated!")
      }
      
      message("Start adding records to META table")
      meta_sql <- "INSERT INTO META VALUES (?, ?, ?)"
      updated <- try(bulk_insert(meta_sql, cur_meta), TRUE)
      if (inherits(updated, "try-error")){
        warning("Error occured during writing meta to SQLite database!")
      } else {
        message("Database meta table updated!")
      }
      
    } else {
      
      message("Start adding records to BENCHMARKS table")
      updated <- try( dbWriteTable(conn, "BENCHMARKS", cur_bmrk), TRUE)
      if (inherits(updated, "try-error")){
        warning("Error occured during writing benchmarks to database!")
      } else {
        message("Database benchmarks table updated!")
      }
      
      message("Start adding records to META table")
      updated <- try( dbWriteTable(conn, "META", cur_meta), TRUE)
      if (inherits(updated, "try-error")){
        warning("Error occured during writing meta to database!")
      } else {
        message("Database meta table updated!")
      }
    }
  }
  
  message("Closing SQLite database connection")
  dbDisconnect(conn)
  return(invisible("DB_UPDATED"))
}