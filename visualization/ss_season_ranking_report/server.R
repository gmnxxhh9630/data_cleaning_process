library(shiny)


server <- function(input, output, session){
  ss_ranking <- reactive({

    ss_ranking <- get_mysql_query(sprintf(
      "select * from ss_season_byss where dt = '%s'",input$select_dt))%>%
      rank_func_ss()
  })

  tl_ranking <- reactive({

    tl_ranking <- get_mysql_query(sprintf(
      "select * from ss_season_byteam where dt = '%s'",input$select_dt))%>%
      rank_func()%>%
      group_by(region,dgm)%>%
      mutate(region_rank = rank(t_rank,ties.method = 'min')) %>%
      select(DAQU = region,DGM = dgm,TL = tl,calculating_performance = calculating_performance,
             challenge_rate = challenge_rate,new_stu_renew_rate = new_stu_renew_rate,refund_rate = refund_rate,
             unit_rate = unit_rate,kehao_rate = kehao_rate,t_rank = t_rank,region_rank = region_rank)

  })


  dgm_ranking <- reactive({

    dgm_ranking <- get_mysql_query(sprintf(
      "select * from ss_season_bydgm where dt = '%s'",input$select_dt))%>%
      rank_func()%>%
      select(DAQU = region,DGM = dgm,calculating_performance = calculating_performance,
             challenge_rate = challenge_rate,new_stu_renew_rate = new_stu_renew_rate,refund_rate = refund_rate,
             unit_rate = unit_rate,kehao_rate = kehao_rate,t_rank = t_rank)
  })

  newstu_renew_detail <- reactive({
    select_region_option <- paste("'", input$region_range, "'", sep = "", collapse = ",")
    select_dgm_option <- paste("'", input$dgm_range, "'", sep = "", collapse = ",")
    select_team_option <- paste("'", input$team_range, "'", sep = "", collapse = ",")

    newstu_renew_detail <- get_mysql_query(sprintf(
      "select * from ss_season_renew_rate_detail
      where lock_region in (%s)
      and lock_dgm in (%s)
      and lock_ss_group_name in (%s)",select_region_option,select_dgm_option,select_team_option))
  })


  output$ss_ranking <- renderDataTable({
    d <- ss_ranking() %>%
      dt_func_ss()
  })

  output$tl_ranking <- renderDataTable({
    d <- tl_ranking() %>%
      dt_func_tl()
  })


  output$dgm_ranking <- renderDataTable({
    d <- dgm_ranking()  %>%
      dt_func()
  })

  output$renew_cohort <- renderDataTable({
    d <- newstu_renew_detail() %>%
      group_by(first_deal_ym) %>%
      summarize(new = sum(newstu_num),
                renew = sum(renew_num))
    e <- newstu_renew_detail() %>%
      filter(renew_num== 1)%>%
      group_by(first_deal_ym,first_renew_ym)%>%
      summarize(renew = sum(renew_num)) %>%
      spread(first_renew_ym,renew)

    f <- merge(d,e,by = 'first_deal_ym',all.d = TRUE)

    first_deal_ym <- c('HUIZONG')
    region_t <- data.frame(first_deal_ym)

    d_h <- newstu_renew_detail() %>%
      group_by() %>%
      summarize(new = sum(newstu_num),
                renew = sum(renew_num))
    e_h <- newstu_renew_detail() %>%
      filter(renew_num == 1)%>%
      group_by(first_renew_ym)%>%
      summarize(renew = sum(renew_num)) %>%
      spread(first_renew_ym,renew)
    g <- cbind(region_t,d_h)
    h <- cbind(region_t,e_h)
    i <- merge(g,h,by = 'first_deal_ym',all.g = TRUE)
    new_d <- rbind(f,i)%>%
      rename(c('SHOUDAN YM' = first_deal_ym, 'new student num' = new,'renew student num' = renew))%>%
      renew_dt_func()


    })

  output$renew_cohort_rate <- renderDataTable({

    first_deal_ym <- c('HUIZONG')
    region_t <- data.frame(first_deal_ym)

    d <- newstu_renew_detail() %>%
      group_by(first_deal_ym) %>%
      summarize(new = sum(newstu_num),
                renew = scales::percent(sum(renew_num)/sum(newstu_num), accuracy = 0.01))
    d_h <- newstu_renew_detail() %>%
      group_by() %>%
      summarize(new = sum(newstu_num),
                renew = scales::percent(sum(renew_num)/sum(newstu_num), accuracy = 0.01))
    g <- cbind(region_t,d_h)
    new_d <- rbind(d,g)

    e <- newstu_renew_detail() %>%
      filter(renew_num == 1)%>%
      group_by(first_deal_ym,first_renew_ym)%>%
      summarize(renew_num = sum(renew_num))
    e_h <- newstu_renew_detail() %>%
      filter(renew_num == 1)%>%
      group_by(first_renew_ym)%>%
      summarize(renew_num = sum(renew_num))
    h <- cbind(region_t,e_h)
    new_e <- rbind(data.frame(e),data.frame(h))

    left_join(new_d,new_e,by = "first_deal_ym") %>%
      mutate(renew_rate = scales::percent(renew_num /new, accuracy = 0.01)) %>%
      select(-c(renew_num))%>%
      spread(first_renew_ym,renew_rate) %>%
      rename(c('SHOUDAN YM' = first_deal_ym, 'new student num' = new,'renew student num' = renew))%>%
      renew_dt_func()


  })

  output$renew_byss <- renderDataTable({
    d <- newstu_renew_detail() %>%
      group_by(lock_region,lock_ss_group_name,lock_ss_name) %>%
      summarize(new_num = sum(newstu_num),
                renew_num = sum(renew_num)) %>%
      left_join(
        newstu_renew_detail() %>%
          group_by(lock_ss_name) %>%
          filter(ss_name != lock_ss_name) %>%
          summarize(renew_num_t = sum(renew_num)),by = 'lock_ss_name') %>%
      mutate_all(~replace(., is.na(.), 0)) %>%
      mutate(renew_rate_t = round((renew_num - renew_num_t)/new_num *100,1)) %>%
      arrange(desc(renew_rate_t)) %>%
      rename(c('DAQU' = lock_region,'ZU' = lock_ss_group_name,'SS' = lock_ss_name, 'new student num' = new_num,'renew student num' = renew_num,'transfer student num' = renew_num_t,'renew rate(%)' = renew_rate_t)) %>%
      renew_dt_func()

    })

  output$renew_byteam <- renderDataTable({
    d <- newstu_renew_detail() %>%
      group_by(lock_region,lock_ss_group_name) %>%
      summarize(new_num = sum(newstu_num),
                renew_num = sum(renew_num)) %>%
      left_join(
        newstu_renew_detail() %>%
          group_by(lock_ss_group_name) %>%
          filter(ss_group_name != lock_ss_group_name) %>%
          summarize(renew_num_t = sum(renew_num)),by = 'lock_ss_group_name') %>%
      mutate_all(~replace(., is.na(.), 0)) %>%
      mutate(renew_rate_t = round((renew_num - renew_num_t)/new_num *100,1)) %>%
      arrange(desc(renew_rate_t)) %>%
      rename(c('DAQU' = lock_region,'ZU' = lock_ss_group_name,'new student num' = new_num,'renew student num' = renew_num,'transfer student num' = renew_num_t,'renew rate(%)' = renew_rate_t)) %>%
      renew_dt_func()
  })



  output$renew_bydgm <- renderDataTable({
    d <- newstu_renew_detail() %>%
      group_by(lock_region,lock_dgm) %>%
      summarize(new_num = sum(newstu_num),
                renew_num = sum(renew_num)) %>%
      left_join(
        newstu_renew_detail() %>%
          group_by(lock_dgm) %>%
          filter(dgm != lock_dgm & region != lock_region) %>%
          summarize(renew_num_t = sum(renew_num)),by = 'lock_dgm') %>%
      mutate_all(~replace(., is.na(.), 0)) %>%
      mutate(renew_rate_t = round((renew_num - renew_num_t)/new_num *100,1)) %>%
      arrange(desc(renew_rate_t)) %>%
      rename(c('DAQU' = lock_region,'DGM' = lock_dgm,'new student num' = new_num,'renew student num' = renew_num,'transfer student num' = renew_num_t,'renew rate(%)' = renew_rate_t)) %>%
      renew_dt_func()
  })

  output$downloaddata <- downloadHandler(
    filename = function() { paste('download', '.xlsx', sep='') },
    content = function(file) {
      write.xlsx(as.data.frame(dgm_ranking()), file,sheetName = "DGM",row.names = FALSE)
      write.xlsx(as.data.frame(tl_ranking()), file, sheetName="TL",append=TRUE,row.names = FALSE)
      write.xlsx(as.data.frame(ss_ranking()), file, sheetName="SS",append=TRUE,row.names = FALSE)

    })


  output$tx <- renderTable({
    df <- read.table("./Notes.txt", sep = "\t", header = TRUE, fileEncoding = "utf-8")
    return(df)
  })
}
