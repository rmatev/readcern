#' Read a file produced by PVSSExport.
#'
#' This is a simple wrapper around [read_csv()]. Columns are renamed
#' and times are converted to UNIX timestamps.
#'
#' @param file Anything accepted by [read_csv()] or an xrootd URL.
#' @return A data frame.
#' @seealso [read_csv()].
#' @export
#' @examples
#' read_pvss_export(readcern_example('pvss.csv'))
#' read_pvss_export('root://eosuser.cern.ch//eos/user/r/rmatev/readcern/pvss.csv')
read_pvss_export <- function(file) {
  file <- standardise_path(file)
  data <- read_csv(file, col_types = cols(
    DPE = col_character(),
    TS = col_datetime(format = "%d-%m-%Y %H:%M:%OS"), #, tz=locale(tz="CET")), #TODO: choose correct timezone here
    VALUE = col_character()
  )) %>% dplyr::rename(time = 'TS', variable = 'DPE', value = 'VALUE')
  data %>% dplyr::mutate(time = as.numeric(.data$time))
}
