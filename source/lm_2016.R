
#============== Functions ===============
lm = function() {
  lmObj = list(
    createModel = function(d, yName, xNames, amountToAddToY) {
      #d[[yName]] = log(d[[yName]] + amountToAddToY)
      set.seed(754)
      return(stats::lm(formula=getFormula(yName, xNames), data=d))
    },
    createPrediction = function(model, newData, xNames, amountToAddToY) {
      return(predict(model, newData, type='response'))
      #return(exp(predict(model, newData, type='response')) - amountToAddToY)
    },
    printModelResults = function(d, yName, xNames, amountToAddToY, prefix='') {
      model = lmObj$createModel(d, yName, xNames, amountToAddToY)
      modelSummary = summary(model)
      cat(prefix, 'ResidualStErr/Adj-R-Squared: ', modelSummary$sigma, '/', modelSummary$adj.r.squared, '\n', sep='')
    },
    findBestHyperParams = function(d, yName, xNames, amountToAddToY) {
      return()
    },
    doPlots = function(toPlot, prodRun, data, yName, xNames, amountToAddToY, filename) {
      return()
    }
  )
  return(lmObj)
}