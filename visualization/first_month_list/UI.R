library(shiny)
library(shinydashboard)
library(shinyWidgets)

dashboard_box_size <-  "3"

ui <- dashboardPage(
  header <- dashboardHeader(title = "SS first month service"),
  siderbar <- dashboardSidebar(disable = TRUE),
  body <- dashboardBody(
    navbarPage(
      "SS first month service",
      tabPanel(
        title = "Daily report",
        fluidRow(
          tabBox(
            width = 12,
            tabPanel(
              status = "primary",
              title = "firstcall48h",
              plotlyOutput("shoutong_rate_f", height = "250px")),
            tabPanel(
              status = "primary",
              title = "firstlesson",
              plotlyOutput("shouke_rate", height = "250px")))),
        fluidRow(
          column(12,
                 box(
                   width = "6 col-lg-12",
                   status = "info",
                   title = "Team TOP 10",
                   tags$div(
                     class = "scroll-overflow-x",
                    uiOutput("top_team")),
                  helpText("explanation："))))),
      tabPanel(
        title = "level table",
        box(
          width = 12,
          column(3,
               pickerInput(
                 inputId = "region_input",
                 label = "district select",
                 choices = select_region_list_r,
                 multiple = TRUE,
                 selected = select_region_list_r,
                 options = pickerOptions(
                   selectedTextFormat = 'count',
                   actionsBox = TRUE))),
          column(3,
               pickerInput(
                 inputId = "qudao_input",
                 label = "stu channel",
                 choices = c('MKT','REF','both'),
                 multiple = TRUE,
                 selected = c('MKT','REF','both'),
                 options = pickerOptions(
                   selectedTextFormat = 'count',
                   actionsBox = TRUE))),
          input_date_range(inputId = "date_range_dt", width = 3)),
        tabsetPanel(
          tabPanel("by region",
                   dataTableOutput("user_region")),
          tabPanel("user detail",
                   dataTableOutput("user_detail")))),
      tabPanel(
        title = 'duration',
        column(2,
               pickerInput(
                 inputId = "select_ym_r",
                 label = "duration_month",
                 choices = choice_ym,
                 multiple = TRUE,
                 selected = choice_ym,
                 options = pickerOptions(
                   selectedTextFormat = 'count',
                   actionsBox = TRUE))),
        column(2,
               pickerInput(
                 inputId = "region_input_r",
                 label = "region select",
                 choices = select_region_list_r,
                 multiple = TRUE,
                 selected = select_region_list_r,
                 options = pickerOptions(
                   selectedTextFormat = 'count',
                   actionsBox = TRUE))),
        box(
          width = 12,
          status = "info",
          tags$div(
            class = "scroll-overflow-x",
            column(6,plotlyOutput("byym_shoutong_f")))),
        box(
          width = 12,
          status = "info",
          tags$div(
            class = "scroll-overflow-x",
            column(6,plotlyOutput("byym_shouke"))))),


      tabPanel("Notes",
               h5("If any question,please contact xxx ",style = "color:red"),
               tableOutput("tx")))))
