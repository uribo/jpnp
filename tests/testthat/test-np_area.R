context("test-np_area.R")

test_that("national park meshes", {
  res <-
    np[1, ] %>%
    np_area_meshed(mesh_size = 10)
  expect_s3_class(res, "sf")
  expect_equal(dim(res), c(21, 2))
  expect_named(res,
               c("meshcode", "geometry"))
  res <-
    np[9, ] %>%
    np_area_meshed(mesh_size = 1)
  expect_s3_class(res, "data.frame")
  expect_equal(dim(res), c(77, 2))
})
