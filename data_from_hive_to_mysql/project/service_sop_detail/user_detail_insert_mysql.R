library(RMySQL)
source("/home/username/common/rhive.R")

con2=dbConnect(RMySQL::MySQL(),
               dbname='dbname', 
               host = "ip_address", 
               port = 3306, 
               user = "username", 
               password = "password" 
)
dbSendQuery(con2, "SET character_set_client='utf8'") 

dat_user_detail_one <- getQuery_new("
with ttm as (
    select t1.stu_id,t3.crm_id,t3.crm_name ss_name,t3.ss_group_name,t3.sm,t3.sd,t3.dgm,t3.region,
    referral_channel_type,t1.deal_time,date_add(t1.deal_time,7) as deadtime
    from dw.user_order t1
    left join (
        select user_id,last_ss_cst_id
        from dw.user_dispatch
        where partition_id = date_sub(current_date(),1)) t2 on t1.stu_id = t2.user_id
    left join (
        select crm_id,crm_name,dept7_name ss_group_name,
        dept6_leader_name sm,dept5_leader_name sd,dept4_leader_name dgm,
        concat(substr(dept4_name,1,instr(dept4_name,'-')-1),substr(dept4_name,instr(dept4_name,'-')+1,2)) region
        from dw.staff
        where partition_id = date_sub(current_date(),1)) t3 on t2.last_ss_cst_id = t3.crm_id
    join (
        select id,referral_channel_type
        from dw.user_base
        where partition_id = date_sub(current_date(),1)
        and business_type = 'b2c') t5 on t1.stu_id = t5.id
    where t1.deal_time >= trunc(date_sub(current_date(),1),'MM')
    and t1.deal_time < date_sub(current_date(),1)
    AND t1.is_normal_new = 1
    and t1.status = 'success'
    and t1.partition_id = date_sub(current_date(),1)
    AND t1.product_category = '1v1'
    and t1.serial_num in (0,1))

select date_sub(current_date(),1) dt,t1.region,t1.dgm,t1.sd,t1.sm,t1.ss_group_name,t1.ss_name,
t1.stu_id,t2.current_level stu_k12_level,coalesce(t2.sso_role,'') sso_role,
t1.referral_channel_type,t1.deal_time,
info_done,t2.oc_status,
t2.service_wechat_status,
coalesce(t2.black_bird_wechat_status,0) blackbirdstatus,t2.order_confirm,
coalesce(t2.is_preview,0) is_preview,coalesce(t2.is_review,0) is_review,
t2.unit_test,t2.unit_service_status,
t2.current_month_appoint_end_num
from ttm as t1
left join (
    select t1.user_id,t1.current_level,t1.sso_role,if(t3.user_id is not null,1,0) info_done,
    if(t4.user_id is not null,1,0) as oc_status,
    if(t1.service_wechat_status >0,1,0) service_wechat_status,
    t1.current_month_appoint_end_num,
    if(t1.black_bird_wechat_status > 0,1,0) black_bird_wechat_status,
    if(t1.order_confirm >0,1,0) order_confirm,
    t1.is_preview,t1.is_review,if(t1.first_unit_end_time >0,1,0) unit_test,
    if(t1.unit_service_status = 2,1,0) unit_service_status
    from dm.stdt_d as t1
    join ttm as t2 on t1.user_id = t2.stu_id
    left join org_structure.user_info t3 on t1.user_id = t3.user_id
    left join org_structure.oc_status t4 on t1.user_id = t4.user_id
    where t1.partition_id = date_sub(current_date(),1)) as t2 on t1.stu_id = t2.user_id

")


dat_user_detail_shoutong <- getQuery_new("
with ttm as (
    select t1.stu_id,t1.deal_time,
    default.from_unixtime_local(t4.dispatch_time,'yyyy-MM-dd HH:mm:ss') as dispatch,
    default.from_unixtime_local(t4.dispatch_time+172800,'yyyy-MM-dd HH:mm:ss') as f_dispatch,
    default.from_unixtime_local(t4.dispatch_time+86400,'yyyy-MM-dd HH:mm:ss') as t_dispatch
    from dw.user_order t1
    left join (
        select user_id,dispatch_time
        from crmnew.user_cycle
        where partition_id = date_sub(current_date(),1)) t4 on t1.stu_id = t4.user_id
    where t1.deal_time >= trunc(date_sub(current_date(),1),'MM')
    and t1.deal_time < date_sub(current_date(),1)
    AND t1.is_normal_new = 1
    and t1.status = 'success'
    and t1.partition_id = date_sub(current_date(),1)
    AND t1.product_category = '1v1'
    and t1.serial_num in (0,1))
select t1.stu_id,t1.dispatch first_dispatch_time,
if(t1.dispatch >= t1.deal_time,1,0) shoutongfenmu,
if(t1.dispatch >= t1.deal_time and tt.f_call_num >0 ,1,0) shoutongfenzi_f,
if(t1.dispatch >= t1.deal_time and tt.t_call_num >0 ,1,0) shoutongfenzi_t
from
ttm as t1
left join (
    select t1.stu_id,t1.dispatch,t1.f_dispatch,t1.t_dispatch,
       count(case when t6.end_time <= t1.f_dispatch then t6.id end) as f_call_num,
       count(case when t6.end_time <= t1.t_dispatch then t6.id end) as t_call_num
       from ttm as t1
       left join crmnew.call_detail as t6 on t1.stu_id = t6.user_id
       left join (select * from dw.staff where partition_id = date_sub(current_date(),1)) as t7 on t6.u_id = t7.id
       where t7.group_name regexp 'IS|ST|SS' and t6.bridge_duration >= 120
       and t6.end_time >= t1.dispatch and t6.end_time <= t1.f_dispatch
       group by t1.stu_id,t1.dispatch,t1.f_dispatch,t1.t_dispatch) tt on t1.stu_id = tt.stu_id
")

dat_user_detail_kaike <- getQuery_new("
                                                                       with ttm as (
    select t1.stu_id,t1.deal_time,date_add(t1.deal_time,7) as deadtime
    from dw.user_order t1
    where t1.deal_time >= trunc(date_sub(current_date(),1),'MM')
    and t1.deal_time < date_sub(current_date(),1)
    AND t1.is_normal_new = 1
    and t1.status = 'success'
    and t1.partition_id = date_sub(current_date(),1)
    AND t1.product_category = '1v1'
    and t1.serial_num in (0,1)),
tto as (
select t1.stu_id,1 as kaikefenmu,
count(case when t2.end_time >= t1.deal_time and t2.end_time <= t1.deadtime then t1.stu_id end) cost
    from ttm as t1
    left join (
        select id,user_id,end_time
        from dw.fact_appoint
        where dt >= date_format(date_sub(current_date(),1),'yyyy-MM-01')
        and status = 'end'
        and use_point = 'buy') as t2 on t1.stu_id = t2.user_id
    where t1.deal_time < date_sub(current_date(),6)
    group by t1.stu_id,1)
select t1.stu_id,if(t3.stu_id is not null,t3.kaikefenmu,0) kaikelvfenmu,
if(t3.cost > 0,1,0) kaikelvfenzi
from ttm as t1
left join tto as t3 on t1.stu_id = t3.stu_id
                                      ")

dat_total <- merge(dat_user_detail_one, dat_user_detail_shoutong, by = 'stu_id',all.dat_user_detail_one=TRUE)
dat_total <- merge(dat_total,dat_user_detail_kaike, by = 'stu_id',all.dat_total=TRUE)

dbWriteTable(con2,"first_month_list_detail_new",dat_total,append=T,row.names=FALSE)
