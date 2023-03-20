


init_mysql <- function(dbname = "") {
  library(RMySQL)
  con <- dbConnect(RMySQL::MySQL(),
                   dbname = 'dbname',
                   host = "ipaddress",
                   port = 3306,
                   user = "username",
                   password = "password"
  )
  dbSendQuery(con, "SET character_set_client='utf8'")
  dbSendQuery(con, "SET character_set_connection='utf8'")
  dbSendQuery(con, "SET character_set_results='utf8'")
  con
}


get_mysql_query <- function(query, dbname = "dbname") {
  print(query)
  con <- init_mysql(dbname)
  dat <- dbGetQuery(con, query)
  dbDisconnect(con)
  dat
}
