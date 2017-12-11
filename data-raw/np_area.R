####################################
# 環境性生物多様性センターが配布している
# 国立公園区域等のshapefile
# アンケートに答えてダウンロード
####################################
library(sf)
library(dplyr)
library(testthat)
library(ggplot2) # 2.2.1.9000

sf_np <- st_read("data-raw/nps/nps_1.shp") %>%
  rlang::set_names(c("name", "area", "geometry"))
expect_equal(dim(sf_np), c(8849, 3))

sf_np$name %>% n_distinct() # 34 より多い
sf_np$name %>% unique()

# Modified ----------------------------------------------------------------
# nameから34公園で区分できるように「編集」
# 編集なのでデータの出典明記を変更する必要あり
df_np <- readr::read_csv("data-raw/np_list.csv")

sf_np_modified <- sf_np %>%
  mutate(name = stringr::str_replace(name, "\\（.+?\\）", "")) %>%
  mutate(name = recode(name,
                       `屋久島・乗り入れ規制` = "屋久島",
                       `屋久島・乗入れ規制地` = "屋久島",
                       `阿蘇くじゅう（阿蘇地` = "阿蘇くじゅう",
                       `やんばる国立公園` = "やんばる",
                       `石西礁湖・西表島・鳩間島周辺` = "西表石垣",
                       `石西礁湖` = "西表石垣",
                       `鳩間島・西表島` = "西表石垣",
                       `石垣地域` = "西表石垣",
                       `西表地域` = "西表石垣",
                       `嘉弥間島` = "西表石垣",
                       `新城島` = "西表石垣",
                       `鳩間島` = "西表石垣",
                       `仲御神島` = "西表石垣",
                       `竹富島` = "西表石垣",
                       `小浜島` = "西表石垣",
                       `黒島` = "西表石垣",
                       `波照間島` = "西表石垣",
                       `利尻例文サロベツ` = "利尻礼文サロベツ",
                       `阿寒` = "阿寒摩周"
                       ))

expect_equal(
  unique(sf_np_modified$name)[!unique(sf_np_modified$name) %in% df_np$name],
  character(0)
)

sf_np_union <- sf_np_modified %>%
  split(.$name) %>%
  purrr::map(~ st_buffer(.x, dist = 0.0001) %>%
               st_union() %>%
               st_simplify(preserveTopology = TRUE, dTolerance = 0.0005)) %>%
  purrr::reduce(c) %>%
  as_tibble() %>%
  st_sf()
sf_np_union$name <- sort(unique(sf_np_modified$name))

# mapの過程でやるとサイズが合わなくなる...
names(sf_np_union) <- c("geometry", "name")

# library(leaflet)
# leaflet() %>% addTiles() %>% addPolygons(data = sf_np_union %>%
#                                            filter(name == "阿寒摩周"))
# なぜかもう一度... WKTが維持されないので、呼び出しごにsf::st_sf()を実行する必要がある
np <- sf_np_union %>%
  as_tibble() %>%
  st_sf()
devtools::use_data(np, overwrite = TRUE, compress = "xz")
