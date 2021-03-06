% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R, R/estimateSeqDepth.R
\docType{methods}
\name{estimateSeqDepth-methods}
\alias{estimateSeqDepth-methods}
\alias{estimateSeqDepth,SummarizedExomePeak-method}
\alias{estimateSeqDepth}
\title{Method estimateSeqDepth}
\usage{
estimateSeqDepth(sep, from = c("Background", "Modification", "All"), ...)

\S4method{estimateSeqDepth}{SummarizedExomePeak}(sep,
  from = c("Background", "Modification", "All"), ...)
}
\arguments{
\item{sep}{a \code{\link{SummarizedExomePeak}} object.}

\item{from}{a \code{character} specify the subset of features for sequencing depth estimation, can be one of \code{c("Background", "Modification", "All")}.

\describe{
 \item{\strong{\code{Background}}}{
 The sequencing depths are estimated from the background control regions. This method could make the IP/input LFC estimates become closer to the true modification proportion.
 }

 \item{\strong{\code{Modification}}}{
 The sequencing depths are estimated from the modification peaks/sites.
 }

 \item{\strong{\code{All}}}{
 The sequencing depths are estimated from both the background and the modification regions.
 }
}

Under the default settings, the sequencing depth size factors are estimated from the background control regions.}

\item{...}{inherited from \code{\link{estimateSizeFactorsForMatrix}}.}
}
\value{
This function will return a \code{\link{SummarizedExomePeak}} object containing newly estimated sequencing depth size factors.
}
\description{
\code{estimateSeqDepth} estimate sequencing depth size factors for each MeRIP-seq samples used in peak statistics quantification.
Under default setting, the sequencing depth are estimated by the robust estimator defined in package \code{DESeq}.
i.e. the median of the ratios to the geometric means of peak counts.
}
\details{
The function takes the input of a \code{\link{SummarizedExomePeak}} object,
and it estimates the sequencing depth size factors by the columns of its \link{assay}.
}
\examples{

### Load the example SummarizedExomPeak object
f1 = system.file("extdata", "sep_ex_mod.rds", package="exomePeak2")

sep <- readRDS(f1)

### Estimate the sequencing depth size factors
sep <- estimateSeqDepth(sep)

sep$sizeFactor

}
\seealso{
\code{\link{normalizeGC}}
}
