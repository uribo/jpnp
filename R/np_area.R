#' Inside of National Park Meshes
#'
#' @param df data frame (national park polygon)
#' @param mesh_size Which mesh size to output. Supports 10 and 1km.
#' @importFrom dplyr filter select pull
#' @importFrom jpmesh export_meshes fine_separate
#' @importFrom purrr map pmap set_names flatten_chr
#' @importFrom sf st_intersects st_sf
#' @importFrom tibble tibble
#' @examples
#' \dontrun{
#' data(np, package = "np")
#' np[11, ] %>% np_area_meshed(mesh_size = 10)
#' }
#' @aliases np_area_meshed
#' @export
np_area_meshed <- function(df, mesh_size = c(1, 10)) {
  id <- meshcode <- res_contains <- NULL
  df_tmp <-
    tibble::tibble(res_contains = suppressMessages(sf::st_intersects(jpmesh::sf_jpmesh,
                                                                     df,
                                                                             sparse = FALSE,
                                                                             prepared = TRUE)) %>%
                             as.numeric())
  df_tmp$id <- seq_len(nrow(df_tmp))
  meshes <-
    jpmesh::sf_jpmesh[df_tmp %>%
                        dplyr::filter(res_contains == 1) %>%
                        dplyr::pull(id) %>% unique(), ] %>%
    dplyr::pull(meshcode) %>%
    purrr::map(jpmesh::fine_separate) %>%
    purrr::flatten_chr() %>%
    unique()
  if (mesh_size == 1) {
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
                                                                     df)) %>%
                             as.numeric())
  df_tmp$id <- seq_len(nrow(df_tmp))
  sf_prefmesh[df_tmp %>%
                  dplyr::filter(!is.na(res_contains)) %>%
                  dplyr::pull(id) %>%
                       unique(), ] %>%
    dplyr::select(meshcode)
}