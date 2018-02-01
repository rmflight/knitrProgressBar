#' updating progress bars
#'
#' Takes care of updating a progress bar and stopping when appropriate
#'
#' @param .pb the progress bar object
#'
#' @export
#' @return the progress bar
update_progress <- function(.pb = NULL) {
  if ((!is.null(.pb)) && inherits(.pb, "Progress") && (.pb$i < .pb$n)) .pb$tick()$print()

  if ((!is.null(.pb)) && inherits(.pb, "Progress") && (.pb$i == .pb$n)) .pb$stop()$print()

  .pb
}