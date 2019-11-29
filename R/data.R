#' @title Japanese National Park Area Dataset
#' @description Japan National Park Spatial Data.
#' @docType data
#' @return \item{np}{a sf. The espg (SRID) is 4326. Combine into single polygon for each park and protection zone area category, namely MULTIPOLYGON.}
#' @format A `sf` object contains 183 rows 2 variables:
#' \itemize{
#'   \item{name}
#'   \item{name_en}
#'   \item{area}
#'   \item{geometry}
#' }
#' @source Natural Environmental Information GIS (Biodiversity Center of Japan, Ministry of the Environment.)
#'
#' \url{http://gis.biodic.go.jp/webgis/sc-026.html?kind=nps}
#'
#' This data is modified from GIS data that national park area by Shinya Uryu.
#' @details
#' National Parks represent outstanding natural landscapes of Japan. The park lands are designated
#' and managed by the Country (MOE) in accordance with the Natural Parks Law.
#' As of February 2018, 34 areas have been designated as the National Parks.
#' The data includes names and classification attributes such as Special Protection Zones,
#' Class I Special Zones, etc. Please see \url{https://www.env.go.jp/en/nature/nps/park/} the description of each zone.
#' @examples
#' np
#' @keywords datasets
"np"

#' @title Japanese National Park Information
#' @description Japan National Park Data.
#' @docType data
#' @examples
#' np_information
"np_information"