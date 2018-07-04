# Test Random
context('test randomizations')
library(spatsoc)

DT <- fread('../testdata/buffalo.csv')

DT[, datetime := as.POSIXct(datetime)]
DT[, yr := year(datetime)]

group_times(DT, datetime = 'datetime', threshold = '2 hours')
group_pts(DT, threshold = 100, id = 'ID', timegroup = 'timegroup',
          coords = c('X', 'Y'))


test_that('DT, type, id, datetime are required', {
  expect_error(randomizations(DT = NULL),
  'input DT required')

  expect_error(randomizations(DT = DT,
                              type = NULL),
               'type of randomization', fixed = FALSE)

  expect_error(randomizations(DT = DT,
                              type = 'step',
                              id = NULL),
               'id field required')

  expect_error(randomizations(DT = DT,
                              type = 'step',
                              id = 'ID',
                              datetime = NULL),
               'datetime field required')

})

test_that('type must be one of options', {
  expect_error(randomizations(DT = DT,
                              type = 'potato'),
               'type of randomization must be one of: step, daily or trajectory')
})

test_that('fields provided must be in DT', {
  expect_error(randomizations(DT = DT,
                              type = 'step',
                              id = 'potato',
                              datetime = 'datetime'),
               'field(s) provided are not present', fixed = TRUE)

  expect_error(randomizations(DT = DT,
                              type = 'step',
                              id = 'ID',
                              datetime = 'potato'),
               'field(s) provided are not present', fixed = TRUE)
})

test_that('iterations is NULL or correctly provided', {
  expect_warning(randomizations(DT = DT,
                              type = 'step',
                              id = 'ID',
                              datetime = 'datetime',
                              iterations = NULL),
               'iterations is not', fixed = FALSE)

  expect_error(randomizations(DT = DT,
                              type = 'step',
                              id = 'ID',
                              datetime = 'datetime',
                              iterations = 'potato'),
               'either provide a numeric for iterations or NULL', fixed = FALSE)
})

test_that('dateFormatted or not depending on randomization type', {
  expect_warning(randomizations(DT = DT,
                                type = 'step',
                                id = 'ID',
                                datetime = 'datetime',
                                iterations = 1),
                 'datetime provided is either POSIXct or IDate', fixed = FALSE)

  DT[, numDate := 1]
  expect_error(randomizations(DT = DT,
                              type = 'daily',
                              id = 'ID',
                              datetime = 'numDate',
                              iterations = 1),
                 'datetime must be either POSIXct', fixed = FALSE)

  expect_error(randomizations(DT = DT,
                              type = 'trajectory',
                              id = 'ID',
                              datetime = 'numDate',
                              iterations = 1),
                 'datetime must be either POSIXct', fixed = FALSE)
})


test_that('jul column found and warn overwrite', {
  DT[, jul := 1]
  expect_warning(randomizations(DT = DT,
                                type = 'daily',
                                id = 'ID',
                                datetime = 'datetime',
                                iterations = 1),
                 'column "jul" found in DT', fixed = FALSE)
  DT[, jul := NULL]

  DT[, jul := 1]
  expect_warning(randomizations(DT = DT,
                                type = 'trajectory',
                                id = 'ID',
                                datetime = 'datetime',
                                iterations = 1),
                 'column "jul" found in DT', fixed = FALSE)
  DT[, jul := NULL]
})
