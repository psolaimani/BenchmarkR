#' benchDBReport
#' @description Uploads benchmarking/profiling results tp database
#' @usage benchDBReport(usr, psw, con_str)
#' @param usr database usrname
#' @param psw database password
#' @param con_str database connection string jdbc:mysql:location/database/table
#' @import rJava RJDBC
#' @export
benchDBReport <- function(usr=NULL, psw=NULL, con_str=NULL){
  require("rJava")
  require("RJDBC")
  
  # check if con info is provided
  if(is.null(usr) | is.null(psw) | is.null(con_str)){
    cat("Can't write results to database. Missing connection information.\n")
    return(NULL)
  }
  
  # extract database type from connection string
  con_type <- unlist(strsplit(con_str, ":"))[2]
  con_type <- tolower(con_type)
  
  updateRecord <- function(conn, table, data, var_nr){

  }
  
  if (con_type == "mysql"){
    cat("Connecting to MySQL database.\n")
    drv <- JDBC("com.mysql.jdbc.Driver", "./inst/java/mysql.jar")
    conn <- dbConnect(drv, con_str, user=usr, password=psw)
    cat("Connection to database established.\n")
    cur_bmrk <- benchGetter(target = "benchmarks" )
    cur_prfl <- benchGetter( target = "profiles" )
    cur_meta <- benchGetter( target = "meta" )
    
    cat("Start adding records to BENCHMARKS table\n")
    for (i in 1:nrow(cur_bmrk)){
      try(
        dbSendUpdate(conn,
                     sprintf(
                       "INSERT INTO BENCHMARKS VALUES ( \'%s\', \'%s\', \'%s\', \'%s\' );",
                       cur_bmrk[i,1], cur_bmrk[i,2], cur_bmrk[i,3], cur_bmrk[i,4]
                     )
        )
        , TRUE)
    }
    
    cat("Start adding records to PROFILES table\n")
    for (i in 1:nrow(cur_prfl)){
      try(
        dbSendUpdate(conn,
                     sprintf(
                       "INSERT INTO PROFILES VALUES ( \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\' );",
                       cur_prfl[i,1], cur_prfl[i,2], cur_prfl[i,3], cur_prfl[i,4], cur_prfl[i,5], cur_prfl[i,6], cur_prfl[i,7]
                     )
        )
        , TRUE)
    }
    
    cat("Start adding records to META table\n")
    for (i in 1:nrow(cur_meta)){
      try(
        dbSendUpdate(conn,
                     sprintf(
                       "INSERT INTO META VALUES ( \'%s\', \'%s\', \'%s\' );",
                       cur_meta[i,1], cur_meta[i,2], cur_meta[i,3]
                     )
        )
        , TRUE)
    }
    
  } else {
    cat(sprintf("Database of type %s is not yet supported", con_type))
    return(NULL)
  }
  
  cat("Database updated!\nClosing database connection\n")
  dbDisconnect(conn)
  return(invisible("DB_UPDATED"))
}