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
    use_logfile <- all_options$kpb.suppress_noninteractive
  }

  if (!is_interactive && is_in_knitr() && !suppress_noninteractive && !use_logfile) {
    return(stderr())
  }

  if (!is_interactive && !is_in_knitr() && !suppress_noninteractive && !use_logfile) {
    return(stdout())
  }

  if (!is_interactive && !suppress_noninteractive) {
    return(NULL)
  }

  if (is_interactive && is_in_knitr() && !use_logfile) {
    return(stderr())
  }
  if (is_interactive && !is_in_knitr() && !use_logfile) {
    return(stdout())
  }
  if (use_logfile) {
    log_connection <- set_logfile(all_options)

    file_loc <- unlist(summary.connection(log_connection))["description"]
    log_message <- paste0("\nProgress is being logged in: ", file_loc)

    if (is_in_knitr()) {
      message_con <- stderr()
      cat(log_message, file = message_con)
    } else {
      message_con <- stdout()
      cat(log_message, file = message_con)
    }
    return(log_connection)
  }
}

# defining our own version of `interactive` so we can mock it in the tests
is_interactive <- function() {interactive()}

is_in_knitr <- function() {
  isTRUE(getOption("knitr.in.progress"))
}

set_logfile <- function(all_options) {
  if (!is.null(all_options$kpb.log_file)) {
    logfile <- file(all_options$kpb.log_file, open = "w")
    class(logfile) <- "kpblogfile"
    return(logfile)
  }

  if (is_in_knitr() && !is.null(all_options$kpb.log_pattern)) {
    chunk_label <- knitr::opts_current$get()$label
    logfile <- file(paste0("chunk_", chunk_label, ".log"), open = "w")
    class(logfile) <- "kpblogfile"
    return(logfile)
  }

  logfile <- file("kpb_output.log", open = "w")
  class(logfile) <- "kpblogfile"
  logfile

}

