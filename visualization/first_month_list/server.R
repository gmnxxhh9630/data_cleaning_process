library(shiny)
library(xlsx)
library(plotly)
library(ggplot2)
library(RColorBrewer)
library(formattable)
source("global.R")

server <- function(input, output, session) {
  ss_server_byteam <- reactive({
    select_region_option <- paste("'", input$region_input, "'", sep = "", collapse = ",")
    select_qudao_option <- paste("'", input$qudao_input, "'", sep = "", collapse = ",")
    user_detail <- get_mysql_query(sprintf("
select *,1 stunum,
if(firstlesson is not null,1,0) is_firstlesson,
if(firstunit is not null,1,0) is_firstunit,
if(firstlesson is not null,is_preview,0) is_preview_l,
if(firstlesson is not null,is_review,0) is_review_l,
if(firstunit is not null,unit_test,0) unit_test_u,
if(firstunit is not null,unit_service_status,0) unit_service_status_u
from first_month_list_detail_new
where region regexp 'SS|ST'
and sso_role = '11'
and region in (%s)
and referral_channel_type in (%s)
and date(deal_time) between '%s' and '%s'
and dt = date_sub(CURDATE(),INTERVAL 1 day)",select_region_option,select_qudao_option,input$date_range_dt[1],input$date_range_dt[2]))
  })

  ss_server_plot_l <- reactive({
    select_region_option <- paste("'", input$region_input_l, "'", sep = "", collapse = ",")
    select_ym_option <- paste("'", input$select_ym_l, "'", sep = "", collapse = ",")
    first_month_byday <- get_mysql_query(sprintf("
    select * from first_month_byday
                                         where region in (%s) and ym in (%s)",select_region_option,select_ym_option))
  })

  ss_server_plot_r <- reactive({
    select_region_option <- paste("'", input$region_input_r, "'", sep = "", collapse = ",")
    select_ym_option <- paste("'", input$select_ym_r, "'", sep = "", collapse = ",")
    first_month_byday <- get_mysql_query(sprintf("
    select * from first_month_byday
                                         where region in (%s) and ym in (%s)",select_region_option,select_ym_option))
  })

  ss_server_byday <- reactive({
    first_month_byday <- get_mysql_query("
    select * from first_month_byday ")
  })

  output$user_region <- renderDataTable({
    d <- ss_server_byteam() %>%
      group_by(region) %>%
      key_kpi_rate_func() %>%
      arrange(rank_point)%>%
      select(-c(rank_point))
    region <- c('total')
    e <- data.frame(region)
    f <- ss_server_byteam() %>%
      group_by() %>%
      key_kpi_rate_func() %>%
      select(-c(rank_point))
    g <- cbind(e,f)
    new_dt <- rbind(d,g)%>%
      dt_func()

  })


  output$user_detail <- renderDataTable({
    d <- ss_server_byteam() %>%
      user_detail_func()
  })

  output$shoutong_rate_f <- renderPlotly({
    ss_server_byday() %>%
      mutate(shoutong_rate_f = round(shoutong_fenzi_f/shoutong_fenmu *100,0))%>%
      filter(region == 'QS') %>%
      filter(dt >= thirty_days) %>%
      select(dt,shoutong_rate_f) %>%
      plot_ly(x = ~dt) %>%
      add_lines(y = ~shoutong_rate_f) %>%
      add_markers(x =~dt,y = ~shoutong_rate_f,showlegend = F)%>%
      layout(title = list(text ="firstcall48h(%)",y = 0.95))
  })


  output$shouke_rate <- renderPlotly({
    ss_server_byday() %>%
      mutate(shouke_rate = round(shouke_fenzi/shouke_fenmu *100,0))%>%
      filter(region == 'QS') %>%
      filter(dt >= thirty_days) %>%
      select(dt,shouke_rate) %>%
      plot_ly(x = ~dt) %>%
      add_lines(y = ~shouke_rate) %>%
      add_markers(x =~dt,y = ~shouke_rate,showlegend = F)%>%
      layout(title = list(text ="firstlesson(%)",y = 0.95))
  })


  output$top_team <- renderUI({
    s <- ss_server_byteam() %>%
      select(region,ss_group_name) %>%
      distinct()
    d <- ss_server_byteam() %>%
      group_by(ss_group_name) %>%
      key_kpi_rate_func() %>%
      filter(ss_group_name != '')
    d <- merge(d,s, by = 'ss_group_name',all.d=TRUE) %>%
      arrange(rank_point)%>%
      select(region,ss_group_name,'firstcall48h%','firstlesson%','firstunit%','stu_info%','OCbook%','review%','preview%') %>%
      head(10)
    d[is.na(d)] <- 0
    knitr_func(d)
  })

  output$byym_shoutong_f <- renderPlotly({
    ss_server_plot_r() %>%
      group_by(ym,dd) %>%
      summarize(shoutong_rate_f = round(sum(shoutong_fenzi_f)/sum(shoutong_fenmu) * 100,0))%>%
      select(dd,ym,shoutong_rate_f) %>%
      plot_ly() %>%
      add_lines(x = ~dd,color =  ~ ym,y = ~shoutong_rate_f)%>%
      add_markers(x = ~dd,color =  ~ ym,y = ~shoutong_rate_f,showlegend = F)%>%
      layout(title = list(text ="firstcall48h(%)",y = 0.95),legend = list(orientation = 'h'))
  })


  output$byym_shouke <- renderPlotly({
    ss_server_plot_r() %>%
      group_by(ym,dd) %>%
      summarize(shouke_rate = round(sum(shouke_fenzi)/sum(shouke_fenmu) * 100,0))%>%
      select(dd,ym,shouke_rate) %>%
      plot_ly() %>%
      add_lines(x = ~dd,color =  ~ ym,y = ~shouke_rate)%>%
      add_markers(x = ~dd,color =  ~ ym,y = ~shouke_rate,showlegend = F)%>%
      layout(title = list(text ="firstlesson(%)",y = 0.95),legend = list(orientation = 'h'))
  })


  output$tx <- renderTable({
    df <- read.table("./notes.txt", sep = "\t", header = TRUE, fileEncoding = "utf-8")
    return(df)})
}
