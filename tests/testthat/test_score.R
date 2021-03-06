context("Differential Expression Gene Scoring")
test_that("Robust z-scores can be calculated correctly", {
  skip_if_devel()
  # load data directly from datafile
  ids.treat <- colnames(sl[, seq_len(5)])
  ids.ctrl <- colnames(sl)[seq_len(59) + 17]
  data <- rhdf5::h5read(gctx, name = "0/DATA/0/matrix")
  coln <- rhdf5::h5read(gctx, name = "0/META/COL/id" )
  data.treat <- data[, match(ids.treat, coln)]
  
  # calculate z scores for 1 plate manually
  data.treat.p5 <- data.treat[,5]
  ix.ctrl.p5 <- c(64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76)
  data.ctrl <- rhdf5::h5read(gctx, 
                             name = "0/DATA/0/matrix", 
                             index = list(NULL, ix.ctrl.p5))
  meanad <- function(x) {
    mean(abs(x - mean(x)) * 1.253314)
  }
  medians <- apply(data.ctrl, 1, median)
  mads <- apply(data.ctrl, 1, mad)
  meanads <- apply(data.ctrl, 1, meanad)
  ix.zero <- which(mads == 0)
  mads[ix.zero] <- meanads[ix.zero]
  zs <- (data.treat.p5 - medians) / mads
  
  # compare to score calculated by package
  zs2 <- rzs(sl, treat = "amoxicillin")
  expect_equal(as.numeric(zs), as.numeric(zs2[,5]))
})
test_that("Scoring on landmark genes only works.", {
  skip_if_devel()
  zs2 <- rzs(sl, treat = "amoxicillin", inferred = FALSE)
  zs <- rzs(sl, treat = "amoxicillin", inferred = TRUE)
  expect(all.equal(zs[1:978, ], zs2))
  expect(nrow(zs2), 978)
})

zs2 <- rzs(sl, treat = "amoxicillin", inferred = FALSE)
test_that("Characteristic direction can be calculated by plate", {
  skip_if_devel()
  cd_vecs <- diffexp(sl, treat = "E2F3",
                     where_clause = list("pert_type" = "trt_sh",
                                         "cell_id" = "MCF7"),
                     split_by_plate = TRUE, 
                     verbose = FALSE)
  expect_equivalent(cd_vecs[1,1],  -0.011311670, tol = 0.00001)
  expect_equal(ncol(cd_vecs), 5)
})
test_that("KS scores can be calculated", {
  skip_if_devel()
  #zs <- rzs(sl, treat = "amoxicillin")
  #scores <- ks(sl, zs)
  #expect_equivalent(scores[1], -0.1784700, tol = 0.00001)
  scores <- diffexp(sl, sl[, seq_len(5)], method = "ks", split_by_plate = FALSE)
  expect_equivalent(scores[1], -0.1784700, tol = 0.00001)
})


