library(tidyr)
library(dplyr)
library(DT)
library(xlsx)
library(dashboardthemes)
library(shinydashboard)
library(shinyWidgets)
library(RColorBrewer)
library(plotly)
library(ggplot2)
library(formattable)
library(DBI)
source("conn.R")


options(DT.options = list(
  searchHighlight = TRUE,
  language = list(
    info = 'Show from_START_ to _END_ results',
    search = 'search:'),
  columnDefs = list(
    list(className = 'dt-center',
         width = '100px',
         targets = '_all'))))

rank_func_ss <- function(dat){
  mutate(dat,
         performance_rank = rank(-calculating_performance,ties.method = 'min'),
         renew_rate_rank = rank(-new_stu_renew_rate,ties.method = 'min'),
         unit_rate_rank = rank(-unit_rate,ties.method = 'min'),
         kehao_rate_rank = rank(-kehao_rate,ties.method = 'min'),
         refund_rate_rank = rank(refund_rate,ties.method = 'min'))%>%
    mutate(t_point = performance_rank * 0.3+ renew_rate_rank * 0.25+refund_rate_rank * 0.25+ unit_rate_rank * 0.1 + kehao_rate_rank * 0.1)%>%
    mutate(t_rank = rank(t_point,ties.method = 'min')) %>%
    arrange(t_rank) %>%
    group_by(region,dgm)%>%
    mutate(region_rank = rank(t_rank,ties.method = 'min')) %>%
    select(region = region,DGM = dgm,Team = ss_group_name,ss_name,calculating_performance = calculating_performance,
             new_stu_renew_rate = new_stu_renew_rate,refund_rate = refund_rate,
           unit_rate = unit_rate,kehao_rate = kehao_rate,t_rank=t_rank,region_rank = region_rank)

}

rank_func <- function(dat){
  mutate(dat,
         performance_rank = rank(-calculating_performance,ties.method = 'min'),
         challenge_rate_rank = rank(-challenge_rate,ties.method = 'min'),
         renew_rate_rank = rank(-new_stu_renew_rate,ties.method = 'min'),
         unit_rate_rank = rank(-unit_rate,ties.method = 'min'),
         kehao_rate_rank = rank(-kehao_rate,ties.method = 'min'),
         refund_rate_rank = rank(refund_rate,ties.method ='min'))%>%
    mutate(t_point = performance_rank * 0.15+ challenge_rate_rank * 0.15 + renew_rate_rank * 0.1 +unit_rate_rank * 0.1 + kehao_rate_rank * 0.1 + refund_rate_rank * 0.4)%>%
    mutate(t_rank = rank(t_point,ties.method = 'min')) %>%
    arrange(t_rank)

}


dt_func_ss <- function(dat){
  datatable(dat,
            rownames = FALSE,
            extensions = c('FixedColumns','Buttons'),
            options = list(
              scrollX = TRUE,
              scrollY = ifelse(nrow(dat) <= 15, "auto", 450),
              scroller = TRUE,
              autoWidth = TRUE,
              pageLength = nrow(dat),
              dom = 'Bfrtip',
              buttons = c('excel'),
              rowCallback = JS(
                "function(row, data) {",
                "var num = data[4].toString().replace(/\\B(?=(\\d{3})+(?!\\d))/g, ',');",
                "$('td:eq(4)', row).html(num);",
                "}"),
              fixedColumns = list(leftColumns = ncol(dat) - 12),
              deferRender = TRUE)) %>%
    formatPercentage(c('new_stu_renew_rate','unit_rate','kehao_rate','refund_rate'),2)

}

dt_func_tl <- function(dat){
  datatable(dat,
            rownames = FALSE,
            extensions = c('FixedColumns','Buttons'),
            options = list(
              scrollX = TRUE,
              scrollY = ifelse(nrow(dat) <= 15, "auto", 450),
              scroller = TRUE,
              autoWidth = TRUE,
              pageLength = nrow(dat),
              buttons = c('excel'),
              dom = 'Bfrtip',
              rowCallback = JS(
                "function(row, data) {",
                "var num = data[3].toString().replace(/\\B(?=(\\d{3})+(?!\\d))/g, ',');",
                "$('td:eq(3)', row).html(num);",
                "}"),
              fixedColumns = list(leftColumns = ncol(dat) - 14),
              deferRender = TRUE)) %>%
    formatPercentage(c('new_stu_renew_rate','unit_rate','kehao_rate','refund_rate'),2)

}

dt_func <- function(dat){
  datatable(dat,
            rownames = FALSE,
            extensions = c('FixedColumns','Buttons'),
            options = list(
              scrollX = TRUE,
              scrollY = ifelse(nrow(dat) <= 15, "auto", 450),
              scroller = TRUE,
              autoWidth = TRUE,
              pageLength = nrow(dat),
              buttons = c('excel'),
              dom = 'Bfrtip',
              rowCallback = JS(
                "function(row, data) {",
                "var num = data[2].toString().replace(/\\B(?=(\\d{3})+(?!\\d))/g, ',');",
                "$('td:eq(2)', row).html(num);",
                "}"),
              fixedColumns = list(leftColumns = ncol(dat) - 13),
              deferRender = TRUE)) %>%
    formatPercentage(c('new_stu_renew_rate','unit_rate','kehao_rate','refund_rate'),2)

}

renew_dt_func <- function(dat){
  datatable(dat,
            rownames = FALSE,
            extensions = 'Buttons',
            options = list(
              scrollY = ifelse(nrow(dat) <= 15, "auto", 450),
              scroller = TRUE,
              pageLength = nrow(dat),
              buttons = c('excel'),
              dom = 'Bfrtip',
              deferRender = TRUE))

}


choice_list <- get_mysql_query("select distinct region,dgm,sd,sm,ss_group_name from ss_season_renew_rate_detail ")



choice_days <- seq(as.Date('2019-08-01'),Sys.Date()-1,by="months")-1
yes_day <- Sys.Date()-1
day_list <- c(choice_days,yes_day)
