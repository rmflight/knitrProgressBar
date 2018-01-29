#' decision logic
#'
#' Provides functionality to decide **where** the progress should be written,
#' if at all.
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
  knitr::opts_current$get()$label
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

