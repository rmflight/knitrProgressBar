% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/decision_logic.R
\name{make_kpb_output_decisions}
\alias{make_kpb_output_decisions}
\title{Progress Output Location}
\usage{
make_kpb_output_decisions()
}
\value{
a write-able connection or NULL
}
\description{
Provides functionality to decide \strong{how} the progress should be written,
if at all.
}
\details{
This function makes decisions about \strong{how} the progress bar should be displayed
based on whether:
\enumerate{
\item The code is being run in an interactive session or not
\item The code is part of a \code{knitr} evaluation using \code{knit()} or \code{rmarkdown::render()}
\item Options set by the user. These options include:
\enumerate{
\item \strong{kpb.suppress_noninteractive}: a logical value. Whether to suppress output
when being run non-interactively.
\item \strong{kpb.use_logfile}: logical, should a log-file be used for output?
\item \strong{kpb.log_file}: character string defining the log-file to use. \strong{kpb.use_logfile} must be \code{TRUE}.
\item \strong{kpb.log_pattern}: character string providing a pattern to use, will be combined with the chunk
label to create a log-file for each knitr chunk. \strong{kpb.use_logfile} must be \code{TRUE}.
}
}

Based on these, it will either return a newly opened connection, either via
\code{stderr()}, \code{stdout()}, or a file connection via \code{file("logfile.log", open = "w")}.
Note that for files this will overwrite a previously existing file, and the contents
will be lost.
}
\examples{
\dontrun{
# suppress output when not interactive
options(kpb.suppress_noninteractive = TRUE)

# use a log-file, will default to kpb_output.txt
options(kpb.use_logfile = TRUE)

# use a specific log-file
options(kpb.use_logfile = TRUE)
options(kpb.log_file = "progress.txt")

# use a log-file based on chunk names
options(kpb.use_logfile = TRUE)
options(kpb.log_pattern = "pb_out_")
# for a document with a chunk labeled: "longcalc", this will generate "pb_out_longcalc.log"
}

}
