#' Read columnar data at CERN.
#'
#' This is a utility package for reading columnar file formats found
#' at CERN. It provides support for reading over the XRootD protocol.
#'
#' @import readr
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
"_PACKAGE"

#' Get path to readcern example
#'
#' readcern comes bundled with a number of sample files in its inst/extdata
#' directory. This function make them easy to access.
#'
#' @param path Name of file.
#' @export
#' @examples
#' readcern_example('pvss.csv')
readcern_example <- function(path) {
  system.file("extdata", path, package = "readcern", mustWork = TRUE)
}
