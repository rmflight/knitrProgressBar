
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/knitrProgressBar)](https://cran.r-project.org/package=knitrProgressBar) [![Build Status](https://travis-ci.org/rmflight/knitrProgressBar.svg?branch=master)](https://travis-ci.org/rmflight/knitrProgressBar) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/rmflight/knitrProgressBar?branch=master&svg=true)](https://ci.appveyor.com/project/rmflight/knitrProgressBar) [![Coverage Status](https://img.shields.io/codecov/c/github/rmflight/knitrProgressBar/master.svg)](https://codecov.io/github/rmflight/knitrProgressBar?branch=master)

knitrProgressBar
----------------

[This package](https://rmflight.github.io/knitrProgressBar) supplies a progress bar (shamelessly borrowed from `dplyr::progress_estimated`) that has options to **not** have output captured inside a `knitr` chunk.

### Installation

This package can be installed from CRAN by:

    install.packages("knitrProgressBar")

To install the development version of this package, use `devtools`:

    devtools::install_github("rmflight/knitrProgressBar")

Problem
-------

You want to use `knitr` or `rmarkdown`, but you want to see the progress of a longer running calculation in the chunk. You think that you can just use `dplyr::progress_estimated`. But if you do, all the output from the progress bar will be suppressed ([by design, actually](https://github.com/tidyverse/dplyr/blob/master/R/progress.R#L96)).

Solution
--------

This package has two functions, `progress_estimated`, that creates a `Progress` object that has a connection object associated with it, and `update_progress`, that properly updates the progress object. The output from the progress will be written to **that** connection. This connection will be either `stdout` (default within an R session), `stderr` (default from within `knitr`), or to a log-file.

Examples
--------

None of these are run in this document!

### Setup

``` r
library(knitrProgressBar)

# borrowed from example by @hrbrmstr
arduously_long_nchar <- function(input_var, .pb=NULL) {
  
  update_progress(.pb)
  
  Sys.sleep(0.5)
  
  nchar(input_var)
  
}
```

### Let Function Decide

If you want the object to decide where to put output, do nothing. Just call the `progress_estimated()` function, which uses `make_kpb_output_decisions()`:

``` r
pb <- progress_estimated(length(letters))

purrr::map_int(letters, arduously_long_nchar, .pb = pb)
```

See the help and the vignette for an explanation of how `make_kpb_output_decisions()` decides where to display the progress bar output.

### Write to Specific Connection

If you want to write the progress out to a specific connection, just pass the connection to the `progress_estimated()` call:

``` r
pb <- progress_estimated(length(letters), progress_location = stdout())

purrr::map_int(letters, arduously_long_nchar, .pb = pb)
```

This includes specific files. You can then display the file, or use `tailf` or equivalent to watch the output of the file.

``` r
pb <- progress_estimated(length(letters), progress_location = file("progress.log", open = "w"))

purrr::map_int(letters, arduously_long_nchar, .pb = pb)
```

Connection Considerations
-------------------------

Each connection will display in specific situations, notably `stdout()` will not display to the terminal when run as part of a document being `knit`ted.

Inspiration
-----------

This package (and the examples) was inspired by [this post](https://rud.is/b/2017/03/27/all-in-on-r%E2%81%B4-progress-bars-on-first-post/) from Bob Rudis! Also, thanks to Hadley Wickham for the great `Progress` object and methods!

Website
-------

Web accessible documentation is available [here](https://rmflight.github.io/knitrProgressBar).

Bug Reports
-----------

Please submit bug reports using the GitHub [issue tracker](https://github.com/rmflight/knitrProgressBar/issues).

Code of Conduct
---------------

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

License
-------

This package is licensed using an [MIT license](LICENSE.md), copyright Robert M Flight.
