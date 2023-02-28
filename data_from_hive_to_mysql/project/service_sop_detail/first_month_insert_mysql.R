library(RMySQL)

init_mysql <- function(dbname = "") {
  library(RMySQL)
  con <- dbConnect(RMySQL::MySQL(), 
                   dbname = 'dbname', 
                   host = "ip_address", 
                   port = 3306, 
                   user = "user_name", 
                   password = "password" 
  )
  dbSendQuery(con, "SET character_set_client='utf8'") 
  dbSendQuery(con, "SET character_set_connection='utf8'")
  dbSendQuery(con, "SET character_set_results='utf8'")
  con
}
# query
get_mysql_query <- function(query, dbname = "") {
  print(query)
  con <- init_mysql(dbname)
  dat <- dbGetQuery(con, query)
  dbDisconnect(con)
  dat
}
con <- init_mysql(dbname)


dat_firstmonth_byday <- get_mysql_query("
select DATE_FORMAT(dt,'%y%m') ym,right(dt,2) dd,dt,region,
COALESCE(count(stu_id),0) stunum,
COALESCE(sum(service_wechat_status),0) service_wechat_status,
COALESCE(sum(case when firstlesson is not null then is_preview end),0) is_preview_l,
COALESCE(sum(case when firstlesson is not null then is_review end),0) is_review_l,
COALESCE(sum(current_month_appoint_end_num),0) t_cost,
COALESCE(sum(shoutongfenmu),0) shoutong_fenmu,
COALESCE(sum(shoutongfenzi_f),0) shoutong_fenzi_f,
COALESCE(sum(shoutongfenzi_t),0) shoutong_fenzi_t,
COALESCE(count(case when firstlesson is not null then stu_id end),0) first_lesson_num,
COALESCE(count(case when firstunit is not null then stu_id end),0) first_unit_num,
COALESCE(sum(kaikelvfenzi),0) kaikelv_fenzi,
COALESCE(sum(kaikelvfenmu),0) kaikelv_fenmu
from first_month_list_detail_new
where region regexp 'SS'
and dt = DATE_SUB(CURDATE(),INTERVAL 1 day)
GROUP BY DATE_FORMAT(dt,'%y%m'),right(dt,2),dt,region

union all

select DATE_FORMAT(dt,'%y%m') ym,right(dt,2) dd,dt,'QS' region,
COALESCE(count(stu_id),0) stunum,
COALESCE(sum(service_wechat_status),0) service_wechat_status,
COALESCE(sum(case when firstlesson is not null then is_preview end),0) is_preview_l,
COALESCE(sum(case when firstlesson is not null then is_review end),0) is_review_l,
COALESCE(sum(current_month_appoint_end_num),0) t_cost,
COALESCE(sum(shoutongfenmu),0) shoutong_fenmu,
COALESCE(sum(shoutongfenzi_f),0) shoutong_fenzi_f,
COALESCE(sum(shoutongfenzi_t),0) shoutong_fenzi_t,
COALESCE(count(case when firstlesson is not null then stu_id end),0) first_lesson_num,
COALESCE(count(case when firstunit is not null then stu_id end),0) first_unit_num,
COALESCE(sum(kaikelvfenzi),0) kaikelv_fenzi,
COALESCE(sum(kaikelvfenmu),0) kaikelv_fenmu
from first_month_list_detail_new
where region regexp 'SS'
and  dt = DATE_SUB(CURDATE(),INTERVAL 1 day)
GROUP BY DATE_FORMAT(dt,'%y%m'),right(dt,2),dt,'QS'
                               ")

dbWriteTable(con,"first_month_byday",dat_firstmonth_byday,append=T,row.names=FALSE)
