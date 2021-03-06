# Copyright (C) 2014 - 2017  Jack O. Wasey
#
# This file is part of icd.
#
# icd is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# icd is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with icd. If not, see <http:#www.gnu.org/licenses/>.

#' Get children of ICD codes
#'
#' Expand ICD codes to all possible sub-codes, optionally limiting to those
#' codes which are \emph{defined} or \emph{billable} (leaf nodes).
#' @param x data, e.g. character vector of ICD codes.
#' @param defined single logical value, whether returned codes should only
#'   include those which have definitions. Definition is based on the ICD
#'   version being used, e.g. ICD-9-CM, the WHO version of ICD-10, or other.
#' @template billable
#' @template short_code
#' @template dotdotdot
#' @keywords manip
#' @family ICD-9 ranges
#' @examples
#' library(magrittr, warn.conflicts = FALSE, quietly = TRUE) # optional
#'
#' # no children other than self
#' icd_children("10201", short_code = TRUE, defined =FALSE)
#'
#' # guess it was ICD-9 and a short, not decimal code
#' icd_children("0032")
#'
#' # empty because 102.01 is not meaningful
#' icd_children("10201", short_code = TRUE, defined =TRUE)
#' icd_children("003", short_code = TRUE, defined =TRUE) %>%
#'   icd_explain(condense = FALSE, short_code = TRUE)
#'
#' icd_children(short_code = FALSE, "100.0")
#' icd_children(short_code = FALSE, "100.00")
#' icd_children(short_code = FALSE, "2.34")
#' @export
icd_children <- function(x, ...)
  UseMethod("icd_children")

#' @describeIn icd_children Get child codes, guessing ICD version and short
#'   versus decimal format
#' @export
icd_children.character <- function(x, ...) {
  ver <- icd_guess_version(x)
  # eventually UseMethod again, but this would be circular until the icd10
  # method is defined.
  switch(ver,
         "icd9" = icd_children.icd9(x = x, ...),
         "icd10" = icd_children.icd10(x = x, ...),
         NULL)
}

#' @describeIn icd_children Get children of ICD-9 codes
#' @export
icd_children.icd9 <- function(x, short_code = icd_guess_short(x),
                              defined = TRUE, billable = FALSE, debug = FALSE, ...) {
  assert(check_factor(x), check_character(x))
  assert_flag(short_code)
  assert_flag(defined)
  assert_flag(billable)

  # TODO order/unorder consistently for decimal and short
  res <- if (short_code)
    .Call("icd_icd9ChildrenShortUnordered", toupper(x), defined)
  else
    .Call("icd_icd9ChildrenDecimalCpp", toupper(x), defined)

  res <- icd_sort.icd9(res)

  if (billable)
    icd_get_billable.icd9cm(icd9cm(res), short_code)
  else
    as.icd9(res)
}

#' @describeIn icd_children Get children of ICD-10 codes (warns because this
#'   only applies to ICD-10-CM for now).
#' @export
#' @keywords internal
icd_children.icd10 <- function(x, short_code = icd_guess_short(x), defined, billable = FALSE, ...) {
  icd_children.icd10cm(x, short_code, defined, billable, ...)
}

#' @describeIn icd_children Get children of ICD-10-CM codes
#' @export
#' @keywords internal
icd_children.icd10cm <- function(x, short_code = icd_guess_short(x), defined, billable = FALSE, ...) {
  assert(check_factor(x), check_character(unclass(x)))
  assert_flag(short_code)
  assert_flag(billable)

  if (!missing(defined) && !defined)
    stop("Finding children of anything but defined ICD-10-CM codes is current not supported.")

  icd_children_defined.icd10cm(x = x, short_code = short_code)
}

# this is just lazy package data, but apparently need to declare it to keep CRAN
# happy. May not be needed if doing icd::
utils::globalVariables("icd10cm2016")

#' defined children of ICD codes
#'
#' Find defined ICD-10 children based on 2016 ICD-10-CM list. "defined" may be a
#' three digit code, or a leaf node. This is distinct from 'billable'.
#'
#' @keywords internal
icd_children_defined <- function(x)
  UseMethod("icd_children_defined")

#' @describeIn icd_children_defined Internal function to get the children of
#'   ICD-10 code(s)
#' @param warn single logical value, if \code{TRUE} will generate warnings when
#'   some input codes are not known ICD-10-CM codes
#' @param use_cpp single logical flag, whether to use C++ version
#' @examples
#' \dontrun{
#' library(microbenchmark)
#' microbenchmark::microbenchmark(
#'   icd:::icd_children_defined.icd10cm("A01"),
#'   icd:::icd_children_defined_r.icd10cm("A01")
# ' )
#' stopifnot(identical(icd:::icd_children_defined.icd10cm("A00"),
#'   icd:::icd_children_defined_r.icd10cm("A00")))
#' }
#' @keywords internal
icd_children_defined.icd10cm <- function(x, short_code = icd_guess_short(x), warn = FALSE) {
  assert_character(x)
  assert_flag(short_code)
  assert_flag(warn)

  x <- trim(x)
  x <- toupper(x)
  if (!short_code)
    x <- icd_decimal_to_short.icd10cm(x)

  kids <- icd10cm_children_defined_cpp(x)
  as.icd10cm(kids, short_code)
}
