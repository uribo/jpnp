####################################
# 環境性生物多様性センターが配布している
# 国立公園区域等のshapefile
# アンケートに答えてダウンロード
####################################
library(sf)
library(dplyr)
library(testthat)
library(ggplot2) # 2.2.1.9000

sf_np <-
  st_read(here::here("data-raw/nps_all/nps_all.shp"), as_tibble = TRUE) %>%
  st_transform(crs = 4326) %>%
  rlang::set_names(c("name", "area", "geometry"))
expect_equal(dim(sf_np), c(8789, 3))
expect_equal(sf_np$name %>% n_distinct(), 35L)

# Modified ----------------------------------------------------------------
# nameから34公園で区分できるように「編集」
# 編集なのでデータの出典明記を変更する必要あり
# source(here::here("data-raw/np_information.R"))
df_np <-
  readr::read_csv(here::here("data-raw/np_list.csv"))

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
# 公園ごとに一つのポリゴン (保護区でわけない)
sf_np_union <-
  sf_np_modified %>%
  split(.$name) %>%
  purrr::map(~ st_buffer(.x, dist = 0.0001) %>%
               st_union() %>%
               st_simplify(preserveTopology = TRUE, dTolerance = 0.0005)) %>%
  purrr::reduce(c) %>%
  as_tibble() %>%
  st_sf()
sf_np_union$name <-
  sort(unique(sf_np_modified$name))

# mapの過程でやるとサイズが合わなくなる...
names(sf_np_union) <- c("geometry", "name")

# library(leaflet)
# leaflet() %>% addTiles() %>% addPolygons(data = sf_np_union %>%
#                                            filter(name == "阿寒摩周"))
# なぜかもう一度... WKTが維持されないので、呼び出しごにsf::st_sf()を実行する必要がある
np <-
  sf_np_union %>%
  select(name, geometry) %>%
  tibble::new_tibble(subclass = "sf")
expect_equal(dim(np), c(34, 2))
usethis::use_data(np, overwrite = TRUE, compress = "xz")
