# Basic tests of tryCatchLog

# Tests are run within the folder "tryCatchLog/tests/testthat".
# Clean it up at the beginning of a test!

library(testthat)



# Test preparation ------------------------------------------------------------------------------------------------

context("test_dump_files.R")



options("tryCatchLog.write.error.dump.file" = FALSE)
options("tryCatchLog.silent.warnings" = FALSE)
options("tryCatchLog.silent.messages" = FALSE)




# helper function to delete all existing dump files in the working directory
# (used for test set-up)
clean.up.dump.files <- function() {
  existing.dump.files <- list.files(pattern = "dump_.*\\.rda")

  if (length(existing.dump.files) > 0)
    file.remove(existing.dump.files)
}



# helper function to count the number of existing dump files
number.of.dump.files <- function() {
  dump.files <- list.files(pattern = "dump_.*\\.rda")
  return(length(dump.files))
}



clean.up.dump.files()



# suppress logging of errors and warnings to avoid overly output
source("disable_logging_output.R")



# unit tests ------------------------------------------------------------------------------------------------------

context("dump.to.file")


test_that("no dump file is created without an error", {
  tryCatchLog(TRUE, write.error.dump.file = TRUE)
  expect_equal(number.of.dump.files(), 0)
  clean.up.dump.files()
})



test_that("no dump file is created for an warning", {
  expect_warning(tryCatchLog(log(-1), write.error.dump.file = TRUE))
  expect_equal(number.of.dump.files(), 0)
  clean.up.dump.files()
})



test_that("no dump file is created with an error but disabled write.error.dump.file parameter",
          {
            tryCatchLog(
              log("a"),
              error = function(e) {
              },
              write.error.dump.file = FALSE
            )
            expect_equal(number.of.dump.files(), 0)

            clean.up.dump.files()

            log <- last.tryCatchLog.result()
            expect_equal(log$dump.file.name, "", info = "no dump file contained in log")
          })



test_that("dump file is created with an error and write.error.dump.file parameter enabled",
          {
            tryCatchLog(
              log("a"),
              error = function(e) {
              },
              write.error.dump.file = TRUE
            )

            expect_equal(number.of.dump.files(), 1)

            log <- last.tryCatchLog.result()

            # Check for correct logging of dump file name
            expect_true(!is.na(log$dump.file.name))
            expect_gt(nchar(log$dump.file.name), 0)
            expect_true(file.exists(log$dump.file.name), info = "correct dump file contained in log")
            # print(log$dump.file.name)

            clean.up.dump.files()
          })



options("tryCatchLog.write.error.dump.file" = FALSE)    # global default setting for all tryCatchLog call params "write.error.dump.file"



test_that("no dump file is created (no error)", {
  tryCatchLog(TRUE)
  expect_equal(number.of.dump.files(), 0)
  clean.up.dump.files()
})



test_that("no dump file is created (warning)", {
  expect_warning(tryCatchLog(
    log(-1),
    error = function(e) {
    }
  ))
  expect_equal(number.of.dump.files(), 0)
  clean.up.dump.files()
})



test_that("no dump file is created (error)", {
  tryCatchLog(
    log("a"),
    error = function(e) {
    }
  )
  expect_equal(number.of.dump.files(), 0)
  clean.up.dump.files()
})



options("tryCatchLog.write.error.dump.file" = TRUE)    # global default setting for all tryCatchLog call params "write.error.dump.file"



test_that("no dump file is created (no error but dump default enabled)", {
  tryCatchLog(TRUE)
  expect_equal(number.of.dump.files(), 0)
  clean.up.dump.files()
})



test_that("no dump file is created (warning but dump default enabled)", {
  expect_warning(tryCatchLog(
    log(-1),
    error = function(e) {
    }
  ))
  expect_equal(number.of.dump.files(), 0)
  clean.up.dump.files()
})



test_that("dump file is created (error and dump default enabled)", {
  tryCatchLog(
    log("a"),
    error = function(e) {
    }
  )
  expect_equal(number.of.dump.files(), 1)
  clean.up.dump.files()
})



clean.up.dump.files()
