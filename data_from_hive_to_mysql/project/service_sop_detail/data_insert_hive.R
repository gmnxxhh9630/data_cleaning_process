library(DBI)
library(data.table)
source("/home/username/common/rhive.R")

user_info_delete <- getQuery_new("
                                  truncate table  org_structure.user_info")

user_info_insert <- getQuery_new("
insert into org_structure.user_info
select stdt_id user_id,1 as is_yes
        from dm.uvc_d
        where partition_id = date_sub(current_date(),1)
        and first_pay_time >= date_format(date_sub(current_date(),1),'yyyy-MM-01')
        and lrn_purse_type <> ''")

oc_status_delete <- getQuery_new("
                                  truncate table  org_structure.oc_status")


oc_status_insert <- getQuery_new("
insert into org_structure.oc_status
select distinct talk_user_id user_id,1 as is_in from ods.eb_live_user
where room_id in (703,704)")
