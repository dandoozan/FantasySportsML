
#-Use RG_points, NF_FP: 10/26-11/23, 2/271, MeanOfSquaredResiduals/%VarExplained=87.61809/50.11933, Trn/CV/Train=5.025854/9.693496/5.134203, RG=9.21892/9.693496, NF=9.654601/9.693496, MAX_COV=Inf, Gain=$8, W/L=10/6, Mean RMSE of all players/rg/team=9.410472/8.953031/9.351791, Mean myScore/lowestScore ratio=0.9394312
#-Use log(y): 10/26-11/23, 2/271, 0.3303115/42.00708, 0.3098712/0.5952686/0.3202836, 0.578914/0.5952686, 0.6198487/0.5952686, Inf, $0, 8/8, 0.568672/0.5651253/0.3851929, 0.9344018

library(randomForest) #randomForest

#============== Functions ===============
rf = function() {
  rfObj = list(
    createModel = function(d, yName, xNames, amountToAddToY) {
      set.seed(754)
      return(randomForest(x=d[, xNames],
                          y=d[[yName]],
                          #y=log(d[[yName]] + amountToAddToY),
                          ntree=rfObj$findBestHyperParams()$ntree))
    },
    createPrediction = function(model, newData, xNames, amountToAddToY) {
      return(predict(model, newData))
      #return(exp(predict(model, newData)) - amountToAddToY)
    },
    printModelResults = function(model, d, yName, xNames, amountToAddToY) {
      hyperParams = rfObj$findBestHyperParams()
      cat('    MeanOfSquaredResiduals / %VarExplained: ', model$mse[hyperParams$ntree], '/', model$rsq[hyperParams$ntree]*100, '\n', sep='')
    },
    findBestHyperParams = function() {
      return(list(ntree=100))
    },
    doPlots = function(toPlot, prodRun, data, yName, xNames, model, amountToAddToY, filename) {
      if (prodRun || toPlot == 'fi') plotImportances(model, save=prodRun, filename=filename)
    },

    #I do not understand any of this code, I borrowed it from a kaggler
    plotImportances = function(model, maxFeatures=50, save=FALSE, filename='') {
      cat('Plotting Feature Importances...\n')

      # Get importance
      importances = randomForest::importance(model)

      #DPD: take the top 20 if there are more than 20
      importances = importances[order(-importances[, 1]), , drop = FALSE][1:min(maxFeatures, nrow(importances)),, drop=F]

      varImportance = data.frame(Variables = row.names(importances),
                                 Importance = round(importances[, 1], 2))

      # Create a rank variable based on importance
      rankImportance = varImportance %>%
        mutate(Rank = paste0('#',dense_rank(desc(Importance))))

      if (save) startSavePlot('Importances_rf', filename, height=max(nrow(importances)*20, 700))
      print(ggplot(rankImportance, aes(x = reorder(Variables, Importance),
                                       y = Importance, fill = Importance)) +
              geom_bar(stat='identity') +
              geom_text(aes(x = Variables, y = 0.5, label = Rank),
                        hjust=0, vjust=0.55, size = 4, colour = 'red') +
              labs(title='Feature Importances', x='Features') +
              coord_flip() +
              theme_few())
      if (save) endSavePlot()
    }
  )
  return(rfObj)
}