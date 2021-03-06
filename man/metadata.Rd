% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/slinky_info.R
\docType{methods}
\name{metadata}
\alias{metadata}
\alias{metadata,Slinky-method}
\title{metadata}
\usage{
metadata(x)

\S4method{metadata}{Slinky}(x)
}
\arguments{
\item{x}{a Slinky object}
}
\value{
The accessor function returns a \code{data.frame} 
containing the metadata.
}
\description{
The accessor function retrieves metadata from Slinky object.
}
\examples{
# for build/demo only.  You MUST use your own key when using the slinky
# package.
user_key <- httr::content(httr::GET('https://api.clue.io/temp_api_key'),
                          as='parsed')$user_key
sl <- Slinky(user_key,
                 system.file('extdata', 'demo.gctx',
                      package='slinky'),
                 system.file('extdata', 'demo_inst_info.txt',
                     package = 'slinky'))
md <- metadata(sl[, 1:10])

}
