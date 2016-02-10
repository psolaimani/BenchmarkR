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
benchDBReport <- function(usr=NULL, pwd=NULL, 
                          host_address=NULL, 
                          conn_string=NULL, 
                          db_name=NULL, con_type=NULL, dbname=NULL){
  
  # check if con info is provided
  if(is.null(host_address) & is.null(conn_string) & is.null(dbname)){
    warning("Can't write results to database. Missing connection information.\n")
    return(NULL)
  }
  
  if (con_type != "sqlite"){
    if(is.null(usr) | is.null(pwd) | is.null(db_name) )
      warning("Can't write results to database. \nMissing username, password, and db_name.\n")
    return(NULL)
  }
  
  # Get benchmarking/profiling data
  cur_bmrk <- benchGetter( target = "benchmarks" )
  cur_meta <- benchGetter( target = "meta" )
  
  # No connection to database has been made
  CONNECTED <- FALSE
  
  
  if (con_type == "mysql"){
    # Connect to MySQL
    cat("Connecting to MySQL database.\n")
    require(RMySQL)
    
    try(
      conn <- dbConnect(RMySQL(), username=usr, password=pwd, conn_string)
      ,TRUE)
    
    if (!exists("conn")) {
      try(conn <- dbConnect(MySQL(), username=usr, password=pwd, host=host_address),TRUE)
    }
    
    if (!exists("conn")) {
      warning("ERROR: Could not connect to database.")
      CONNECTED <- FALSE
      return(NULL)
    }
    
    CONNECTED <- TRUE
    cat("Connection to database established.\n")
    
  } else if (con_type == "sqlite") {
    if (is.null(dbname)){
      warning("ERROR: SQLite db location not provided.")
      return(NULL)
    }
    # Connect to SQLite
    cat("Connecting to SQLite database.\n")
    require(RSQLite)
    
    try(conn <- dbConnect(RSQLite(), dbname = dbname),TRUE)
    
    if (!exists("conn")) {
      try(conn <- dbConnect(SQLite(), dbname = dbname),TRUE)
    }
    
    if (!exists("conn")) {
      warning("ERROR: Could not connect to database!")
      CONNECTED <- FALSE
      return(NULL)
    }
    
    CONNECTED <- TRUE
    cat("Connection to database established.\n")
#    
#  } else if (con_type == "postgresql") {
#    # Connect to PostgreSQL
#    cat("Connecting to PostgreSQL database.\n")
#    require(RPostgreSQL)
#    conn <- dbConnect(RPostgreSQL(), con_str, usr, pwd)
#    CONNECTED <- TRUE
#    cat("Connection to database established.\n")
#    
#  } else if (con_type == "monetdb") {
#    # Connect to MonetDB
#    cat("Connecting to MonetDB database.\n")
#    require(MonetDB.R)
#    conn <- dbConnect(MonetDB.R(), username=usr, password=pwd, host=host_address, dbname=db_name)
#    CONNECTED <- TRUE
#    cat("Connection to database established.\n")
#    
#  } else if (con_type == "oracle"){
#    # Connect to Oracle
#    cat("Connecting to Oracle database.\n")
#    require(ROracle)
#    conn <- dbConnect(ROracle(), url=con_str, username=usr, password=pwd)
#    CONNECTED <- TRUE
#    cat("Connection to database established.\n")
#    
  } else {
    
    warning(sprintf("Database of type %s is not yet supported", con_type))
    CONNECTED <- FALSE
    return(NULL)
    
  }
  
  if (CONNECTED == TRUE) {
    
    if (con_type == "sqlite"){ 
      # adapted from http://www.inside-r.org/packages/cran/RSQLite/docs/dbSendPreparedQuery
      bulk_insert <- function(sql, key_counts) { 
        dbBegin(conn)
        dbSendPreparedQuery(conn, sql, bind.data = key_counts)
        dbCommit(conn)
      }
      
      cat("Start adding records to BENCHMARKS table\n")
      benchmark_sql <- "INSERT INTO BENCHMARKS VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
      try( bulk_insert(benchmark_sql, cur_bmrk), TRUE )
      
      cat("Start adding records to META table\n")
      meta_sql <- "INSERT INTO META VALUES (?, ?, ?)"
      try( bulk_insert(meta_sql, cur_meta), TRUE )
      
      cat("Database updated!\nClosing SQLite database connection\n")
      
      dbDisconnect(conn)
      
    } else {
      
      cat("Start adding records to BENCHMARKS table\n")
      for (i in 1:nrow(cur_bmrk)){
        try(
          dbSendQuery(conn,
                      sprintf(
                        "INSERT INTO BENCHMARKS VALUES 
                       ( \'%s\', \'%s\', \'%s\', \'%s\', 
                       \'%s\', \'%s\', \'%s\', \'%s\' );",
                        cur_bmrk[i,1], cur_bmrk[i,2], 
                        cur_bmrk[i,3], cur_bmrk[i,4], 
                        cur_bmrk[i,5], cur_bmrk[i,6], 
                        cur_bmrk[i,7], cur_bmrk[i,8]
                      )
          )
          , TRUE)
      }
      
      cat("Start adding records to META table\n")
      for (i in 1:nrow(cur_meta)){
        try(
          dbSendQuery(conn,
                      sprintf(
                        "INSERT INTO META VALUES 
                       ( \'%s\', \'%s\', \'%s\' );",
                        cur_meta[i,1], cur_meta[i,2], cur_meta[i,3]
                      )
          )
          , TRUE)
      }
      
      cat("Database updated!\nClosing database connection\n")
      
      dbDisconnect(conn)
    }
  }
  return(invisible("DB_UPDATED"))
}
