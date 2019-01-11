#' Inside of National Park Meshes
#'
#' @param d data (national park polygon)
#' @param mesh_size Which mesh size to output. Supports 10km and 1km.
#'
#' @importFrom dplyr filter select pull
#' @importFrom jpmesh export_meshes fine_separate
#' @importFrom purrr map pmap set_names flatten_chr
#' @importFrom sf st_intersects st_sf
#' @importFrom tibble tibble
#' @examples
#' \dontrun{
#' data(np, package = "np")
#' np[11, ] %>% np_area_meshed(mesh_size = "10km")
#' }
#' @aliases np_area_meshed
#' @export
np_area_meshed <- function(d, mesh_size = c("10km", "1km")) {

  id <- meshcode <- res_contains <- NULL

  df_tmp <-
    tibble::tibble(res_contains = suppressMessages(sf::st_intersects(jpmesh::sf_jpmesh,
                                                                             d,
                                                                             sparse = FALSE,
                                                                             prepared = TRUE)) %>%
                             as.numeric())
  df_tmp$id <- 1:nrow(df_tmp)

  meshes <-
    jpmesh::sf_jpmesh[df_tmp %>%
                        dplyr::filter(res_contains == 1) %>%
                        dplyr::pull(id) %>% unique(), ] %>%
    dplyr::pull(meshcode) %>%
    purrr::map(jpmesh::fine_separate) %>%
    purrr::flatten_chr() %>%
    unique()

  if (mesh_size == "1km") {
    # 10km -> 1km mesh
    meshes <-
      meshes %>%
      purrr::map(jpmesh::fine_separate) %>%
      purrr::flatten_chr()
  }

  sf_prefmesh <-
    meshes %>%
    jpmesh::export_meshes()

  df_tmp <-
    tibble::tibble(res_contains = suppressMessages(sf::st_intersects(sf_prefmesh,
                                                                     d)) %>%
                             as.numeric())

  df_tmp$id <- 1:nrow(df_tmp)
  res <-
    sf_prefmesh[df_tmp %>%
                  dplyr::filter(!is.na(res_contains)) %>%
                  dplyr::pull(id) %>%
                       unique(), ] %>%
    dplyr::select(meshcode)

  return(res)
}