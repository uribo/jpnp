#' @title Browse national park web page
#' @param np national park name.
#' Regular expressions and partial matches are valid.
#' @examples
#' \dontrun{
#' browse_np("Shiretoko")
#' browse_np("Daisetsu")
#' }
#' @export
browse_np <- function(np) {
  id <- name <- name_en <- NULL
  url <-
    np_information %>%
    dplyr::select(id, name, name_en, url) %>%
    tidyr::pivot_longer(cols = c(name, name_en),
                        names_to = "var",
                        values_to = "name") %>%
    dplyr::filter(stringr::str_detect(name, np)) %>%
    dplyr::pull(url)
  utils::browseURL(url)
}

#' @title Convert sfencode to sf
#' @param x sfencode
#' @rdname sfencode_as_sf
#' @examples
#' sfencode_as_sf(np)
#' @export
sfencode_as_sf <- function(x) {
  geometry <- NULL
  googlePolylines::polyline_wkt(x) %>%
    dplyr::mutate(geometry = sf::st_as_sfc(geometry)) %>%
    sf::st_sf(crs = 4326)
}

utils::globalVariables(c("np_information"))
