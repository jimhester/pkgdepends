
skip_if_offline <- function() {
  if (!is_online()) skip("Offline")
}

expect_equal_named_lists <- function(object, expected, ...) {
  expect_true(!is.null(names(object)) && !is.null(names(expected)))
  expect_true(is.list(object) && is.list(expected))
  object <- object[order(names(object))]
  expected <- expected[order(names(expected))]
  expect_equal(object, expected)
}

get_private <- function(x) x$.__enclos_env__$private

`set_private<-` <- function(x, member, value) {
  pr <- get_private(x)
  pr[[member]] <- value
  invisible(x)
}

oneday <- function() as.difftime(1, units = "days")

oneminute <- function() as.difftime(1, units = "mins")

check_packages_data <- function(pkgs) {
  cols <- packages_gz_cols()
  p_cols <- cols$pkgs
  d_cols <- cols$deps

  expect_equal(length(pkgs), 2)
  miss <- setdiff(p_cols, names(pkgs$pkgs))
  expect_identical(miss, character(0))

  miss2 <- setdiff(d_cols, names(pkgs$deps))
  expect_identical(miss2, character(0))
  expect_true(is.integer(pkgs$deps$idx))
  pkgs$deps$idx <- as.character(pkgs$deps$idx)
  expect_true(all(vlapply(pkgs$deps, is.character)))
}

test_temp_file <- function(fileext = "", pattern = "test-file-",
                           envir = parent.frame(), create = TRUE) {
  tmp <- tempfile(pattern = pattern, fileext = fileext)
  if (identical(envir, .GlobalEnv)) {
    message("Temporary files will _not_ be cleaned up")
  } else {
    withr::defer(
      try(unlink(tmp, recursive = TRUE, force = TRUE), silent = TRUE),
      envir = envir)
  }
  if (create) {
    cat("", file = tmp)
    normalizePath(tmp)
  } else {
    tmp
  }
}

test_temp_dir <- function(pattern = "test-dir-", envir = parent.frame()) {
  tmp <- test_temp_file(pattern = pattern, envir = envir, create = FALSE)
  dir.create(tmp, recursive = TRUE, showWarnings = FALSE)
  normalizePath(tmp)
}

test_package_root <- function() {
  x <- tryCatch(
    rprojroot::find_package_root_file(),
    error = function(e) NULL)

  if (!is.null(x)) return(x)

  pkg <- testthat::testing_package()
  x <- tryCatch(
    rprojroot::find_package_root_file(
      path = file.path("..", "..", "00_pkg_src", pkg)),
    error = function(e) NULL)

  if (!is.null(x)) return(x)

  stop("Cannot find package root")
}

skip_in_covr <- function() {
  if (Sys.getenv("R_COVR") == "true") skip("In covr")
}

capture_messages <- function(expr) {
  msg <- ""
  withCallingHandlers(
    expr,
    message = function(m) msg <<- paste0(msg, m$message)
  )
  msg
}

capture_async_messages <- function(expr) {
  msg <- ""
  withCallingHandlers(
    synchronise(expr),
    message = function(m) msg <<- paste0(msg, m$message)
  )
  msg
}
