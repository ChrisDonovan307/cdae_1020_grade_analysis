#' print time
#' 2024-05-14
#' 
#' Convenience function to formart output of Sys.time. No packages needed.

print_time <- function(msg = 'Starting at') {
  cat(
    '\n',
    msg, 
    ' ',
    format(Sys.time(), '%X'),
    '\n',
    sep = ''
  )
}

