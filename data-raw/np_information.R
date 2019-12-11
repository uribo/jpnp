####################################
# List of National Parks
####################################
library(rvest)
library(tidyverse) # dplyr, readr, stringr
library(assertr)
if (dir.exists("data-raw") != TRUE)
  usethis::use_data_raw()
if (file.exists("data-raw/np_list.csv") == FALSE) {
  x <-
    read_html("http://www.env.go.jp/park/parks/index.html")
  np_information <-
    seq.int(7) %>%
    purrr::map_dfr(
      ~ tibble::tibble(
        id = x %>%
          html_nodes(css = glue::glue("#cont-accordion-{.x} > ul > li > div > div.c-number")) %>%
          html_text() %>%
          stringr::str_pad(width = 2, pad = "0"),
        name = x %>%
          html_nodes(css = glue::glue("#cont-accordion-{.x} > ul > li > a > span.item-bottom > span.name")) %>%
          html_text(),
        region = x %>%
          html_nodes(css = glue::glue("#ttl-accordion-{.x} > a")) %>%
          html_text(),
        registered = x %>%
          html_nodes(css = glue::glue("#cont-accordion-{.x} > ul > li > ul > li.data__date")) %>%
          html_text() %>%
          stringr::str_remove(".+：") %>%
          stringr::str_remove("（.+）") %>%
          lubridate::as_date(),
        area = x %>%
          html_nodes(css = glue::glue("#cont-accordion-{.x} > ul > li > ul > li.data__area")) %>%
          html_text() %>%
          stringr::str_remove(".+："),
        prefecture = x %>%
          html_nodes(css = glue::glue("#cont-accordion-{.x} > ul > li > ul > li.data__region")) %>%
          html_text(),
        url = x %>%
          html_nodes(css = glue::glue("#cont-accordion-{.x} > ul > li > a")) %>%
          html_attr("href") %>%
          xml2::url_absolute(base = "https://www.env.go.jp/park/parks") %>%
          stringr::str_replace("https://www.env.go.jp/", "https://www.env.go.jp/park/")
      )) %>%
    verify(dim(.) == c(36, 7)) %>%
    mutate(area = recode(name,
                         `瀬戸内海国立公園` = "近畿地区, 中国四国地区, 九州地区",
                         .default = area)) %>%
    distinct(id, .keep_all = TRUE) %>%
    verify(dim(.) == c(34, 7)) %>%
    arrange(id) %>%
    mutate(name = stringr::str_remove(name, "国立公園"),
           name_en = purrr::pmap_chr(.,
                                     ~ ..7 %>%
                                       stringr::str_replace("/park", "/en/nature/nps/park") %>%
                                       read_html() %>%
                                       html_nodes(css = "h1") %>%
                                       html_text(trim = TRUE) %>%
                                       stringr::str_remove("National Park") %>%
                                       stringr::str_trim()),
           name_en_short = stringr::str_remove(url,
                                "https://www.env.go.jp/park/") %>%
             stringr::str_remove("/index.html") %>%
             stringr::str_to_title())
  np_information <-
    np_information %>%
    select(id, name, name_en, name_en_short, region, registered, area, prefecture, url) %>%
    tidyr::separate_rows(prefecture, sep = "\u30fb") %>%
    group_by(name) %>%
    tidyr::nest(prefs = c(prefecture)) %>%
    ungroup() %>%
    verify(dim(.) == c(34, 9))
  np_information %>%
    tidyr::unnest(cols = prefs) %>%
    verify(nrow(.) == 82L)
  unique(np_information$name_en_short)
  usethis::use_data(np_information, overwrite = TRUE)
}
