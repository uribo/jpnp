context("test-np_area.R")

test_that("national park geometry", {
  expect_s3_class(
    np,
    "sfencoded"
  )
  expect_equal(
    dim(np),
    c(183, 4)
  )
})

test_that("national park meshes", {
  np <-
    np %>%
    sfencode_as_sf()
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
