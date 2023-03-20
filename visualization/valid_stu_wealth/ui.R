library(shinydashboard)


ui <- dashboardPage(
  header <- dashboardHeader(disable = TRUE),
  siderbar <- dashboardSidebar(disable = TRUE),
  body <- dashboardBody(

    navbarPage(
      "Valid student",
      tabPanel(
        title = "student wealth",
        box(
          width = 12,
          column(2,
                 pickerInput(
                   inputId = "stu_occup",
                   label = "student attribute",
                   choices = stu_occup_list,
                   multiple = TRUE,
                   selected = stu_occup_list,
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE))),
          column(2,
                 pickerInput(
                   inputId = "valid_end",
                   label = "expired time",
                   choices = valid_range_list,
                   multiple = TRUE,
                   selected = valid_range_list,
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE))),
          column(2,
                 pickerInput(
                   inputId = "point_count",
                   label = "count",
                   choices = count_range_list,
                   multiple = TRUE,
                   selected = count_range_list,
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE))),
          column(2,
                 pickerInput(
                   inputId = "business_type",
                   label = "business type",
                   choices = c('b2b','b2c','b2s'),
                   multiple = TRUE,
                   selected = c('b2b','b2c','b2s'),
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE))),
          column(2,
                 pickerInput(
                   inputId = "is_hm",
                   label = "is hm",
                   choices = c('0','1'),
                   multiple = TRUE,
                   selected = c('0','1'),
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE))),
          column(2,
                 pickerInput(
                   inputId = "is_overseas",
                   label = "is overseas",
                   choices = overseas_list,
                   multiple = TRUE,
                   selected = overseas_list,
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE))),
          column(2,
                 pickerInput(
                   inputId = "is_zhengjia",
                   label = "is zhengjia",
                   choices = is_zhengjia_list,
                   multiple = TRUE,
                   selected = is_zhengjia_list,
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE))),
          column(2,
                 pickerInput(
                   inputId = "is_zhengjia_disable",
                   label = "is zhengjia disable",
                   choices = is_zhengjia_disable_list,
                   multiple = TRUE,
                   selected = is_zhengjia_disable_list,
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE))),
          column(2,
                 pickerInput(
                   inputId = "province_select",
                   label = "province",
                   choices = unique(province_list$province),
                   multiple = TRUE,
                   selected = unique(province_list$province),
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE))),
          column(2,
                 pickerInput(
                   inputId = "city_select",
                   label = "city",
                   choices = unique(city_list$city),
                   multiple = TRUE,
                   selected = unique(city_list$city),
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE)))
        ),
        dataTableOutput("valid_range"),
        dataTableOutput("point_range"),
        dataTableOutput("is_overseas"),
        dataTableOutput("occup_range"),
        dataTableOutput("city")
      ),
      tabPanel(
        title = "trend",
        box(
          width = 12,
          column(2,
                 pickerInput(
                   inputId = "ym_select",
                   label = "month",
                   choices = choice_ym,
                   multiple = TRUE,
                   selected = choice_ym,
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE))),
          column(2,
                 pickerInput(
                   inputId = "stu_occup_sec",
                   label = "student attribute",
                   choices = stu_occup_list,
                   multiple = TRUE,
                   selected = stu_occup_list,
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE))),
          column(2,
                 pickerInput(
                   inputId = "valid_end_sec",
                   label = "expired time",
                   choices = valid_range_list,
                   multiple = TRUE,
                   selected = valid_range_list,
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE))),
          column(2,
                 pickerInput(
                   inputId = "point_count_sec",
                   label = "point count",
                   choices = count_range_list,
                   multiple = TRUE,
                   selected = count_range_list,
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE))),
          column(2,
                 pickerInput(
                   inputId = "business_type_sec",
                   label = "business type",
                   choices = c('b2b','b2c','b2s'),
                   multiple = TRUE,
                   selected = c('b2b','b2c','b2s'),
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE))),
          column(2,
                 pickerInput(
                   inputId = "is_hm_sec",
                   label = "is hm",
                   choices = c('0','1'),
                   multiple = TRUE,
                   selected = c('0','1'),
                   options = pickerOptions(
                     selectedTextFormat = 'count',
                     actionsBox = TRUE))),
          box(
            width = 12,
            status = "info",
            tags$div(
              class = "scroll-overflow-x",
              column(12,plotlyOutput("byym_hm_count")))),
          box(
            width = 12,
            status = "info",
            tags$div(
              class = "scroll-overflow-x",
              column(12,plotlyOutput("byym_point_count")))),
          box(
            width = 12,
            status = "info",
            tags$div(
              class = "scroll-overflow-x",
              column(12,plotlyOutput("byym_hm_count_avg")))),
          box(
            width = 12,
            status = "info",
            tags$div(
              class = "scroll-overflow-x",
              column(12,plotlyOutput("byym_point_count_avg"))))
        ),
      )
    )
  )
)
