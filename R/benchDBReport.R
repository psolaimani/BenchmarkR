#' benchDBReport
#' @description Uploads benchmarking/profiling results tp database
#' @usage benchDBReport(usr, pwd, host_address, db_name, con_type)
#' @param usr database usrname
#' @param psw database password
#' @param host_address IP address of the MySQL server
#' @param db_name database name
#' @param con_type type of database (currently only mysql supported)
#' @import RMySQL RSQLite
#' @export
benchDBReport <- function(         usr = NULL, 
                                   pwd = NULL, 
                          host_address = NULL, 
                           conn_string = NULL, 
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
      } if (is.null(c(host_address, conn_string, db_name))) {
        warning("Missing connection information.")
      }
      
      cat("Loading RMySQL package.\n")
      require(RMySQL)
      
      cat("Connecting to MySQL database.\n")
      db <- try(conn <- dbConnect(RMySQL(), username = usr, password = pwd, conn_string), TRUE)
      if (inherits(db, "try-error")) {
        db <- try(conn <- dbConnect(MySQL(), username = usr, password = pwd, host = host_address), TRUE)
        if (inherits( db, "try-error")) {
          warning("MySQL() and RMySQL() resulted in error!")
        }
      }
      
      conn
    },
    
    "sqlite" = {
      # Connect to SQLite
      if (is.null(db_name)) {
        warning("SQLite database location not provided.")
      }
      
      cat("Loading RSQLite package.\n")
      require(RSQLite)
      
      cat("Connecting to SQLite database.\n")
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
  
  cat("Checking database connection\n")
  if (!exists("conn")) {
    warning("ERROR: Could not connect to database!")
    CONNECTED <- FALSE
  } else {
    CONNECTED <- TRUE
    cat("Connection to database established!\n") 
  }
  
  if (CONNECTED) {
    
    if (con_type == "sqlite") { 
      # adapted from http://www.inside-r.org/packages/cran/RSQLite/docs/dbSendPreparedQuery
      bulk_insert <- function(sql, key_counts) { 
        dbBegin(conn)
        dbSendPreparedQuery(conn, sql, bind.data = key_counts)
        dbCommit(conn)
      }
      
      cat("Start adding records to BENCHMARKS table\n")
      benchmark_sql <- "INSERT INTO BENCHMARKS VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
      updated <- try(bulk_insert( benchmark_sql, cur_bmrk ), TRUE)
      if (inherits(updated, "try-error")){
        warning("Error occured during writing benchmarks to SQLite database!")
      } else {
        cat("Database benchmarks table updated!")
      }
      
      cat("Start adding records to META table\n")
      meta_sql <- "INSERT INTO META VALUES (?, ?, ?)"
      updated <- try(bulk_insert(meta_sql, cur_meta), TRUE)
      if (inherits(updated, "try-error")){
        warning("Error occured during writing meta to SQLite database!")
      } else {
        cat("Database meta table updated!")
      }
      
    } else {
      
      cat("Start adding records to BENCHMARKS table\n")
      for (i in 1:nrow(cur_bmrk)) {
        updated <- try(
          dbSendQuery(conn,
                      sprintf(
                        "INSERT INTO BENCHMARKS VALUES 
                       ( \'%s\', \'%s\', \'%s\', \'%s\', 
                       \'%s\', \'%s\', \'%s\', \'%s\' );",
                        cur_bmrk[i,1], cur_bmrk[i,2], 
                        cur_bmrk[i,3], cur_bmrk[i,4], 
                        cur_bmrk[i,5], cur_bmrk[i,6], 
                        cur_bmrk[i,7], cur_bmrk[i,8], 
                        cur_bmrk[i,8]
                      )
          ), TRUE)
        if (inherits(updated, "try-error" )){
          warning("Error occured during writing benchmarks to database!")
        } else {
          cat("Database benchmarks table updated!")
        }
      }
      
      cat("Start adding records to META table\n")
      for (i in 1:nrow(cur_meta)){
        try(
          updated <- dbSendQuery(conn,
                      sprintf(
                        "INSERT INTO META VALUES 
                       ( \'%s\', \'%s\', \'%s\' );",
                        cur_meta[i,1], cur_meta[i,2], cur_meta[i,3]
                      )
          ), TRUE)
        if (inherits(updated, "try-error")){
          warning("Error occured during writing meta to database!")
        } else {
          cat("Database meta table updated!")
        }
      }
    }
  }
  
  cat("Closing SQLite database connection\n")
  dbDisconnect(conn)
  return(invisible("DB_UPDATED"))
}