
library(testthat)

context("Testing hello function")
#unit test

test_that("Whether output is as expected", {
  res = hello("John")
  expect_equal(res, "Hello, John")
})
