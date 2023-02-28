## set connection, url, username, password

Sys.setenv("hive_username" = "user_name")
Sys.setenv("hive_password" = "user_password")

options(java.parameters = "-Xmx8g")
library(DBI)

## connect Hive
init_jdbc <- function() {
  require(RHJDBC)
  cp <- dir(system.file("java", package = "RHJDBC"), full.names = TRUE)  # you can use your own jdbc driver
  .jinit(classpath = cp) # init
  drv <- JDBC("org.apache.hive.jdbc.HiveDriver") # set driver
  con <- dbConnect(drv,
                   "ip_address",
                   Sys.getenv('hive_username'),
                   Sys.getenv('hive_password')
  ) # set connection,url,username,password
  class(con) <- "JHDBCConnection" # change the class of con
  con
}

# query Hive
getQuery <- function(query) {
  writeLines(query)
  conn <- init_jdbc()
  dat <- try(dbGetQuery(conn, query), silent = TRUE)
  dbDisconnect(conn)
  if (class(dat) %in% c("error", "try-error")) {
    return()
  }
  if (nrow(dat) > 0) {
    colnames(dat) <- gsub("(.*)\\.(.*)", "\\2", colnames(dat))
    data.table::setDT(dat)
    dat
  }
}

## query Hive_new_address
init_jdbc_new <- function() {
  require(RHJDBC)
  cp <- dir(system.file("java", package = "RHJDBC"), full.names = TRUE) # you can use your own jdbc driver
  .jinit(classpath = cp) # init
  drv <- JDBC("org.apache.hive.jdbc.HiveDriver") # set driver
  con <- dbConnect(drv,
                   "new_address",
                   Sys.getenv('hive_username'),
                   Sys.getenv('hive_password')
  ) # set connection,url,username,password
  class(con) <- "JHDBCConnection" # change the class of con
  con
}

# 查询 Hive_new
getQuery_new <- function(query) {
  writeLines(query)
  conn <- init_jdbc_new()
  dat <- try(dbGetQuery(conn, query), silent = TRUE)
  dbDisconnect(conn)
  if (class(dat) %in% c("error", "try-error")) {
    return()
  }
  if (nrow(dat) > 0) {
    colnames(dat) <- gsub("(.*)\\.(.*)", "\\2", colnames(dat))
    data.table::setDT(dat)
    dat
  }
}

mail_pw <- 'mail_password'
s_mail <- 'mail_address'
