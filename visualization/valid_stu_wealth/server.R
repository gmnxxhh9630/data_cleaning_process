

server <- function(input, output, session) {
  stu_range <- reactive({
    select_occup_option <- paste("'", input$stu_occup, "'", sep = "", collapse = ",")
    select_valid_end_option <- paste("'", input$valid_end, "'", sep = "", collapse = ",")
    select_point_count_option <- paste("'", input$point_count, "'", sep = "", collapse = ",")
    select_business_type_option <- paste("'", input$business_type, "'", sep = "", collapse = ",")
    select_is_hm_option <- paste("'", input$is_hm, "'", sep = "", collapse = ",")
    select_province <- paste("'", input$province_select, "'", sep = "", collapse = ",")
    select_city <- paste("'", input$city_select, "'", sep = "", collapse = ",")
    select_overseas <- paste("'", input$is_overseas, "'", sep = "", collapse = ",")
    select_is_zhengjia <- paste("'", input$is_zhengjia, "'", sep = "", collapse = ",")
    select_is_zhengjia_disable <- paste("'", input$is_zhengjia_disable, "'", sep = "", collapse = ",")
    stu_range <- get_mysql_query(sprintf("
                                 select * from stu_range_detail
                                         where occup_type in (%s)
                                         and valid_end in (%s)
                                         and point_count in (%s)
                                         and business_type in (%s)
                                         and is_hm in (%s)
                                         and province in (%s)
                                         and city in (%s)
                                         and is_overseas in (%s)
                                         and is_zhengjia in (%s)
                                         and is_disable_point in (%s)",select_occup_option,select_valid_end_option,select_point_count_option,select_business_type_option,select_is_hm_option,select_province,select_city,select_overseas,select_is_zhengjia,select_is_zhengjia_disable))
  })

  stu_trend <- reactive({
    select_ym_option <- paste("'", input$ym_select, "'", sep = "", collapse = ",")
    select_occup_option <- paste("'", input$stu_occup_sec, "'", sep = "", collapse = ",")
    select_valid_end_option <- paste("'", input$valid_end_sec, "'", sep = "", collapse = ",")
    select_point_count_option <- paste("'", input$point_count_sec, "'", sep = "", collapse = ",")
    select_business_type_option <- paste("'", input$business_type_sec, "'", sep = "", collapse = ",")
    select_is_hm_option <- paste("'", input$is_hm_sec, "'", sep = "", collapse = ",")
    dat_byday <- get_mysql_query(sprintf("
                                         select * from stu_wealth_byday
                                         where ym  in (%s)
                                         and occup_type in (%s)
                                         and valid_end in (%s)
                                         and point_count in (%s)
                                         and business_type in (%s)
                                         and is_hm in (%s)",select_ym_option,select_occup_option,select_valid_end_option,select_point_count_option,select_business_type_option,select_is_hm_option))
  })

  output$valid_range <- renderDataTable({
    d <- stu_range()
    d$valid_end <- factor(d$valid_end, levels = valid_range_list)
    d[order(d$valid_end),]

    od <- d %>%
      group_by(valid_end) %>%
      summarize_func()

    valid_end <- "HZ"
    e <- data.frame(valid_end)

    f <- stu_range() %>%
      group_by() %>%
      summarize_func()

    g <- cbind(e,f)
    new_dt <-  rbind(od,g) %>%
      dt_func()

  })

  output$point_range <- renderDataTable({
    d <- stu_range()
    d$point_count <- factor(d$point_count, levels = count_range_list)
    d[order(d$point_count),]

    od <- d %>%
      group_by(point_count) %>%
      summarize_func()

    point_count <- "HZ"
    e <- data.frame(point_count)

    f <- stu_range() %>%
      group_by() %>%
      summarize_func()

    g <- cbind(e,f)
    new_dt <-  rbind(od,g) %>%
      dt_func()

  })


  output$is_overseas <- renderDataTable({
    d <- stu_range()
    d$is_overseas <- factor(d$is_overseas, levels = overseas_list)
    d[order(d$is_overseas),]

    od <- d %>%
      group_by(is_overseas) %>%
      summarize_func()

    is_overseas <- "HZ"
    e <- data.frame(is_overseas)

    f <- stu_range() %>%
      group_by() %>%
      summarize_func()

    g <- cbind(e,f)
    new_dt <-  rbind(od,g) %>%
      dt_func()

  })

  output$occup_range <- renderDataTable({
    d <- stu_range()
    d$occup_type <- factor(d$occup_type, levels = stu_occup_list)
    d[order(d$occup_type),]

    od <- d %>%
      group_by(occup_type) %>%
      summarize_func()

    occup_type <- "HZ"
    e <- data.frame(occup_type)

    f <- stu_range() %>%
      group_by() %>%
      summarize_func()

    g <- cbind(e,f)
    new_dt <-  rbind(od,g) %>%
      dt_func()


  })

  output$city <- renderDataTable({
    d <- stu_range()
    od <- d %>%
      group_by(city) %>%
      summarize_func()

    city <- "HZ"
    e <- data.frame(city)

    f <- stu_range() %>%
      group_by() %>%
      summarize_func()

    g <- cbind(e,f)
    new_dt <-  rbind(od,g) %>%
      dt_func()


  })

  output$byym_hm_count <- renderPlotly({
    stu_trend() %>%
      group_by(ym,dd) %>%
      summarize(hm_point_count = sum(hm_count_num))%>%
      select(dd,ym,hm_point_count) %>%
      plot_ly() %>%
      add_lines(x = ~dd,color =  ~ ym,y = ~hm_point_count)%>%
      add_markers(x = ~dd,color =  ~ ym,y = ~hm_point_count,showlegend = F)%>%
      layout(title = list(text ="hm count",y = 0.95),legend = list(orientation = 'h'))
  })

  output$byym_point_count <- renderPlotly({
    stu_trend() %>%
      group_by(ym,dd) %>%
      summarize(point_count = sum(point_count_num))%>%
      select(dd,ym,point_count) %>%
      plot_ly() %>%
      add_lines(x = ~dd,color =  ~ ym,y = ~point_count)%>%
      add_markers(x = ~dd,color =  ~ ym,y = ~point_count,showlegend = F)%>%
      layout(title = list(text ="1v1 count",y = 0.95),legend = list(orientation = 'h'))
  })

  output$byym_hm_count_avg <- renderPlotly({
    stu_trend() %>%
      group_by(ym,dd) %>%
      summarize(hm_point_count_avg = sum(hm_count_num)/sum(stunum))%>%
      select(dd,ym,hm_point_count_avg) %>%
      plot_ly() %>%
      add_lines(x = ~dd,color =  ~ ym,y = ~hm_point_count_avg)%>%
      add_markers(x = ~dd,color =  ~ ym,y = ~hm_point_count_avg,showlegend = F)%>%
      layout(title = list(text ="AVG hm count",y = 0.95),legend = list(orientation = 'h'))
  })

  output$byym_point_count_avg <- renderPlotly({
    stu_trend() %>%
      group_by(ym,dd) %>%
      summarize(point_count_avg = sum(point_count_num)/sum(stunum))%>%
      select(dd,ym,point_count_avg) %>%
      plot_ly() %>%
      add_lines(x = ~dd,color =  ~ ym,y = ~point_count_avg)%>%
      add_markers(x = ~dd,color =  ~ ym,y = ~point_count_avg,showlegend = F)%>%
      layout(title = list(text ="AVG1v1 count",y = 0.95),legend = list(orientation = 'h'))
  })
}
