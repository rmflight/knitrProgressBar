#' multi process progress indicator
#'
#' Sets up a progress object that writes to a shared file to indicate the total
#' progress. Progress can be monitored by `watch_progress_mp`.
#'
#' @param write_location where to save progress to
#'
#' @seealso watch_progress_mp
#' @export
#' @return ProgressMP
set_progress_mp <- function(write_location = NULL){
  ProgressMP$new(write_location = write_location)
}

ProgressMP <- R6::R6Class("ProgressMP",
  inherit = Progress,
  public = list(
    write_location = NULL,
    print = function(){
      if (!is.null(self$write_location)) {
        cat(".", file = self$write_location, append = TRUE)
      } else {
        return(self)
      }
    },
    tick = function(){return(self)},

    initialize = function(write_location = NULL) {
      if (is.null(write_location)) {
        self$write_location <- tempfile(pattern = "kbp_mp_progress", fileext = ".log")
      } else {
        self$write_location <- write_location
      }
      cat("", file = self$write_location, append = FALSE)
      self$i <- 0
      self$n <- 1
    }
  )
)

#' watch progress from multi process
#'
#' sets up a "watcher" function that will report on the progress
#' of a multi-process process that is being indicated by `set_progress_mp`.
#'
#' @param n number of times process is running
#' @param min_time how long to wait
#' @param watch_location where is the progress being written to
#' @param progress_location where to write the progress output
#'
#' @seealso set_progress_mp
#' @export
#' @return ProgressMPWatcher
watch_progress_mp <- function(n, min_time = 0, watch_location = NULL,
                              progress_location = make_kpb_output_decisions()) {
  if (is.null(watch_location)) {
    stop("The watch_location must be set!")
  }
  ProgressMPWatcher$new(n = n, min_time = min_time,
                        watch_location = watch_location,
                        progress_location = progress_location)
}

ProgressMPWatcher <- R6::R6Class("ProgressMPWatcher",
  inherit = Progress,
  public = list(

    watch_location = NULL,
    #self$watch_interval = 0.5,

    initialize = function(n, min_time = 0, watch_location, progress_location) {
      self$progress_location <- progress_location
      self$n <- n
      self$min_time <- min_time

      self$watch_location <- watch_location
      #self$progress_location <- stdout()
      self$begin()
      self$tick()
    },

    tick = function(){
      if (file.exists(self$watch_location)) {
        read_dot <- scan(file = self$watch_location, what = character(), quiet = TRUE)
        if (length(read_dot) > 0) {
          n_dot <- nchar(read_dot)
          if (n_dot > self$i) {
            self$i <- n_dot
            self$print()
          } else if (n_dot == self$n) {
            self$stop()$print()
            return()
          }
        }
      }
      later::later(self$tick, 1)
    }
  )
)
