####################################
# List of National Parks
####################################
library(rvest)
library(tidyverse) # dplyr, readr, stringr
library(testthat)
if (dir.exists(here::here("data-raw")) != TRUE) {
  usethis::use_data_raw()
}

base_url <- "http://www.env.go.jp/nature/np/"

x <-
  read_html("http://www.env.go.jp/park/parks/index.html") %>%
  html_nodes(css = 'body > div.l-wrapper > div.l-main > div > div > div.p-map.p-spot-map.u-center.u-mb50 > div.inner > a')

df_np_list <-
  tibble(
    name_en = x %>%
      html_attr("href") %>%
      str_replace("../", "") %>%
      str_replace("/index.html", ""),
    name = x %>%
      html_text() %>%
      str_replace("[0-9]{0,2}", "") %>%
      str_trim()) %>%
  # nps_all.shp と合わせるために修正
  mutate(name = recode(name,
                       `霧島錦江` = "霧島錦江湾"))
expect_equal(nrow(df_np_list), 34L)

# 適宜必要な情報を追加していく
# まだdata-rawで管理。最終的にはdataでパッケージのデータとして利用可能にする
df_np_list %>%
  write_csv(here::here("data-raw/np_list.csv"))

# 陸域と海域
# 慶良間, 奄美群島, 西表石垣, やんばる, 屋久島, 霧島錦江湾, 雲仙天草,
# 西海, 足摺宇和海, 瀬戸内海, 大山隠岐, 山陰海岸, 吉野熊野, 伊勢志摩,
# 富士箱根伊豆, 三陸復興, 利尻礼文サロベツ, 知床
# ... 18

####################################
# [WIP] 指定年月日
####################################
if (file.exists("data-raw/国立_国定公園_指定年月日一覧.pdf") == FALSE) {
  download.file("https://www.env.go.jp/nature/ari_kata/shiryou/031208-3-3.pdf",
                "data-raw/国立_国定公園_指定年月日一覧.pdf")
}

df_list <-
  tabulizer::extract_tables(here::here("data-raw/国立_国定公園_指定年月日一覧.pdf"),
                                     pages = 1,
                            # listをdafa.frameにするのでmatrix
                                     output = "matrix") %>%
  as.data.frame() %>%
  mutate_all(na_if, y = "") %>%
  mutate_all(as.character)

names(df_list) <- df_list[1, ] %>% c()
df_list <-
  df_list %>%
  slice(-1L) %>%
  select(-3) %>%
  rlang::set_names(c("date", "name")) %>%
  mutate(name = str_replace(name, "\\r", "")) %>%
  tidyr::separate(col = "name", into = c("np1", "np2", "np3", "np4"),
                  sep = "・") %>%
  tidyr::gather(key = "np", "name", -date) %>%
  select(-np) %>%
  filter(!is.na(name))
