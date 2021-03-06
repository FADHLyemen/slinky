% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/slinky_gctx.R
\docType{methods}
\name{readGCTX}
\alias{readGCTX}
\alias{readGCTX,Slinky-method}
\alias{readGCTX}
\title{readGCTX}
\usage{
readGCTX(x)

\S4method{readGCTX}{Slinky}(x)
}
\arguments{
\item{x}{a Slinky Object}
}
\value{
Matrix of expression data with rownames and
   colnames appropriately set. If a subset of the data is desired, 
   subset the slinky object itself, not the resulting data matrix. 
   That is, \code{data <- readGCTX(x[1:50,1:500])} will be 
   MUCH faster than \code{ndata <- readGCTX(x)[1:50, 1:500]}.
}
\description{
Read portions of data matrix from LINCS gctx datafile
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
data <- readGCTX(sl[1:20,1:5])

}
