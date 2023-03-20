library(shiny)
library(tidyr)
library(plotly)
library(dplyr)
library(lubridate)
library(RColorBrewer)
library(formattable)
library(DT)
source("conn.R")

options(DT.options = list(
  searchHighlight = TRUE,
  language = list(
    info = 'show_START_ to _END_ results，all _TOTAL_ results',
    search = 'search:',
    paginate = list(previous = 'up', `next` = 'down'),
    lengthMenu = 'show _MENU_ results'),
  columnDefs = list(
    list(className = 'dt-center',
         width = '112px',
         targets = c(-1:-17)
        ))))


key_kpi_rate_func <- function(dat){
  summarize(dat,
            stunum = sum(stunum),
            shoutong_rate_f = round(sum(shoutongfenzi_f)/sum(shoutongfenmu) * 100,0),
            shouke_rate = round(sum(shoukefenzi)/sum(shoukefenmu) * 100,0),
            avg_cost = round(mean(current_month_appoint_end_num),1),
            wechat_rate = round(sum(service_wechat_status)/sum(stunum) * 100,0),
            unit_service_rate = round(sum(unit_service_status_u)/sum(is_firstunit) * 100,0)) %>%
    mutate_all(~replace(., is.na(.), 0)) %>%
    mutate(
      rank_point = rank(-shoutong_rate_f,ties.method = 'min')*0.2 +
        rank(-shouke_rate,ties.method = 'min')*0.2+
        rank(-wechat_rate,ties.method = 'min')*0.25 +
        rank(-unit_service_rate,ties.method = 'min')*0.35) %>%

    rename(c('firstcall%' = shoutong_rate_f,'student num' = stunum,
             'firstlesson%' = shouke_rate,
            'average cost' = avg_cost,'wechat connect%' = wechat_rate,'unit_rate%' = unit_service_rate))

}

knitr_func <- function(dat){
  knitr::kable(dat,
               format = "html",
               escape = FALSE,
               align = "c",
               table.attr = 'class = "table"') %>%
    HTML()
}


select_region_list_l <- c("BJSS","SHSS","WHSS","SJZSS","HFSS","ZZSS","QS")
select_region_list_r <- c("BJSS","SHSS","WHSS","SJZSS","HFSS","ZZSS")

choice_ym <- format(seq(as.Date('2019-06-01'),Sys.Date()-1,by="months"),'%y%m')
select_ym_l <- format(Sys.Date()-1,'%y%m')


input_date_range <- function(inputId = "date_range_dt", width = 4) {
  column(
    width = width,
    dateRangeInput(
      inputId = inputId, label = "first order date",
      start = floor_date(as.Date(Sys.Date()-1) %m-% months(0),'month'),
      end = Sys.Date() - 2,
      min = floor_date(as.Date(Sys.Date()-1) %m-% months(0),'month'),
      max = Sys.Date() - 2
    )
  )
}


dt_func <- function(dat){

    datatable(dat,
      filter = "top",
      extensions = c('Buttons','FixedColumns'),
      options = list(
        scrollX = TRUE,
        scrollY = ifelse(nrow(dat) <= 10, "auto", 350),
        scroller = TRUE,
        autoWidth = TRUE,
        pageLength = nrow(dat),
        dom = 'Bfrtip',
        buttons = c('excel'),
        fixedColumns = list(leftColumns = ncol(dat) - 15),
        deferRender = TRUE)) %>%
    formatStyle(
      'firstcall48h%',
      background = styleColorBar(dat$`firstcall%`, 'lightpink',angle = -90),
      backgroundSize = '100% 60%',
      backgroundRepeat = 'no-repeat',
      backgroundPosition = 'center') %>%
    formatStyle(
      'firstlesson%',
      background = styleColorBar(dat$`firstlesson%`, 'lightblue',angle = -90),
      backgroundSize = '100% 60%',
      backgroundRepeat = 'no-repeat',
      backgroundPosition = 'center')

}



user_detail_func <- function(dat) {
  select(dat,stu_id,region,dgm,sd,sm,ss_group_name,ss_name,referral_channel_type,deal_time,service_wechat_status,
         unit_service_status,shoutongfenzi_f,
         firstlesson,kaikelvfenzi)%>%
    rename('student ID'=stu_id,'district' = region,'Team' = ss_group_name,'SS' = ss_name,'channel' = referral_channel_type,
           'deal time' = deal_time,'wechat status' = service_wechat_status,'unit status' = unit_service_status,
           'first call status' = shoutongfenzi_f,'first lesson status' = firstlesson,'open class' = kaikelvfenzi)%>%
    datatable(
            filter = "top",
            extensions = c('Buttons','FixedColumns'),
            options = list(
              scrollX = TRUE,
              scrollY = ifelse(nrow(dat) <= 10, "auto", 350),
              scroller = TRUE,
              autoWidth = TRUE,
              pageLength = nrow(dat),
              dom = 'Bfrtip',
              buttons = c('excel'),
              fixedColumns = list(leftColumns = 2),
              deferRender = TRUE))
}

thirty_days <- Sys.Date()-30
