
#============== Functions ===============
lm = function() {
  return(list(
    createModel = function(d, yName, xNames, hyperParams, amountToAddToY) {
      set.seed(754)
      return(stats::lm(formula=getFormula(yName, xNames), data=d))
    },
    createPrediction = function(model, newData, xNames, amountToAddToY) {
      return(predict(model, newData, type='response'))
    },
    computeError = function(y, yhat, amountToAddToY) {
      return(rmse(y, yhat))
    },
    printModelResults = function(model, hyperParams, d, yName, xNames, amountToAddToY) {
      modelSummary = summary(model)
      cat('    ResidualStErr/Adj-R-Squared: ', modelSummary$sigma, '/', modelSummary$adj.r.squared, '\n', sep='')
    },
    findBestHyperParams = function(d, yName, xNames, amountToAddToY) {
      return()
    },
    doPlots = function(toPlot, prodRun, data, yName, xNames, model, amountToAddToY, filename) {
      return()
    }
  ))
}