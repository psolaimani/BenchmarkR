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
#' @usage benchDBReport(usr, pwd, host_address, db_name, con_type)
#' @param usr database usrname
#' @param psw database password
#' @param host_loc IP address of the MySQL server
#' @param con_str a complete connection string (eg jdbc:mysql:127.0.0.1:36/myDatabase)
#' @param db_name database name
#' @param con_type type of database (currently only mysql and sqlite supported)
#' @import RMySQL RSQLite
#' @export
benchDBReport <- function(     usr = NULL, 
                               pwd = NULL, 
                          host_loc = NULL, 
                          conn_str = NULL, 
                           db_name = NULL, 
                          con_type = c("mysql","sqlite")) {
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
      
      message("Loading RMySQL package.")
      require(RMySQL)
      
      message("Connecting to MySQL database.")
      db <- try(conn <- dbConnect(RMySQL(), username = usr, password = pwd, 
                                  conn_str), TRUE)
      if (inherits(db, "try-error")) {
        db <- try(conn <- dbConnect(MySQL(), username = usr, password = pwd, 
                                    host = host_loc), TRUE)
        if (inherits( db, "try-error")) {
          warning(c("Could not connect to database.\n",
                    "MySQL() and RMySQL() resulted in error!"))
        }
      }
      
      conn
    },
    
    "sqlite" = {
      # Connect to SQLite
      if (is.null(db_name)) {
        warning("SQLite database location not provided.")
      }
      
      message("Loading RSQLite package.")
      require(RSQLite)
      
      message("Connecting to SQLite database.")
      db <- try(conn <- dbConnect(RSQLite(), dbname = db_name), TRUE)
      if (inherits(db, "try-error")) {
        db <- try(conn <- dbConnect(SQLite(), dbname = db_name), TRUE)
        if (inherits(db, "try-error")) {
          warning("MySQL() and RMySQL() resulted in error!")
        }
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
      bench_sql <- "INSERT INTO BENCHMARKS VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
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
      bench_sql <- 
        for (i in 1:nrow(cur_bmrk)) {
          updated <- try(
            dbSendQuery(conn,
                        paste0("INSERT INTO BENCHMARKS VALUES ('",
                               paste(cur_bmrk[i,], collapse = "','"), "');")
            ), TRUE)
          if (inherits(updated, "try-error")){
            warning("Error occured during writing benchmarks to database!")
          } else {
            message("Database benchmarks table updated!")
          }
        }
      
      message("Start adding records to META table")
      for (i in 1:nrow(cur_meta)){
        try(updated <- dbSendQuery(conn,
                                   sprintf(
                                     "INSERT INTO META VALUES 
                                      ( \'%s\', \'%s\', \'%s\' );",
                                     cur_meta[i,1], cur_meta[i,2], cur_meta[i,3]
                                   )), TRUE)
        if (inherits(updated, "try-error")){
          warning("Error occured during writing meta to database!")
        } else {
          message("Database meta table updated!")
        }
      }
    }
  }
  
  message("Closing SQLite database connection")
  dbDisconnect(conn)
  return(invisible("DB_UPDATED"))
}