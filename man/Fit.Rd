% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generics.R, R/GP.R, R/GP_geomod.R, R/SPGP.R,
%   R/SPGP_geomod.R
\docType{methods}
\name{Fit}
\alias{Fit}
\alias{Fit,GP-method}
\alias{Fit,GP_geomod-method}
\alias{Fit,SPGP-method}
\alias{Fit,SPGP_geomod-method}
\title{Fit}
\usage{
Fit(object, ...)

\S4method{Fit}{GP}(object, contribution = T, nugget = T, nugget.t = F,
  maxrange = T, midrange = F, minrange = F, azimuth = F, dip = F,
  rake = F, power = F, ...)

\S4method{Fit}{GP_geomod}(object, contribution = T, nugget = T,
  maxrange = T, midrange = F, minrange = F, azimuth = F, dip = F,
  rake = F, power = F, ...)

\S4method{Fit}{SPGP}(object, contribution = F, maxrange = F, midrange = F,
  minrange = F, azimuth = F, dip = F, rake = F, pseudo_inputs = F,
  pseudo_tangents = F, power = F, nugget = F, metric = c("logLik",
  "PLPD", "NRMSE"), ...)

\S4method{Fit}{SPGP_geomod}(object, contribution = T, nugget = T,
  maxrange = T, midrange = F, minrange = F, azimuth = F, dip = F,
  rake = F, power = F, pseudo_inputs = F, pseudo_tangents = F, ...)
}
\arguments{
\item{...}{Arguments passed on to \code{\link{ga}}, such as \code{maxiter},
\code{popSize}, etc.}

\item{contribution}{Optimize on the covariance model's amplitude?}

\item{nugget}{Optimize on nugget?}

\item{maxrange}{Optimize on the covariance model's range?}

\item{midrange, minrange}{Optimize on the covariance model's anisotropy?}

\item{azimuth, dip, rake}{Optimize on the covariance model's orientation?}

\item{power}{Optimize on the power parameter (not relevant for all
covariances)?}

\item{pseudo_inputs}{Optimize on the pseudo-inputs' locations?}

\item{pseudo_tangents}{Optimize on the pseudo-inputs' locations for
derivative data?}

\item{metric}{Which metric to optimize?}
}
\value{
A \code{GP} object similar to \code{object}, with optimized
covariance parameters.
}
\description{
Training of a Gaussian Process model with a genetic algorithm.
}
\details{
This method uses a genetic algorithm to optimize the contribution
(or amplitude) and range of each covariance structure contained in the
\code{model} slot of \code{object}, as well as the parameters above, if
allowed.

Optimization is done with respect to the specified metric. The available
metrics are the log-likelihood (default), normalized root mean square error
(NRMSE), and penalized log predictive density (PLPD). The latter two are
determined by leave-one-out cross validation, which is slower than the
log-likelihood.

The positions of the pseudo-inputs may be constrained to match a subset of
the data (\code{pseudo_inputs = "subset"}) or be free to lie anywhere
inside the data`s bounding box (\code{pseudo_inputs = "free"}). The
pseudo-tangents, however, must be a subset of the tangent data to avoid
overfitting, as the tangents have a greater degree of freedom (position and
direction).

See the documentation in \code{\link{ga}} to control the optimization
process. Standard GP uses continuous optimization to fit the parameters,
using the current ones as a starting point. The sparse GP uses discrete
optimization (with binary encoding) to fit the parameters and select the
best positions for the pseudo-inputs. In both cases, it is
recommnded to set the \code{popSize} around 20 and
\code{pmutation} between 0.3 and 0.5. Convergence status can be visualized by
setting \code{monitor = T}.

The variational SPGP model may pose difficulties for training. It may help
to train a FIC model (or a standard GP, using a subset of the data)
to obtain the best covariance
parameters and nugget and use them to build a variational SPGP object.

In order to obtain reproducible results, set the seed before calling this
method.
}
\references{
Bauer, M.S., van der Wilk, M., Rasmussen, C.E., 2016. Understanding
Probabilistic Sparse Gaussian Process Approximations. Adv. Neural Inf.
Process. Syst. 29.
}
\seealso{
\code{\link{covarianceStructure3D-class}},
\code{\link{GP-init}}, \code{\link{SPGP-init}}
}
