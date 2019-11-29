####################################
# Update: 2019-11-29
# 環境性生物多様性センターが配布している
# 国立公園区域等のshapefile (http://gis.biodic.go.jp/webgis/sc-026.html?kind=nps)
# アンケートに答えてダウンロード
# kmlならアンケート回答不要だし1ファイルで済むがst_readで読み込めない
####################################
# source("data/np_information.R") np_information
pkgload::load_all()
library(sf)
library(dplyr)
library(testthat)
library(googlePolylines)

sf_np <-
  st_read("data-raw/nps/nps_all.shp",
          as_tibble = TRUE,
          stringsAsFactors = FALSE) %>%
  st_transform(crs = 4326) %>%
  purrr::set_names(c("name", "area", "geometry"))
expect_equal(dim(sf_np), c(8789, 3))
expect_equal(sf_np$name %>% n_distinct(), 35L) # あとで34に修正
expect_equal(sf_np$area %>% n_distinct(), 7L)
expect_equal(format(object.size(sf_np), units = "Mb"),
             "54.9 Mb")

# Modified ----------------------------------------------------------------
# nameから34公園で区分できるように「編集」
expect_length(
  unique(sf_np$name)[!unique(sf_np$name) %in% np_information$name],
  2L
)
sf_np_modified <-
  sf_np %>%
  mutate(name = recode(name,
                       `奄美大島` = "奄美群島",
                       `利尻例文サロベツ` = "利尻礼文サロベツ"
                       ))

expect_length(
  unique(sf_np_modified$name)[!unique(sf_np_modified$name) %in% np_information$name],
  0
)
# 公園、保護区の区分ごとに一つのポリゴンにマージ
np <-
  sf_np_modified %>%
  mutate(area = forcats::fct_relevel(area,
                                     "普通地域",
                                     "特別保護地区",
                                     "第1種特別地域",
                                     "第2種特別地域",
                                     "第3種特別地域",
                                     "海域公園地区",
                                     "区分未定")) %>%
  lwgeom::st_make_valid() %>%
  group_by(name, area) %>%
  summarise() %>%
  ungroup() %>%
  left_join(np_information %>%
              select(id, name, name_en),
            by = "name") %>%
  arrange(id, area) %>%
  select(id, name, name_en, area)
expect_equal(format(object.size(np), units = "Mb"),
             "49.3 Mb")
fix_id <-
  stringr::str_which(st_geometry_type(np), "GEOMETRYCOLLECTION")
np <-
  np[-c(fix_id), ] %>%
  rbind(
    np[c(fix_id), ] %>%
      st_collection_extract("POLYGON") %>%
      group_by(id, name, name_en, area) %>%
      summarise() %>%
      ungroup()
  ) %>%
  arrange(id, area) %>%
  select(-id) %>%
  mutate(area = as.character(area))
np <-
  seq.int(nrow(np)) %>%
  purrr::map(
    ~ encode(np[.x, ])) %>%
  purrr::reduce(rbind)
expect_equal(format(object.size(np), units = "Mb"),
             "8.6 Mb")
expect_equal(dim(np), c(183, 4))
usethis::use_data(np, overwrite = TRUE, compress = "xz")
