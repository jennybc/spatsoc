# Test GroupTimes
context('test GroupTimes')
library(spatsoc)

DT <- fread('../testdata/buffalo.csv')


test_that('DT is required', {
  expect_error(GroupTimes(DT = NULL, timeField = NULL, threshold = '10 minutes'),
               'input DT required')
})


test_that('time field correctly provided or error detected', {
  expect_error(GroupTimes(DT, timeField = NULL, threshold = '10 minutes'),
               'time field required')

  expect_error(GroupTimes(DT, timeField = 'potato', threshold = '10 minutes'),
               'time field provided is not found in DT')
})

test_that('if threshold is null, warning returned', {
  copyDT <- copy(DT)[, posix := as.POSIXct(posix)]
  expect_warning(GroupTimes(copyDT, timeField = 'posix', threshold = NULL),
                 'no threshold provided', fixed = FALSE)
})


test_that('time fields are already present', {
  copyDT <- copy(DT)[, posix := as.POSIXct(posix)]
  GroupTimes(copyDT, timeField = 'posix', threshold = '10 minutes')
  expect_warning(GroupTimes(copyDT, timeField = 'posix', threshold = '10 minutes'),
                 'columns found in input DT', fixed = FALSE)
})

test_that('time field is appropriate format', {
  copyDT <- copy(DT)

  # where character is provided
  expect_error(GroupTimes(copyDT, timeField = 'posix', threshold = '60 minutes'),
               'time field provided must be either', fixed = FALSE)

  # where numeric is provided
  copyDT[, datetime := 1]
  expect_error(GroupTimes(copyDT, timeField = 'datetime', threshold = '60 minutes'),
               'time field provided must be either', fixed = FALSE)


})

test_that('threshold with minutes fails with > 60', {
  copyDT <- copy(DT)[, posix := as.POSIXct(posix)]
  expect_error(GroupTimes(copyDT, timeField = 'posix', threshold = '70 minutes'),
               '> 60 minutes', fixed = FALSE)
})

test_that('threshold with minutes fails if not divisible by 60', {
  copyDT <- copy(DT)[, posix := as.POSIXct(posix)]
  expect_error(GroupTimes(copyDT, timeField = 'posix', threshold = '13 minutes'),
               'threshold not evenly', fixed = FALSE)
})


# check that 60 minutes and 1 hour are the same result
# warn if not divisible
# warn if block isnt even
# stop if threshold isnt in terms of hours, minutes, days