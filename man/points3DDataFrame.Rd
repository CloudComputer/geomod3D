% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/points3DDataFrame.R
\name{points3DDataFrame}
\alias{points3DDataFrame}
\title{3D point cloud with attributes}
\usage{
points3DDataFrame(coords, df)
}
\arguments{
\item{coords}{A list, matrix, or data frame containing the 3D coordinates
of the points.}

\item{df}{A data frame with the points' attributes}
}
\description{
3D point cloud with attributes
}
\details{
If \code{coords} is a matrix or data frame with less than 3
columns, the missing coordinates are given a value of 0.
}
\seealso{
\code{\link{spatial3DDataFrame-class}},
\code{\link{points3DDataFrame-class}}
}
