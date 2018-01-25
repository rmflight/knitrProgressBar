knitrProgressBar
----------------

This package supplies a progress bar (shamelessly borrowed from `dplyr::progress_estimated`) that has options to **not** have output captured inside a `knitr` chunk.

### Installation

To install this package, use `devtools`:

    devtools::install_github("rmflight/knitrProgressBar")

Problem
-------

You want to use `knitr` or `rmarkdown`, but you want to see the progress of a longer running calculation in the chunk. You think that you can just use `dplyr::progress_estimated`. But if you do, all the output from the progress bar will be suppressed ([by design, actually](https://github.com/tidyverse/dplyr/blob/master/R/progress.R#L96)).

Solution
--------

This package has one function, `progress_estimated`, that allows you to redirect the output from the progress bar, either to the `R` terminal (`stdout`, the default), to `stderr`, so the output stays in the terminal while `knitr` is running, or to a file, so you can use `tailf` or something similar on the command line to watch the progress in the file, or occasionally open the file to see progress.

Example Usage
-------------

None of these are run in this document.

### Setup

``` r
library(knitrProgressBar)
arduously_long_nchar <- function(input_var, .pb=NULL) {
  
  if ((!is.null(.pb)) && inherits(.pb, "Progress") && (.pb$i < .pb$n)) .pb$tick()$print()
  
  Sys.sleep(0.5)
  
  nchar(input_var)
  
}
```

### Normal Progress to stdout

Useful to use these progress bars in the `R` terminal itself. Will show up in a `knit`ted document, but not in a terminal running `knitr` or `rmarkdown::render`.

``` r
pb <- progress_estimated(length(letters))

purrr::map_int(letters, arduously_long_nchar, .pb = pb)
```

### Progress to stderr

This will use `stderr()` to view the progress bar in the `R` terminal when running from `knitr` or `rmarkdown::render`.

``` r
pb <- progress_estimated(length(letters), write_location = stderr())

purrr::map_int(letters, arduously_long_nchar, .pb = pb)
```

### Progress to file

This will use a file to keep track of the progress.

``` r
pb <- progress_estimated(length(letters), write_location = "test.log")

purrr::map_int(letters, arduously_long_nchar, .pb = pb)
```

### No Progress

If you want to keep the progress function call, but want to suppress the output completely, use `NULL` instead.

``` r
pb <- progress_estimated(length(letters), write_location = NULL)

purrr::map_int(letters, arduously_long_nchar, .pb = pb)
```

License
-------

This package is licensed under an MIT license.

Code of Conduct
---------------

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.