% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R, R/Allaccessors.R
\docType{methods}
\name{Parameter-methods}
\alias{Parameter-methods}
\alias{Parameter,MeripBamFileList-method}
\alias{Parameter}
\title{Method Parameter}
\usage{
Parameter(x)

\S4method{Parameter}{MeripBamFileList}(x)
}
\arguments{
\item{x}{a \code{MeripBamFileList} object.}
}
\value{
a list for the additional parameters of the MeRIP-seq experiment.
}
\description{
Method Parameter

Accessor to the slot \code{Parameter} in class \code{MeripBamFileList}.
}
\examples{
GENE_ANNO_GTF = system.file("extdata", "example.gtf", package="exomePeak2")

f1 = system.file("extdata", "IP1.bam", package="exomePeak2")
f2 = system.file("extdata", "IP2.bam", package="exomePeak2")
f3 = system.file("extdata", "IP3.bam", package="exomePeak2")
f4 = system.file("extdata", "IP4.bam", package="exomePeak2")
IP_BAM = c(f1,f2,f3,f4)
f1 = system.file("extdata", "Input1.bam", package="exomePeak2")
f2 = system.file("extdata", "Input2.bam", package="exomePeak2")
f3 = system.file("extdata", "Input3.bam", package="exomePeak2")
INPUT_BAM = c(f1,f2,f3)

f1 = system.file("extdata", "treated_IP1.bam", package="exomePeak2")
TREATED_IP_BAM = c(f1)
f1 = system.file("extdata", "treated_Input1.bam", package="exomePeak2")
TREATED_INPUT_BAM = c(f1)

MeRIP_Seq_Alignment <- scanMeripBAM(
  bam_ip = IP_BAM,
  bam_input = INPUT_BAM,
  paired_end = FALSE
)

Parameter(MeRIP_Seq_Alignment)

}
