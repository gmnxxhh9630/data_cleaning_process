library(shiny)
library(tidyr)
library(plotly)
library(dplyr)
library(shinyWidgets)
library(lubridate)
library(RColorBrewer)
library(formattable)
library(dashboardthemes)
library(DT)
source("conn.R")
source("function.R")

options(digits =  1)

stu_occup_list <- c("kids","primary","junior","senior","university","worker","other")

overseas_list <- c("yes","no")
is_zhengjia_list <- c("yes","no")
is_zhengjia_disable_list <- c("yes","no")

valid_range_list <- c("0-30days","31-60days","61-90days","91-120days","121-180days","181-240days","241-300days","301-360days","more than 360")

count_range_list <- c("0count","1-15count","16-30count","31-45count","46-90count","91-180count","181-270count","271-360count","more than 360")

province_list <- get_mysql_query("select distinct province from stu_range_detail")

city_list <- get_mysql_query("select distinct city from stu_range_detail")

choice_ym <- format(seq(as.Date('2020-01-01'),Sys.Date()-1,by="months"),'%y%m')
cur_ym <- format(Sys.Date()-1,'%y%m')
