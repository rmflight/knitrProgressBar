# The original source for much of this came from Hadley Wickham's dplyr
# code in github.com/tidyverse/dplyr/R/progress.R

#' Progress bar with estimated time.
#'
#' This provides a eference class representing a text progress bar that displays the
#' estimaged time remaining. When finished, it displays the total duration.  The
#' automatic progress bar can be disabled by setting `progress_location = NULL`.
#'
#' @param n Total number of items
#' @param min_time Progress bar will wait until at least `min_time`
#'   seconds have elapsed before displaying any results.
#' @param progress_location where to write the progress to. Default is to make
#' decisions based on location type using `make_kpb_output_decisions()`.
#'
#' @seealso [make_kpb_output_decisions()]
#'
#' @return A ref class with methods `tick()`, `print()`,
#'   `pause()`, and `stop()`.
#' @export
#' @examples
#' p <- progress_estimated(3)
#' p$tick()
#' p$tick()
#' p$tick()
#'
#' p <- progress_estimated(3)
#' for (i in 1:3) p$pause(0.1)$tick()$print()
#'
#' p <- progress_estimated(3)
#' p$tick()$print()$
#'  pause(1)$stop()
#'
#' # If min_time is set, progress bar not shown until that many
#' # seconds have elapsed
#' p <- progress_estimated(3, min_time = 3)
#' for (i in 1:3) p$pause(0.1)$tick()$print()
#'
#' \dontrun{
#' p <- progress_estimated(10, min_time = 3)
#' for (i in 1:10) p$pause(0.5)$tick()$print()
#'
#' # output to stderr
#' p <- progress_estimated(10, progress_location = stderr())
#'
#' # output to a file
#' p <- progress_estimated(10, progress_location = tempfile(fileext = ".log"))
#' }
progress_estimated <- function(n, min_time = 0, progress_location = make_kpb_output_decisions()) {
  Progress$new(n, min_time = min_time, progress_location = progress_location)
}

#' @importFrom R6 R6Class
Progress <- R6::R6Class("Progress",
  public = list(
    n = NULL,
    i = 0,
    init_time = NULL,
    stopped = FALSE,
    stop_time = NULL,
    min_time = NULL,
    last_update = NULL,
    progress_location = NULL,

    initialize = function(n, min_time = 0, progress_location, ...) {
      self$progress_location <- progress_location
      self$n <- n
      self$min_time <- min_time
      self$begin()
    },

    begin = function() {
      "Initialise timer. Call this before beginning timing."
      self$i <- 0
      self$last_update <- self$init_time <- now()
      self$stopped <- FALSE
      self
    },

    pause = function(x) {
      "Sleep for x seconds. Useful for testing."
      Sys.sleep(x)
      self
    },

    width = function() {
      getOption("width") - nchar("|100% ~ 99.9 h remaining") - 2
    },

    tick = function() {
      "Process one element"
      if (self$stopped) return(self)

      if (self$i == self$n) abort("No more ticks")
      self$i <- self$i + 1
      self
    },

    stop = function() {
      if (self$stopped) return(self)

      self$stopped <- TRUE
      self$stop_time <- now()
      self
    },

    print = function(...) {
      if (is.null(self$progress_location)) {
        return(invisible(self))
      }

      now_ <- now()
      if (now_ - self$init_time < self$min_time || now_ - self$last_update < 0.05) {
        return(invisible(self))
      }
      self$last_update <- now_

      if (self$stopped) {
        overall <- show_time(self$stop_time - self$init_time)
        if (self$i == self$n) {
          cat_line(file = self$progress_location, "Completed after ", overall)
          cat("\n")
        } else {
          cat_line("Killed after ", overall)
          cat("\n")
        }
        return(invisible(self))
      }

      avg <- (now() - self$init_time) / self$i
      time_left <- (self$n - self$i) * avg
      nbars <- trunc(self$i / self$n * self$width())

      cat_line(file = self$progress_location,
        "|", str_rep("=", nbars), str_rep(" ", self$width() - nbars), "|",
        format(round(self$i / self$n * 100), width = 3), "% ",
        "~", show_time(time_left), " remaining"
      )

      invisible(self)
    }

  )
)

cat_line <- function(file = NULL, ...) {
  msg <- paste(..., sep = "", collapse = "")
  gap <- max(c(0, getOption("width") - nchar(msg, "width")))
  cat("\r", msg, rep.int(" ", gap), sep = "", file = file, append = TRUE)
  utils::flush.console()
}

str_rep <- function(x, i) {
  paste(rep.int(x, i), collapse = "")
}

show_time <- function(x) {
  if (x < 60) {
    paste(round(x), "s")
  } else if (x < 60 * 60) {
    paste(round(x / 60), "m")
  } else {
    paste(round(x / (60 * 60)), "h")
  }
}

now <- function() proc.time()[[3]]