#' @title read and tidy up national park visitor data
#' @inheritParams readxl::read_excel
tidy_np_visitor <- function(path, range, col_names) {
  . <- park <- NULL
  readxl::read_xls(path,
           sheet = 1,
           range = range,
           col_names = col_names) %>%
    tidyr::fill(park, .direction = "down") %>%
    dplyr::mutate(park = gsub("\u203b", "", park)) %>%
    dplyr::mutate(park = dplyr::recode(
      park,
      "\u5229\u5c3b\u793c\u6587" = "\u5229\u5c3b\u793c\u6587\u30b5\u30ed\u30d9\u30c4",
      "\u30b5\u30ed\u30d9\u30c4" = "\u5229\u5c3b\u793c\u6587\u30b5\u30ed\u30d9\u30c4",
      "\u4e09\u9678\u5fa9\u8208\n\uff08\u9678\u4e2d\u6d77\u5cb8\uff09" = "\u4e09\u9678\u5fa9\u8208",
      "\u9727\u5cf6\u9326\u6c5f\u6e7e\n\uff08\u9727\u5cf6\u5c4b\u4e45\uff09" = "\u9727\u5cf6\u9326\u6c5f\u6e7e"
    )) %>%
    dplyr::slice(seq.int(2, nrow(.), by = 2)) %>%
    dplyr::mutate_at(dplyr::vars(tidyselect::starts_with("y")),
                     gsub,
                     pattern = "\u203b",
                     replacement = "") %>%
    readr::type_convert(col_types = readr::cols(park = readr::col_character(),
                                                .default = readr::col_integer())) %>%
    dplyr::mutate_at(dplyr::vars(tidyselect::starts_with("y")),
                     dplyr::na_if,
                     y = "\u2014") %>%
    tidyr::pivot_longer(tidyselect::starts_with("y"),
                        names_to = "year",
                        values_to = "count",
                        names_prefix = "y",
                        names_ptypes = list(year = character()))
}