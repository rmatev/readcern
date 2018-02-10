.convertTimeFromMS <- function(x) as.numeric(x)/1e3
.convertTimeFromLocal <- function(x) as.numeric(as.POSIXct(x, tz=''))
.convertTimeFromUTC <- function(x) as.numeric(as.POSIXct(x, tz='UTC'))

#' Read a csv file produced by TIMBER or the Java Export CLI
#'
#' @param file Anything accepted by [read_lines()] or an xrootd URL.
#' @param variables A vector of variables to read (if NULL, read all).
#' @param pattern Filter array variables based on regular expression.
#' @return A list of data frames.
#' @export
#' @examples
#' read_acclogging_csv(readcern_example('Summary_4691_B1.HYB.CSV.gz'))
#' read_acclogging_csv(readcern_example('Summary_4691_B1.HYB.CSV.gz'),
#'                     variables=c('BSRL.B1.HYB.Q_sat_bunched'))
read_acclogging_csv <- function(file, variables=NULL, pattern=NULL) {
  file <- standardise_path(file)
  lines <- read_lines(file)

  # find the first and last line of each variable
  i1 <- grep('^VARIABLE: ', lines)
  i2 <- c(i1[1:length(i1)] - 1, length(lines))[-1]
  # extract names of variables and filter only requested ones
  sections <- data_frame(
    i1 = i1, i2 = i2,
    variable = make.names(stringr::str_match(lines[i1], '^VARIABLE: (.+)$')[,2])
  )
  if (!is.null(variables))
    sections <- filter(sections, variable %in% variables)
  # read the variables (into a list of dataframes)
  lists <- sections %>%
    group_by(variable) %>%
    do(x=read_acclogging_var(lines[.$i1:.$i2], pattern)) %>%
    `[[`('x')
  names(lists) <- NULL
  do.call(c, lists)
}


read_acclogging_var <- function(lines, pattern=NULL) {
  i <- max(grep('^([^[:digit:]]|$)', lines[1:min(100, length(lines))]))
  if (i == length(lines))  # no data points
    return(data_frame())

  meta <- parse_acclogging_metadata(lines[1:i], lines[i+1])
  text <- paste(lines[(i+1):length(lines)], collapse='\n')  # read.csv can get directly lines, but it is VERY slow
  data <- read.csv(text=text, header=FALSE, stringsAsFactors=FALSE)

  names(data)[1] <- 'time'
  data[,1] <- meta$cnvtime(data[,1])

  if (!meta$isarray) {
    names(data) <- c('time', 'value')
    return(setNames(list(as_data_frame(data)), meta$name))
  }
  else {
    idx <- if (is.null(pattern)) 1:(ncol(data)-1) else grep(pattern, meta$colnames)
    vlist <- lapply(idx, function(i) data_frame(time=data[,1], value=data[,i+1]))
    names(vlist) <- paste(meta$name, meta$colnames[idx], sep='.')
    return(vlist)
  }

}

parse_acclogging_metadata <- function(metaLines, dataLine1) {
  # Fix buggy output for array (vector) variables (after Nov'15 update)
  # TODO report to the relevant people
  if (any(metaLines == 'DataType: VECTORNUMERIC') && !any(grepl('Timestamp.*Array Values', metaLines))) {
    enames <- na.omit(stringr::str_extract(metaLines, 'Element Names.*'))
    timefmt <- na.omit(stringr::str_extract(metaLines, 'Timestamp \\(([^\\)]+)\\)'))
    header <- paste(timefmt, 'Array Values', sep = ',')
    metaLines[grep('Timestamp', metaLines):length(metaLines)] <- c(enames, header)
  }

  dataLine1 <- strsplit(dataLine1, ',')[[1]]
  varname <- make.names(stringr::str_match(metaLines[1], '^VARIABLE: (.+)$')[2])
  header <- stringr::str_match(metaLines[length(metaLines)], '^Timestamp \\(([^\\)]+)\\),(.+)$')
  timefmt <- header[2]
  valname <- header[3]  # name of value column(s)
  isarray <- valname == 'Array Values'

  cnvtime <- list(
    'UNIX Format'=.convertTimeFromMS,
    'LOCAL_TIME'=.convertTimeFromLocal,
    'UTC_TIME'=.convertTimeFromUTC
  )[[timefmt]]

  if (isarray) {
    x <- metaLines[grep('^Element Names Valid Since ', metaLines)]
    if (length(x) == 0) {
      colnames <- as.character(c(1:(length(dataLine1)-1)))
    } else {
      x <- stringr::str_match(x, '^Element Names Valid Since ([0-9\\-]+ [0-9:\\.]+) \\(UTC_TIME\\):,(.+)$')
      i <- findInterval(cnvtime(dataLine1[1]), as.numeric(as.POSIXct(x[,2], tz='UTC')))
      colnames <- strsplit(x[i,3], ',')[[1]]
    }
  } else {
    colnames <- 'value'
  }

  list(name=varname, cnvtime=cnvtime, isarray=isarray, colnames=colnames)
}

