context("kpb")

run_pb <- function(){
  n_iter <- 5
  pb <- progress_estimated(n_iter)
  tmp <- purrr::map(seq(1, n_iter), function(x){
    pb$tick()
    pb$print()
    Sys.sleep(0.1)
  })
}

test_that("regular progress works", {
  with_mock(
    is_interactive = function() TRUE,
    is_in_knitr = function() FALSE,

    {
      pb <- progress_estimated(5)
      withr::with_output_sink("test_pb.txt",
                run_pb())
      expect_match(paste(suppressMessages(readLines("test_pb.txt", warn = FALSE)), collapse = ""), "|========================================================================================================|100% ~0 s remaining")
    }

  )
})
