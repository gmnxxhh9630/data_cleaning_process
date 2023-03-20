library(shiny)
library(shinydashboard)


ui <- dashboardPage(
  dashboardHeader(
    title = 'SS season ranking report'),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    navbarPage(
      "SS level season ranking report",
      tabPanel("SS ranking",
               column(10,selectInput("select_dt",
                                    h5("dt select"),
                                    choices = day_list,
                                    selected = yes_day)),
               column(2,
                      downloadButton("downloaddata",'download all levels')),
               column(12,
                      h5("explanation:",style = "color:#8B0000"),),
               column(12,
                      tabsetPanel(
                        tabPanel("SS个人",dataTableOutput("ss_ranking")),
                        tabPanel("By TL",dataTableOutput("tl_ranking")),
                        tabPanel("By DGM",dataTableOutput("dgm_ranking"))))),
      tabPanel("new student renew rate",
               box(
                 width = 12,
                 column(2,pickerInput(
                   inputId = "region_range",
                   label = "region select",
                   choices = unique(choice_list$region),
                   multiple = TRUE,
                   selected = unique(choice_list$region),
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE))),
                 column(2,pickerInput(
                   inputId = "dgm_range",
                   label = "DGM select",
                   choices = unique(choice_list$dgm),
                   multiple = TRUE,
                   selected = unique(choice_list$dgm),
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE))),
                 column(2,pickerInput(
                   inputId = "team_range",
                   label = "Team select",
                   choices = unique(choice_list$ss_group_name),
                   multiple = TRUE,
                   selected = unique(choice_list$ss_group_name),
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE)))),
               tabsetPanel(
                 tabPanel("cohort_renew rate",
                          dataTableOutput("renew_cohort"),
                          br(),
                          dataTableOutput("renew_cohort_rate")),
                 tabPanel("By SS",dataTableOutput("renew_byss")),
                 tabPanel("By Team",dataTableOutput("renew_byteam")),
                 tabPanel("By DGM",dataTableOutput("renew_bydgm"))
                 )),
      tabPanel(title = 'Notes',
               h5("If any question,please contact xxx ",style = "color:red"),
               img(src = "guize.png", height = 300, width = 700),
               tableOutput("tx"))
    )

  )
)
