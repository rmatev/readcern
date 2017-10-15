#' Open an xrootd connection.
#'
#' `xrd()` returns a pipe, while `xrd_command()` returns the command
#' with which an xrootd url is piped.
#'
#' @param url URL starting with `root://`.
#' @param decompress Whether to automatically decompress files.
#' @return A connection or the command to be given to [pipe()].
#' @export
#' @examples
#' xrd('root://eosuser.cern.ch//eos/user/r/rmatev/readcern/README')
#' xrd_command('root://eosuser.cern.ch//eos/user/r/rmatev/readcern/README')
xrd <- function(url, decompress = TRUE) {
  pipe(xrd_command(url, decompress = decompress))
}

#' @rdname xrd
#' @export
xrd_command <- function(url, decompress = TRUE) {
  stopifnot(length(url) == 1)
  stopifnot(is_xrd(url))
  cmd <- sprintf('xrdcp --silent "%s" -', url)
  if (decompress) {
    ext <- tools::file_ext(strsplit(url, '?', fixed = TRUE)[[1]][1])
    unzip <- list('gz' = 'gzip -cd', 'bz2' = 'bzip2 -cd', 'xz'= 'xz -cd')[[ext]]
    if (!is.null(unzip))
      cmd <- paste(cmd, '|', unzip)
  }
  cmd
}

is_xrd <- function(url) {
  grepl("^root://", url)
}

standardise_path <- function(path) {
  if (is.character(path) && is_xrd(path) && !grepl("\\n", path)) {
    return(xrd(path))
  }
  path
}
