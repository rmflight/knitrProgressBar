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
      if (is.null(write_locaiton)) {
        self$write_location <- tempfile(pattern = "kbp_mp_progress", fileext = "log")
      }
    }
  )
)

ProgressMPSub <- R6::R6Class("ProgressMPWatcher",
  inherit = Progress,
  public = list(

    self$watch_location = NULL,
    self$watch_interval = 0.5,

    initialize = function(n, min_time = 0, watch_location) {
      self$progress_location <- progress_location
      self$n <- n
      self$min_time <- min_time

      self$watch_location <- watch_location
      self$progress_location <- stdout()
      self$begin()
      self$watch()
    },

    watch = function(){
      while (self$i < self$n) {
        Sys.sleep(self$watch_interval)
        read_dot <- scan(file = self$watch_location, what = character(), quiet = TRUE)
        n_dot <- nchar(read_dot)
        if (n_dot > self$i) {
          self$i <- n_dot
          self$print()
        }
      }
    }
  )
)