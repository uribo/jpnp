####################################
# Update: 2019-06-05
# 環境性生物多様性センターが配布している
# 国立公園区域等のshapefile (http://gis.biodic.go.jp/webgis/sc-026.html?kind=nps)
# アンケートに答えてダウンロード
# kmlならアンケート回答不要だし1ファイルで済むがst_readで読み込めない
####################################
library(sf)
library(dplyr)
library(testthat)
library(ggplot2)

sf_np <-
  st_read(here::here("data-raw/nps/nps_all.shp"), as_tibble = TRUE) %>%
  st_transform(crs = 4326) %>%
  purrr::set_names(c("name", "area", "geometry"))
expect_equal(dim(sf_np), c(8789, 3))
expect_equal(sf_np$name %>% n_distinct(), 35L) # あとで34に修正
expect_equal(sf_np$area %>% n_distinct(), 7L)

# Modified ----------------------------------------------------------------
# nameから34公園で区分できるように「編集」
# source(here::here("data-raw/np_information.R"))
df_np <-
  readr::read_csv(here::here("data-raw/np_list.csv")) %>%
  tibble::rowid_to_column()

expect_length(
  unique(sf_np$name)[!unique(sf_np$name) %in% df_np$name],
  2L
)
sf_np_modified <-
  sf_np %>%
  mutate(name = recode(name,
                       `奄美大島` = "奄美群島",
                       `利尻例文サロベツ` = "利尻礼文サロベツ"
                       ))

expect_length(
  unique(sf_np_modified$name)[!unique(sf_np_modified$name) %in% df_np$name],
  0
)
# 公園、保護区の区分ごとに一つのポリゴンにマージ
np <-
  sf_np_modified %>%
  group_by(name, area) %>%
  summarise() %>%
  ungroup() %>%
  left_join(df_np, by = "name") %>%
  arrange(rowid, area) %>%
  mutate(name_en = stringr::str_to_title(name_en)) %>%
  select(name, name_en, area)

# library(leaflet)
# leaflet() %>% addTiles() %>% addPolygons(data = np %>%
#                                            filter(name == "阿寒摩周"))
expect_equal(dim(np), c(183, 4))
usethis::use_data(np, overwrite = TRUE, compress = "xz")
