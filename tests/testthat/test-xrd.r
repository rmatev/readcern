library(readcern)
context("xrd")

test_that("xrd_command works", {
  url <- 'root://eosuser.cern.ch//eos/user/r/rmatev/readcern/pvss.gz?params'
  expect_equal(xrd_command(url), sprintf('xrdcp --silent "%s" - | gzip -cd', url))
})

test_that("xrd connection works", {
  url <- 'root://eosuser.cern.ch//eos/user/r/rmatev/readcern/README'
  contents = "This directory contains files used in the tests of readcern R package.

This is the third line.
"
  expect_equal(readr::read_file(xrd(url)), contents)
  expect_equal(readr::read_file(xrd(paste0(url, '.gz'))), contents)
  expect_equal(readr::read_file(xrd(paste0(url, '.bz2'))), contents)
  expect_equal(readr::read_file(xrd(paste0(url, '.xz'))), contents)
})
