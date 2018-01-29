#' decision logic
#'
#' Provides functionality to decide **how** the progress should be written,
#' if at all.
#'
#' @details
#'
#' This function makes decisions about **how** the progress bar should be displayed
#' based on whether:
#'
#' 1. The code is being run in an interactive session or not
#' 1. The code is part of a `knitr` evaluation using `knit()` or `rmarkdown::render()`
#' 1. Options set by the user. These options include:
#'     1. **kpb.suppress_noninteractive**: a logical value. Whether to suppress output
#'   when being run non-interactively.
#'     1. **kpb.use_logfile**: logical, should a log-file be used for output?
#'     1. **kpb.log_file**: character string defining the log-file to use. **kpb.use_logfile** must be `TRUE`.
#'     1. **kpb.log_pattern**: character string providing a pattern to use, will be combined with the chunk
#'   label to create a log-file for each knitr chunk. **kpb.use_logfile** must be `TRUE`.
#'
#' @examples
#' \dontrun{
#' # suppress output when not interactive
#' options(kpb.suppress_noninteractive = TRUE)
#'
#' # use a log-file, will default to kpb_output.txt
#' options(kpb.use_logfile = TRUE)
#'
#' # use a specific log-file
#' options(kpb.use_logfile = TRUE)
#' options(kpb.log_file = "progress.txt")
#'
#' # use a log-file based on chunk names
#' options(kpb.use_logfile = TRUE)
#' options(kpb.log_pattern = "pb_out_")
#' # for a document with a chunk labeled: "longcalc", this will generate "pb_out_longcalc.log"
#' }
#'
#' @export
#'
#' @return a connection or NULL
make_kpb_output_decisions <- function(){

  all_options <- options()
  if (is.null(all_options$kpb.suppress_noninteractive)) {
    suppress_noninteractive <- FALSE
  } else {
    suppress_noninteractive <- all_options$kpb.suppress_noninteractive
  }

  if (is.null(all_options$kpb.use_logfile)) {
    use_logfile <- FALSE
  } else {
    use_logfile <- all_options$kpb.use_logfile
  }

  # dont worry about suppressing a non-interactive session or using log-files first

  # use stderr to see progress if we are in knitr and not use a log-file
  if (is_interactive() && is_in_knitr() && !suppress_noninteractive) {
    pb_connection <- stderr()
  } else if (!is_interactive() && is_in_knitr() && !suppress_noninteractive) {
    # regardless of whether interactive or not, because knitr suppresses the output to stdout
    pb_connection <- stderr()
  } else if (is_interactive() && !is_in_knitr() && !suppress_noninteractive) {
    # however, we can use stdout as soon as we are not in knitr itself
    pb_connection <- stdout()
  } else if (!is_interactive() && !is_in_knitr() && !suppress_noninteractive) {
    pb_connection <- stdout()
  } else if (!is_interactive() && !is_in_knitr() && suppress_noninteractive) {
    # now address suppressing non-interactive
    pb_connection <- NULL
  } else if (!is_interactive() && is_in_knitr() && suppress_noninteractive) {
    # now address suppressing non-interactive
    pb_connection <- NULL
  }

  if (use_logfile) {
    log_connection <- set_logfile(all_options)

    if (!is.null(pb_connection)) {
      log_message <- paste0("\nProgress is being logged in: ",
                            get_con_description(log_connection), "\n")
      cat(log_message, file = pb_connection)
    }
    # replace the progress bar connection with our new one, b/c we are pushing
    # it to the log file
    pb_connection <- log_connection
  }

  pb_connection
}

#' connection description
#'
#' @param con a connection object
#'
#' @export
#' @return character string
get_con_description <- function(con){
  unlist(summary.connection(con))["description"]
}

# defining our own version of `interactive` so we can mock it in the tests
is_interactive <- function() {interactive()}

is_in_knitr <- function() {
  isTRUE(getOption("knitr.in.progress"))
}

get_chunk_label <- function() {
  if (is_in_knitr()){
    out_label <- knitr::opts_current$get()$label
  } else {
    out_label <- ""
  }
  out_label
}

set_logfile <- function(all_options) {
  if (!is.null(all_options$kpb.log_file)) {
    logfile <- file(all_options$kpb.log_file, open = "w")
    class(logfile) <- "kpblogfile"
    return(logfile)
  }

  if (is_in_knitr() && !is.null(all_options$kpb.log_pattern)) {
    chunk_label <- get_chunk_label()
    logfile <- file(paste0(all_options$kpb.log_pattern, chunk_label, ".log"), open = "w")
    class(logfile) <- "kpblogfile"
    return(logfile)
  }

  logfile <- file("kpb_output.log", open = "w")
  class(logfile) <- "kpblogfile"
  logfile

}

