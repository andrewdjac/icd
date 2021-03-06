% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/datadocs.R
\name{icd10_sub_chapters}
\alias{icd10_sub_chapters}
\title{ICD-10 sub-chapters}
\format{list with sub-chapter or major names stored in list names, each with
  two element named character vector with start and end codes.}
\source{
http://apps.who.int/classifications/icd10/browse/2016/en
}
\description{
The WHO ICD-10 scheme sub-chapters. N.b. there may be WHO vs CM differences:
please file bug if noted. In the \code{XML} definition of ICD-10-CM there are
some intermediate hierarchical levels, e.g. for neoplasms. Sub-chapter here
is defined as the lowest-level grouping of three-digit codes, e.g. C00-C14
"Malignant neoplasms of lip, oral cavity and pharynx", not C00-C96 "Malignant
neoplasms" which itself is a subset of the chapter C00-D49 "Neoplasms"
}
