% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/valid.R
\name{re_just}
\alias{re_just}
\alias{re_just_ws}
\alias{re_wrap_or}
\title{Limit a regular expression to just what is given}
\usage{
re_just(x, whitespace_ok = FALSE)

re_just_ws(x)

re_wrap_or(x)
}
\arguments{
\item{x}{single string containing a regular expression}

\item{whitespace_ok}{Single logical, if \code{TRUE}, the default, matches for
ICD codes will accept leading and trailing white space.}
}
\description{
update regular expression to limit by start and end, with or without white
space
}
\section{Functions}{
\itemize{
\item \code{re_just_ws}: allow white space

\item \code{re_wrap_or}: contain any \code{|} options within a regular expression,
e.g. ICD-9 codes without \code{^} or \code{$}.
}}

\keyword{internal}
