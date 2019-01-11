# context("test-np_area.R")
#
# test_that("national park meshes", {
#
#   data(np, package = "jpnp")
#   res <- np[1, ] %>% sf::st_transform(crs = 4326) %>% np_area_meshed(mesh_size = "10km")
#   expect_s3_class(res, "sf")
#   expect_equal(dim(res), c(10, 2))
#   expect_named(res,
#                c("meshcode", "geometry"))
#   expect_equal(res %>% sf::st_bbox() %>% as.vector(),
#                c(128.00000, 26.58333, 128.37500, 26.91667))
#
#
#   res <- np[9, ] %>% sf::st_transform(crs = 4326) %>% np_area_meshed(mesh_size = "1km")
#   expect_s3_class(res, "data.frame")
#   expect_equal(dim(res), c(894, 2))
#   expect_equal(res %>% sf::st_bbox() %>% as.vector(),
#                c(127.15000, 26.06667, 127.66250, 26.33333))
#
# })
