setwd(normalizePath(dirname(R.utils::commandArgs(asValues=TRUE)$"f")))
source('../h2o-runit.R')

test.pcavanilla.golden <- function(H2Oserver) {
  # Import data: 
  Log.info("Importing USArrests.csv data...") 
  arrestsR <- read.csv(locate("smalldata/pca_test/USArrests.csv"), header = TRUE)
  arrestsH2O <- h2o.uploadFile(H2Oserver, locate("smalldata/pca_test/USArrests.csv"), destination_frame = "arrestsH2O")
  
  Log.info("Compare with PCA when center = TRUE, scale. = FALSE")
  fitR <- prcomp(arrestsR, center = TRUE, scale. = FALSE)
  fitH2O <- h2o.prcomp(arrestsH2O, k = 4, transform = 'DEMEAN', max_iterations = 2000)
  checkPCAModel(fitH2O, fitR, tolerance = 1e-5)
  
  pcimpR <- summary(fitR)$importance
  pcimpH2O <- fitH2O@model$pc_importance
  Log.info("R Importance of Components:"); print(pcimpR)
  Log.info("H2O Importance of Components:"); print(pcimpH2O)
  Log.info("Compare Importance between R and H2O\n") 
  # expect_equal(as.matrix(pcimpH2O), pcimpR, tolerance = 1e-4)
  expect_equal(dim(pcimpH2O), dim(pcimpR))
  pcimpH2O <- as.matrix(pcimpH2O)
  dimnames(pcimpH2O) <- dimnames(pcimpR)
  expect_equal(pcimpH2O, pcimpR, tolerance = 1e-5)
  
  testEnd()
}

doTest("PCA Golden Test: USArrests with Centering", test.pcavanilla.golden)
