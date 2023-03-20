
options(digits = 1)

summarize_func <- function(dat){
  mutate(dat,
         stu_num = 1) %>%
    summarize(stunum = sum(stu_num),
              point_num = sum(point_count_num),
              zhengjia_point_num = sum(zhengjia_point),
              hm_num = sum(hm_count_num),
              avg_point_num = round(mean(point_count_num),0),
              avg_hm_num = round(mean(hm_count_num),0),
              hm_lesson = sum(hm_end),
              avg_point_end = round(mean(point_end),0),
              avg_hm_end = round(mean(hm_end),0))


}


dt_func <- function(dat) {
  rename(dat,c("student num" = stunum,"point count" = point_num,"zhengjia count" = zhengjia_point_num,
           "AVG 1v1 count" = avg_point_num,"AVG hm count" = avg_hm_num,
           "AVG_1v1 end" = avg_point_end,"AVG_hm end" = avg_hm_end)) %>%
  datatable(extensions = "Buttons",
            options = list(
              buttons = c('excel'),
              dom = 'Bfrtip',
              pageLength = nrow(dat),
              rowCallback = JS(
                "function(row, data) {",
                "var num = data[3].toString().replace(/\\B(?=(\\d{3})+(?!\\d))/g, ',');",
                "$('td:eq(3)', row).html(num);",
                "}"),
              columnDefs = list(
                list(className = 'dt-center',
                     targets = '_all'))
            ))
}
