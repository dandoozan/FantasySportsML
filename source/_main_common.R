library(caret) #dummyVars
library(Ckmeans.1d.dp) #xgb.plot.importance
library(randomForest) #randomForest
library(hydroGOF) #rmse
library(ggplot2) #visualization
library(ggthemes) #visualization
library(dplyr) #%>%
source('../ml-common/plot.R')
source('../ml-common/util.R')
source('source/_getData_2016.R')
source('source/_createTeam.R')

#How to run boruta:
  #-R
  #-rm(list = ls())
  #-source('~/Desktop/ML/df/source/_getData_2016.R')
  #-source('~/Desktop/ML/df/source/_main_common.R')
  #-d = getData()
  #-f = getAllFeatures(d, F.TOEXCLUDE)
  #-library(Boruta)
  #-set.seed(13)
  #-b = Boruta(d[, f], d[[Y_NAME]], doTrace=2)
  #-paste(names(b$finalDecision[b$finalDecision=='Confirmed']), collapse='\', \'')
  #-paste(names(b$finalDecision[b$finalDecision=='Tentative']), collapse='\', \'')
  #-paste(names(b$finalDecision[b$finalDecision=='Rejected']), collapse='\', \'')


#possible duplicates:
# Salary, RG_MW_fd_current <-- duplicate REMOVE
# RG_saldiff, RG_MW_fd_change <-- no, saldiff is between fd and dk (fd-dk)
# RG_diff20, RG_MW_dk_change <-- no, it's dk - fd
# RG_salary20, RG_MW_dk_current <-- they might be duplicate, but they both have missing data that the other contains; perhaps merge them in the future
# RG_salary15, RG_MW_dd_current <-- "
# RG_salary28, RG_MW_fa_current <-- "
# RG_salary43, RG_MW_fdft_current <-- "
# RG_salary50, RG_MW_y_current <-- "
# RG_salary58, RG_MW_rstr_current <-- "
# RG_ADV_D_RT, NBA_S_P_ADV_DEF_RATING <-- no
# RG_ADV_O_RT, NBA_S_P_ADV_OFF_RATING <-- no
# RG_ADV_EFGPCT, NBA_S_P_ADV_EFG_PCT <-- no
# RG_ADV_TSPCT, NBA_S_P_ADV_TS_PCT <-- no
# RG_ADV_USGPCT, NBA_S_P_ADV_USG_PCT <-- no

Y_NAME = 'FP'
PREDICTION_NAME = 'Prediction'

#features excluded: FantasyPoints, Minutes, Date, Name
F.ID = c('Date', 'Name', 'Position', 'Team', 'Opponent')
F.FANDUEL = c('Date', 'Name', 'Position', 'FPPG', 'GamesPlayed', 'Salary', 'Home', 'Team', 'Opponent', 'InjuryIndicator', 'InjuryDetails')
F.ROTOGURU = c('FantasyPoints', 'Minutes')
F.NUMBERFIRE = c('NF_Min', 'NF_Pts', 'NF_Reb', 'NF_Ast', 'NF_Stl', 'NF_Blk', 'NF_TO', 'NF_FP')
F.RG.PP = c('RG_ceil', 'RG_floor', 'RG_points', 'RG_ppdk', 'RG_line',  'RG_movement', 'RG_overunder', 'RG_total', 'RG_contr', 'RG_pownpct', 'RG_rank', 'RG_rankdiff', 'RG_saldiff', 'RG_deviation', 'RG_minutes', 'RG_rank20', 'RG_diff20', 'RG_rank_diff20', 'RG_salary20', 'RG_salary15', 'RG_salary19', 'RG_salary28', 'RG_salary43', 'RG_salary50', 'RG_salary58', 'RG_points15', 'RG_points19', 'RG_points20', 'RG_points28', 'RG_points43', 'RG_points50', 'RG_points51', 'RG_points58')
F.RG.ADVANCEDPLAYERSTATS = c('RG_ADV_D_RT', 'RG_ADV_O_RT', 'RG_ADV_POW_AST', 'RG_ADV_POW_BLK', 'RG_ADV_POW_PTS', 'RG_ADV_POW_REB', 'RG_ADV_POW_STL', 'RG_ADV_EFGPCT', 'RG_ADV_TSPCT', 'RG_ADV_USGPCT')
F.RG.MARKETWATCH = c('RG_MW_dk_current', 'RG_MW_dk_change', 'RG_MW_fa_current',  'RG_MW_fa_change', 'RG_MW_y_current', 'RG_MW_y_change', 'RG_MW_dd_current', 'RG_MW_dd_change', 'RG_MW_rstr_current', 'RG_MW_rstr_change', 'RG_MW_fd_change', 'RG_MW_fdft_current', 'RG_MW_fdft_change')
F.RG.OPTIMALLINEUP = c('RG_OL_OnTeam')
F.RG.START = c('RG_START_Order', 'RG_START_Starter', 'RG_START_Status')
F.RG.DVP = c('RG_OPP_DVP_CFPPG', 'RG_OPP_DVP_CRK', 'RG_OPP_DVP_PFFPPG', 'RG_OPP_DVP_PFRK', 'RG_OPP_DVP_PGFPPG', 'RG_OPP_DVP_PGRK', 'RG_OPP_DVP_SFFPPG', 'RG_OPP_DVP_SFRK', 'RG_OPP_DVP_SGFPPG', 'RG_OPP_DVP_SGRK')
F.RG.OVD.BASIC = c('RG_OVD_AST', 'RG_OVD_STL', 'RG_OVD_FGM', 'RG_OVD_TO', 'RG_OVD_3PM', 'RG_OVD_BLK', 'RG_OVD_FGPCT', 'RG_OVD_REB', 'RG_OVD_PTS', 'RG_OVD_FGA')
F.RG.OVD.OPP.BASIC = c('RG_OVD_OPP_AST', 'RG_OVD_OPP_STL', 'RG_OVD_OPP_FGM', 'RG_OVD_OPP_TO', 'RG_OVD_OPP_3PM', 'RG_OVD_OPP_BLK', 'RG_OVD_OPP_FGPCT', 'RG_OVD_OPP_REB', 'RG_OVD_OPP_PTS', 'RG_OVD_OPP_FGA')
F.RG.BACK2BACK = c('RG_B2B_Situation')
F.RG.BACK2BACK.OPP = c('RG_B2B_OPP_Situation')
F.NBA.SEASON.PLAYER.TRADITIONAL = c('NBA_S_P_TRAD_GP', 'NBA_S_P_TRAD_W', 'NBA_S_P_TRAD_L', 'NBA_S_P_TRAD_W_PCT', 'NBA_S_P_TRAD_MIN', 'NBA_S_P_TRAD_FGM', 'NBA_S_P_TRAD_FGA', 'NBA_S_P_TRAD_FG_PCT', 'NBA_S_P_TRAD_FG3M', 'NBA_S_P_TRAD_FG3A', 'NBA_S_P_TRAD_FG3_PCT', 'NBA_S_P_TRAD_FTM', 'NBA_S_P_TRAD_FTA', 'NBA_S_P_TRAD_FT_PCT', 'NBA_S_P_TRAD_OREB', 'NBA_S_P_TRAD_DREB', 'NBA_S_P_TRAD_REB', 'NBA_S_P_TRAD_AST', 'NBA_S_P_TRAD_TOV', 'NBA_S_P_TRAD_STL', 'NBA_S_P_TRAD_BLK', 'NBA_S_P_TRAD_BLKA', 'NBA_S_P_TRAD_PF', 'NBA_S_P_TRAD_PFD', 'NBA_S_P_TRAD_PTS', 'NBA_S_P_TRAD_PLUS_MINUS', 'NBA_S_P_TRAD_DD2', 'NBA_S_P_TRAD_TD3')
F.NBA.SEASON.PLAYER.ADVANCED = c('NBA_S_P_ADV_OFF_RATING', 'NBA_S_P_ADV_DEF_RATING', 'NBA_S_P_ADV_NET_RATING', 'NBA_S_P_ADV_AST_PCT', 'NBA_S_P_ADV_AST_TO', 'NBA_S_P_ADV_AST_RATIO', 'NBA_S_P_ADV_OREB_PCT', 'NBA_S_P_ADV_DREB_PCT', 'NBA_S_P_ADV_REB_PCT', 'NBA_S_P_ADV_TM_TOV_PCT', 'NBA_S_P_ADV_EFG_PCT', 'NBA_S_P_ADV_TS_PCT', 'NBA_S_P_ADV_USG_PCT', 'NBA_S_P_ADV_PACE', 'NBA_S_P_ADV_PIE', 'NBA_S_P_ADV_FGM_PG', 'NBA_S_P_ADV_FGA_PG')
F.NBA.SEASON.PLAYER.DEFENSE = c('NBA_S_P_DEF_DEF_RATING', 'NBA_S_P_DEF_PCT_DREB', 'NBA_S_P_DEF_PCT_STL', 'NBA_S_P_DEF_PCT_BLK', 'NBA_S_P_DEF_OPP_PTS_OFF_TOV', 'NBA_S_P_DEF_OPP_PTS_2ND_CHANCE', 'NBA_S_P_DEF_OPP_PTS_FB', 'NBA_S_P_DEF_OPP_PTS_PAINT', 'NBA_S_P_DEF_DEF_WS')
F.NBA.PLAYERBIOS = c('NBA_PB_AGE', 'NBA_PB_PLAYER_HEIGHT_INCHES', 'NBA_PB_PLAYER_WEIGHT', 'NBA_PB_COLLEGE', 'NBA_PB_COUNTRY', 'NBA_PB_DRAFT_YEAR', 'NBA_PB_DRAFT_ROUND', 'NBA_PB_DRAFT_NUMBER')
F.NBA.TODAY = c('NBA_TODAY_GP', 'NBA_TODAY_W', 'NBA_TODAY_L', 'NBA_TODAY_W_PCT', 'NBA_TODAY_MIN', 'NBA_TODAY_FGM', 'NBA_TODAY_FGA', 'NBA_TODAY_FG_PCT', 'NBA_TODAY_FG3M', 'NBA_TODAY_FG3A', 'NBA_TODAY_FG3_PCT', 'NBA_TODAY_FTM', 'NBA_TODAY_FTA', 'NBA_TODAY_FT_PCT', 'NBA_TODAY_OREB', 'NBA_TODAY_DREB', 'NBA_TODAY_REB', 'NBA_TODAY_AST', 'NBA_TODAY_TOV', 'NBA_TODAY_STL', 'NBA_TODAY_BLK', 'NBA_TODAY_BLKA', 'NBA_TODAY_PF', 'NBA_TODAY_PFD', 'NBA_TODAY_PTS', 'NBA_TODAY_PLUS_MINUS', 'NBA_TODAY_DD2', 'NBA_TODAY_TD3')
F.NBA.SEASON.TEAM.TRADITIONAL = c('NBA_S_T_TRAD_GP', 'NBA_S_T_TRAD_W', 'NBA_S_T_TRAD_L', 'NBA_S_T_TRAD_W_PCT', 'NBA_S_T_TRAD_MIN', 'NBA_S_T_TRAD_FGM', 'NBA_S_T_TRAD_FGA', 'NBA_S_T_TRAD_FG_PCT', 'NBA_S_T_TRAD_FG3M', 'NBA_S_T_TRAD_FG3A', 'NBA_S_T_TRAD_FG3_PCT', 'NBA_S_T_TRAD_FTM', 'NBA_S_T_TRAD_FTA', 'NBA_S_T_TRAD_FT_PCT', 'NBA_S_T_TRAD_OREB', 'NBA_S_T_TRAD_DREB', 'NBA_S_T_TRAD_REB', 'NBA_S_T_TRAD_AST', 'NBA_S_T_TRAD_TOV', 'NBA_S_T_TRAD_STL', 'NBA_S_T_TRAD_BLK', 'NBA_S_T_TRAD_BLKA', 'NBA_S_T_TRAD_PF', 'NBA_S_T_TRAD_PFD', 'NBA_S_T_TRAD_PTS', 'NBA_S_T_TRAD_PLUS_MINUS')
F.NBA.SEASON.OPPTEAM.TRADITIONAL = c('NBA_S_OPPT_TRAD_GP', 'NBA_S_OPPT_TRAD_W', 'NBA_S_OPPT_TRAD_L', 'NBA_S_OPPT_TRAD_W_PCT', 'NBA_S_OPPT_TRAD_MIN', 'NBA_S_OPPT_TRAD_FGM', 'NBA_S_OPPT_TRAD_FGA', 'NBA_S_OPPT_TRAD_FG_PCT', 'NBA_S_OPPT_TRAD_FG3M', 'NBA_S_OPPT_TRAD_FG3A', 'NBA_S_OPPT_TRAD_FG3_PCT', 'NBA_S_OPPT_TRAD_FTM', 'NBA_S_OPPT_TRAD_FTA', 'NBA_S_OPPT_TRAD_FT_PCT', 'NBA_S_OPPT_TRAD_OREB', 'NBA_S_OPPT_TRAD_DREB', 'NBA_S_OPPT_TRAD_REB', 'NBA_S_OPPT_TRAD_AST', 'NBA_S_OPPT_TRAD_TOV', 'NBA_S_OPPT_TRAD_STL', 'NBA_S_OPPT_TRAD_BLK', 'NBA_S_OPPT_TRAD_BLKA', 'NBA_S_OPPT_TRAD_PF', 'NBA_S_OPPT_TRAD_PFD', 'NBA_S_OPPT_TRAD_PTS', 'NBA_S_OPPT_TRAD_PLUS_MINUS')
F.MINE = c('FP', 'AVG_FP', 'OPP_DVP_FPPG', 'OPP_DVP_RANK', 'TEAM_RG_points', 'TEAMMATES_RG_points')

F.PROJECTIONS.FANTASYPOINTS = c('NF_FP', 'RG_ceil', 'RG_floor', 'RG_points', 'RG_ppdk', 'RG_points15', 'RG_points19', 'RG_points20', 'RG_points28', 'RG_points43', 'RG_points50', 'RG_points51', 'RG_points58', 'TEAM_RG_points', 'TEAMMATES_RG_points')
F.PROJECTIONS.STATS = c('NF_Min', 'NF_Pts', 'NF_Reb', 'NF_Ast', 'NF_Stl', 'NF_Blk', 'NF_TO', 'RG_minutes')
F.SALARIES = c('RG_salary20', 'RG_salary15', 'RG_salary19', 'RG_salary28', 'RG_salary43', 'RG_salary50', 'RG_salary58', 'RG_MW_dk_current', 'RG_MW_fa_current', 'RG_MW_y_current', 'RG_MW_dd_current', 'RG_MW_rstr_current', 'RG_MW_fdft_current')
F.TOEXCLUDE = c(Y_NAME, 'FP0', 'FP1', 'FP2', F.ROTOGURU, F.NBA.TODAY, 'Date', 'Name')

# F.ALL = setdiff(c(F.FANDUEL, F.NUMBERFIRE, F.RG.PP, F.RG.ADVANCEDPLAYERSTATS, F.RG.MARKETWATCH, F.RG.OPTIMALLINEUP, F.RG.START, F.RG.DVP,
#                     F.RG.OVD.BASIC, F.RG.OVD.OPP.BASIC, F.RG.BACK2BACK, F.RG.BACK2BACK.OPP, F.NBA.SEASON.PLAYER.TRADITIONAL,
#                     F.NBA.SEASON.PLAYER.ADVANCED, F.NBA.SEASON.PLAYER.DEFENSE, F.NBA.PLAYERBIOS, F.NBA.SEASON.TEAM.TRADITIONAL,
#                     F.NBA.SEASON.OPPTEAM.TRADITIONAL, F.MINE),
#                   F.TOEXCLUDE)
# F.ALL.SANSPROJECTIONS = setdiff(F.ALL, c(
#   c('NF_FP', 'RG_ceil', 'RG_floor', 'RG_points', 'RG_ppdk', 'RG_points15', 'RG_points19', 'RG_points20', 'RG_points28', 'RG_points43', 'RG_points50', 'RG_points51', 'RG_points58', 'TEAM_RG_points', 'TEAMMATES_RG_points') #projected fantasy points
#   #,c('RG_salary20', 'RG_salary15', 'RG_salary19', 'RG_salary28', 'RG_salary43', 'RG_salary50', 'RG_salary58', 'RG_MW_dk_current', 'RG_MW_fa_current', 'RG_MW_y_current', 'RG_MW_dd_current', 'RG_MW_rstr_current', 'RG_MW_fdft_current') #salaries
#   #,c('NF_Min', 'NF_Pts', 'NF_Reb', 'NF_Ast', 'NF_Stl', 'NF_Blk', 'NF_TO', 'RG_minutes') #projected specific stats
# ))

F.BORUTA.CONFIRMED = c('FPPG', 'GamesPlayed', 'Salary', 'Team', 'NF_Min', 'NF_Pts', 'NF_Reb', 'NF_Ast', 'NF_Stl', 'NF_Blk', 'NF_TO', 'RG_line', 'RG_overunder', 'RG_total', 'RG_contr', 'RG_pownpct', 'RG_deviation', 'RG_minutes', 'RG_rank', 'RG_salary15', 'RG_salary19', 'RG_rank20', 'RG_diff20', 'RG_salary20', 'RG_salary28', 'RG_salary43', 'RG_salary50', 'RG_salary58', 'RG_ADV_D_RT', 'RG_ADV_O_RT', 'RG_ADV_POW_AST', 'RG_ADV_POW_BLK', 'RG_ADV_POW_PTS', 'RG_ADV_POW_REB', 'RG_ADV_POW_STL', 'RG_ADV_EFGPCT', 'RG_ADV_TSPCT', 'RG_ADV_USGPCT', 'RG_START_Order', 'RG_START_Starter', 'RG_MW_dk_current', 'RG_MW_fa_current', 'RG_MW_y_current', 'RG_MW_dd_current', 'RG_MW_dd_change', 'RG_MW_rstr_current', 'RG_MW_fdft_current', 'NBA_S_P_TRAD_GP', 'NBA_S_P_TRAD_W', 'NBA_S_P_TRAD_L', 'NBA_S_P_TRAD_W_PCT', 'NBA_S_P_TRAD_MIN', 'NBA_S_P_TRAD_FGM', 'NBA_S_P_TRAD_FGA', 'NBA_S_P_TRAD_FG_PCT', 'NBA_S_P_TRAD_FG3M', 'NBA_S_P_TRAD_FG3A', 'NBA_S_P_TRAD_FG3_PCT', 'NBA_S_P_TRAD_FTM', 'NBA_S_P_TRAD_FTA', 'NBA_S_P_TRAD_FT_PCT', 'NBA_S_P_TRAD_OREB', 'NBA_S_P_TRAD_DREB', 'NBA_S_P_TRAD_REB', 'NBA_S_P_TRAD_AST', 'NBA_S_P_TRAD_TOV', 'NBA_S_P_TRAD_STL', 'NBA_S_P_TRAD_BLK', 'NBA_S_P_TRAD_PF', 'NBA_S_P_TRAD_PFD', 'NBA_S_P_TRAD_PTS', 'NBA_S_P_TRAD_PLUS_MINUS', 'NBA_S_P_ADV_OFF_RATING', 'NBA_S_P_ADV_DEF_RATING', 'NBA_S_P_ADV_NET_RATING', 'NBA_S_P_ADV_AST_PCT', 'NBA_S_P_ADV_AST_TO', 'NBA_S_P_ADV_AST_RATIO', 'NBA_S_P_ADV_OREB_PCT', 'NBA_S_P_ADV_DREB_PCT', 'NBA_S_P_ADV_REB_PCT', 'NBA_S_P_ADV_TM_TOV_PCT', 'NBA_S_P_ADV_EFG_PCT', 'NBA_S_P_ADV_TS_PCT', 'NBA_S_P_ADV_USG_PCT', 'NBA_S_P_ADV_PACE', 'NBA_S_P_ADV_PIE', 'NBA_S_P_ADV_FGM_PG', 'NBA_S_P_ADV_FGA_PG', 'NBA_S_P_DEF_DEF_RATING', 'NBA_S_P_DEF_PCT_DREB', 'NBA_S_P_DEF_PCT_STL', 'NBA_S_P_DEF_PCT_BLK', 'NBA_S_P_DEF_OPP_PTS_OFF_TOV', 'NBA_S_P_DEF_OPP_PTS_2ND_CHANCE', 'NBA_S_P_DEF_OPP_PTS_FB', 'NBA_S_P_DEF_OPP_PTS_PAINT', 'NBA_S_P_DEF_DEF_WS', 'NBA_PB_AGE', 'NBA_PB_PLAYER_HEIGHT_INCHES', 'NBA_PB_PLAYER_WEIGHT', 'NBA_PB_COLLEGE', 'NBA_PB_DRAFT_YEAR', 'NBA_PB_DRAFT_NUMBER', 'NBA_S_T_TRAD_FGM', 'NBA_S_T_TRAD_FG_PCT', 'NBA_S_T_TRAD_FG3M', 'NBA_S_T_TRAD_FG3A', 'NBA_S_T_TRAD_FG3_PCT', 'NBA_S_T_TRAD_FTM', 'NBA_S_T_TRAD_FTA', 'NBA_S_T_TRAD_AST', 'NBA_S_T_TRAD_TOV', 'NBA_S_T_TRAD_STL', 'NBA_S_T_TRAD_PF', 'NBA_S_T_TRAD_PTS', 'NBA_S_T_TRAD_PLUS_MINUS', 'NBA_S_OPPT_TRAD_FGM', 'InRotoGrinders', 'InRGAndNF', 'AVG_FP')
F.BORUTA.TENTATIVE = c('Date', 'Position', 'RG_saldiff', 'RG_MW_fd_change', 'RG_OVD_AST', 'RG_OVD_OPP_AST', 'RG_OVD_OPP_FGM', 'NBA_S_P_TRAD_BLKA', 'NBA_S_P_TRAD_DD2', 'NBA_PB_DRAFT_ROUND', 'NBA_S_T_TRAD_GP', 'NBA_S_T_TRAD_L', 'NBA_S_T_TRAD_W_PCT', 'NBA_S_T_TRAD_MIN', 'NBA_S_T_TRAD_FGA', 'NBA_S_T_TRAD_FT_PCT', 'NBA_S_T_TRAD_OREB', 'NBA_S_T_TRAD_DREB', 'NBA_S_T_TRAD_REB', 'NBA_S_T_TRAD_BLK', 'NBA_S_T_TRAD_BLKA', 'NBA_S_T_TRAD_PFD', 'NBA_S_OPPT_TRAD_GP', 'NBA_S_OPPT_TRAD_AST', 'NBA_S_OPPT_TRAD_STL')
F.BORUTA.REJECTED = c('Home', 'Opponent', 'InjuryIndicator', 'InjuryDetails', 'RG_movement', 'RG_rankdiff', 'RG_rank_diff20', 'RG_START_Status', 'RG_MW_dk_change', 'RG_MW_fa_change', 'RG_MW_y_change', 'RG_MW_rstr_change', 'RG_MW_fdft_change', 'RG_OL_OnTeam', 'RG_OPP_DVP_CFPPG', 'RG_OPP_DVP_CRK', 'RG_OPP_DVP_PFFPPG', 'RG_OPP_DVP_PFRK', 'RG_OPP_DVP_PGFPPG', 'RG_OPP_DVP_PGRK', 'RG_OPP_DVP_SFFPPG', 'RG_OPP_DVP_SFRK', 'RG_OPP_DVP_SGFPPG', 'RG_OPP_DVP_SGRK', 'RG_OVD_STL', 'RG_OVD_FGM', 'RG_OVD_TO', 'RG_OVD_3PM', 'RG_OVD_BLK', 'RG_OVD_FGPCT', 'RG_OVD_REB', 'RG_OVD_PTS', 'RG_OVD_FGA', 'RG_OVD_OPP_STL', 'RG_OVD_OPP_TO', 'RG_OVD_OPP_3PM', 'RG_OVD_OPP_BLK', 'RG_OVD_OPP_FGPCT', 'RG_OVD_OPP_REB', 'RG_OVD_OPP_PTS', 'RG_OVD_OPP_FGA', 'RG_B2B_Situation', 'RG_B2B_OPP_Situation', 'NBA_S_P_TRAD_TD3', 'NBA_PB_COUNTRY', 'NBA_S_T_TRAD_W', 'NBA_S_OPPT_TRAD_W', 'NBA_S_OPPT_TRAD_L', 'NBA_S_OPPT_TRAD_W_PCT', 'NBA_S_OPPT_TRAD_MIN', 'NBA_S_OPPT_TRAD_FGA', 'NBA_S_OPPT_TRAD_FG_PCT', 'NBA_S_OPPT_TRAD_FG3M', 'NBA_S_OPPT_TRAD_FG3A', 'NBA_S_OPPT_TRAD_FG3_PCT', 'NBA_S_OPPT_TRAD_FTM', 'NBA_S_OPPT_TRAD_FTA', 'NBA_S_OPPT_TRAD_FT_PCT', 'NBA_S_OPPT_TRAD_OREB', 'NBA_S_OPPT_TRAD_DREB', 'NBA_S_OPPT_TRAD_REB', 'NBA_S_OPPT_TRAD_TOV', 'NBA_S_OPPT_TRAD_BLK', 'NBA_S_OPPT_TRAD_BLKA', 'NBA_S_OPPT_TRAD_PF', 'NBA_S_OPPT_TRAD_PFD', 'NBA_S_OPPT_TRAD_PTS', 'NBA_S_OPPT_TRAD_PLUS_MINUS', 'InNumberFire', 'OPP_DVP_FPPG', 'OPP_DVP_RANK')

computeError = function(y, yhat, amountToAddToY) {
  return(rmse(y, yhat))
}
setup = function(startDate, endDate, prodRun, filename) {
  if (prodRun) cat('PROD RUN: ', filename, '\n', sep='')

  #load data
  data = getData(startDate, endDate)
  return(data)
}

getAllFeatures = function(d, featuresToExclude) {
  featuresToUse = setdiff(colnames(d), featuresToExclude)
  cat('Number of features to use: ', length(featuresToUse), '/', length(colnames(d)), '\n', sep='')
  return(featuresToUse)
}
getFeaturesToUse = function(d) {
  featuresToUse = c('RG_points', 'NF_FP')
  #featuresToUse = c('RG_points', 'NF_FP', 'RG_points51', 'RG_points15', 'RG_points19', 'RG_points20', 'RG_points28', 'RG_points43', 'RG_points50', 'RG_points58')
  cat('Number of features to use: ', length(featuresToUse), '/', length(colnames(d)), '\n', sep='')
  return(featuresToUse)
}

runAlgs = function(algs, d, amountToAddToY, featuresToUse) {
  cat('Running algorithms...\n')
  #run avg
  if (PLOT_ALG == '' || PLOT_ALG == 'avg') {
    cat('---------------AVG---------------\n')
    teamStats = if (MAKE_TEAMS) makeTeams(NULL, d, Y_NAME, featuresToUse, amountToAddToY, PREDICTION_NAME, MAX_COVS, NUM_HILL_CLIMBING_TEAMS, createTeamPrediction, CONTESTS_TO_PLOT, STARTING_BALANCE, PLOT, PROD_RUN, T) else list()
    if (PLOT_ALG == 'avg') {
      makePlots(NULL, PLOT, d, Y_NAME, featuresToUse, baseModel, amountToAddToY, FILENAME, CONTESTS_TO_PLOT, teamStats, PROD_RUN)
    }
  }

  #run the specific algos
  for (algName in names(algs)) {
    if (PLOT_ALG == '' || PLOT_ALG == algName) {
      cat('---------------', toupper(algName), '---------------\n')
      obj = algs[[algName]]
      baseModel = createBaseModel(obj, d, Y_NAME, featuresToUse, amountToAddToY)
      printErrors(obj, baseModel, d, Y_NAME, featuresToUse, amountToAddToY)
      teamStats = if (MAKE_TEAMS) makeTeams(obj, d, Y_NAME, featuresToUse, amountToAddToY, PREDICTION_NAME, MAX_COVS, NUM_HILL_CLIMBING_TEAMS, createTeamPrediction, CONTESTS_TO_PLOT, STARTING_BALANCE, PLOT, PROD_RUN, F) else list()
      if (PLOT_ALG == algName) {
        makePlots(obj, PLOT, d, Y_NAME, featuresToUse, baseModel, amountToAddToY, FILENAME, CONTESTS_TO_PLOT, teamStats, PROD_RUN)
      }
    }
  }
}

createBaseModel = function(obj, d, yName, xNames, amountToAddToY) {
  #create model
  cat('Creating Model...\n', sep='')
  timeElapsed = system.time(baseModel <- obj$createModel(d, yName, xNames, amountToAddToY))
  cat('    Time to compute model: ', timeElapsed[3], '\n', sep='')
  obj$printModelResults(baseModel, d, yName, xNames, amountToAddToY)
  return(baseModel)
}

printErrors = function(obj, model, data, yName, xNames, amountToAddToY) {
  cat('Computing Errors...\n')

  #split data into trn, cv
  split = splitData(data, yName)
  trn = split$train
  cv = split$cv

  trnModel = obj$createModel(trn, yName, xNames, amountToAddToY)
  trnError = computeError(trn[[yName]], obj$createPrediction(trnModel, trn, xNames, amountToAddToY), amountToAddToY)
  cvPrediction = obj$createPrediction(trnModel, cv, xNames, amountToAddToY)
  cvError = computeError(cv[[yName]], cvPrediction, amountToAddToY)
  trainError = computeError(data[[yName]], obj$createPrediction(model, data, xNames, amountToAddToY), amountToAddToY)
  cat('    Trn/CV/Train: ', trnError, '/', cvError, '/', trainError, '\n', sep='')

  #print rg error
  cvWithRGData = cv[cv$InRotoGrinders == 1,]
  cat('    CV RG/Mine: ', computeError(cvWithRGData[[yName]], cvWithRGData$RG_points, amountToAddToY), '/', computeError(cvWithRGData[[yName]], cvPrediction[which(cv$InRotoGrinders == 1)], amountToAddToY), '\n', sep='')

  #print nf error
  cvWithNFData = cv[cv$InNumberFire == 1,]
  cat('    CV NF/Mine: ', computeError(cvWithNFData[[yName]], cvWithNFData$NF_FP, amountToAddToY), '/', computeError(cvWithNFData[[yName]], cvPrediction[which(cv$InNumberFire == 1)], amountToAddToY), '\n', sep='')
}

findFirstIndexOfDate = function(data, date) {
  index = which(data$Date == date)
  if (length(index) > 0) {
    return(which(data$Date == date)[1])
  }
  return(-1)
}
findLastIndexOfDate = function(data, date) {
  dateIndices = which(data$Date == date)
  if (length(dateIndices) > 0) {
    return(dateIndices[length(dateIndices)])
  }
  return(-1)
}
splitDataIntoTrainTest = function(data, startDate, splitDate) {
  startIndex = ifelse(startDate == 'start', 1, findFirstIndexOfDate(data, startDate))
  if (splitDate == 'end') {
    train = data[startIndex:nrow(data),]
    test = NULL
  } else {
    splitIndex = findFirstIndexOfDate(data, splitDate)
    endIndex = findLastIndexOfDate(data, splitDate)
    train = data[startIndex:(splitIndex-1),]
    test = data[splitIndex:endIndex,]
  }
  return(list(train=train, test=test))
}

getHighestWinningScore = function(contestData, dateStr) {
  #return the highest winnning score for this date
  return(max(contestData[contestData$Date == dateStr, 'HighestScore'], na.rm=T))
}
getLowestWinningScore = function(contests, dateStr, type, entryFee=-1, maxEntries=-1, maxEntriesPerUser=-1) {
  #return the lowest lastWinningScore; essentially, this is what i need to have won anything in any contest
  contests = contests[(contests$Date == dateStr) & (contests$Type == type),]
  if (entryFee > -1) {
    contests = contests[contests$EntryFee == entryFee,]
  }
  if (maxEntries > -1) {
    contests = contests[contests$MaxEntries == maxEntries,]
  }
  if (maxEntriesPerUser > -1) {
    contests = contests[contests$MaxEntriesPerUser == maxEntriesPerUser,]
  }

  if (sum(!is.na(contests$LastWinningScore)) > 0) {
    return(max(contests$LastWinningScore, na.rm=T))
  }
  return(NA)
}

getRgTeam = function(test, yName) {
  rgTeam = test[test$RG_OL_OnTeam == 1,]
  if (sum(rgTeam[[yName]] == 0) || nrow(rgTeam) < 9) {
    return(NULL)
  }
  return(rgTeam)
}

plotScores = function(dateStrs, bandLow=c(), bandHigh=c(), contestLowests=list(), contestsToPlot=list(), greedyTeamExpected=c(), greedyTeamActual=c(), rgTeamExpected=c(), rgTeamActual=c(), myTeamUsingRGPointsActual=c(), hillClimbingTeams=list(), medianActualFPs=c(), balance=c(), name='Scores', save=FALSE, main='Title', filename='') {
  cat('    Plotting ', name, '...\n', sep='')

  if (save) startSavePlot(name, filename)

  labels = c()
  colors = c()

  dates = as.Date(dateStrs)

  #draw balance
  if (length(balance) > 0) {
    #make the margin wider on side 4 (right side)
    par(mar=c(5, 4, 4, 5) + 0.1)
    plot(dates, balance, type='l', col='gray', ylim=c(min(balance), max(balance) + 50), xaxt='n', yaxt='n', xlab='', ylab='')
    polygon(c(dates, rev(dates)), c(balance, numeric(length(balance))), col='gray95', border=NA)
    axis(side=4)
    mtext('Balance', side=4, line=3)
    labels = c(labels, 'Balance')
    colors = c(colors, 'gray')

    #create new plot after balance
    par(new=TRUE)
  }

  numHillClimbing = length(hillClimbingTeams)
  numContestLowests = length(contestLowests)

  #get ymin and ymax
  yMin = min(bandLow, greedyTeamExpected, greedyTeamActual, rgTeamExpected, rgTeamActual, myTeamUsingRGPointsActual, medianActualFPs, na.rm=T)
  yMax = max(bandHigh, greedyTeamExpected, greedyTeamActual, rgTeamExpected, rgTeamActual, myTeamUsingRGPointsActual, medianActualFPs, na.rm=T)
  if (numContestLowests > 0) {
    for (i in 1:numContestLowests) {
      yMin = min(yMin, contestLowests[[i]], na.rm=T)
      yMax = max(yMax, contestLowests[[i]], na.rm=T)
    }
  }
  if (numHillClimbing > 0) {
    for (i in 1:numHillClimbing) {
      yMin = min(yMin, hillClimbingTeams[[i]], na.rm=T)
      yMax = max(yMax, hillClimbingTeams[[i]], na.rm=T)
    }
  }
  yMax = yMax + 50 #add 50 to allow room for legend

  #create plot
  plot(dates, numeric(length(dates)), type='n', ylim=c(yMin, yMax), ylab='Fantasy Points', xlab='Date', xaxt='n', main=main)

  #draw band
  if (length(bandLow) > 0) {
    lines(dates, bandLow, col='blue')
    lines(dates, bandHigh, col='blue')
    polygon(c(dates, rev(dates)), c(bandHigh, rev(bandLow)), col='azure', border=NA)
    labels = c(labels, 'Tournament Results')
    colors = c(colors, 'blue')
  }

  #draw lowest5050
  if (numContestLowests > 0) {
    for (i in 1:numContestLowests) {
      lines(dates, contestLowests[[i]], col=contestsToPlot[[i]]$color)
      labels = c(labels, contestsToPlot[[i]]$label)
      colors = c(colors, contestsToPlot[[i]]$color)
    }
  }

  #draw rg expected
  if (length(rgTeamExpected) > 0) {
    lines(dates, rgTeamExpected, col='blue')
    labels = c(labels, 'RG Team Expected')
    colors = c(colors, 'blue')
  }
  #draw rg actual
  if (length(rgTeamActual) > 0) {
    lines(dates, rgTeamActual, col='orange')
    labels = c(labels, 'RG Team')
    colors = c(colors, 'orange')
  }

  #draw my team using rg points
  if (length(myTeamUsingRGPointsActual) > 0) {
    lines(dates, myTeamUsingRGPointsActual, col='orange')
    labels = c(labels, 'My Team Using RG Points')
    colors = c(colors, 'orange')
  }

  #draw greedy expected
  if (length(greedyTeamExpected) > 0) {
    lines(dates, greedyTeamExpected, col='purple')
    labels = c(labels, 'My Team Expected')
    colors = c(colors, 'purple')
  }

  #draw hill climbing
  if (numHillClimbing > 0) {
    for (i in 1:numHillClimbing) {
      lines(dates, hillClimbingTeams[[i]], col='grey', lty=2)
    }
    #draw greedy as gray
    if (length(greedyTeamActual) > 0) {
      lines(dates, greedyTeamActual, col='grey')
    }
    labels = c(labels, 'My Teams')
    colors = c(colors, 'grey')

    #draw median
    if (length(medianActualFPs) > 0) {
      lines(dates, medianActualFPs, col='black')
      labels = c(labels, 'My Teams Median')
      colors = c(colors, 'black')
    }
  } else {
    if (length(greedyTeamActual) > 0) {
      #draw greedy
      color = 'red'
      lines(dates, greedyTeamActual, col=color)
      labels = c(labels, 'My Team')
      colors = c(colors, color)
    }
  }

  #add grid
  spacing = 50
  abline(h=seq((yMin - yMin%%spacing), (yMax - yMax%%spacing + spacing), spacing), v=dates, col='gray', lty='dotted')

  #add legend
  addLegend(rev(labels), rev(colors))

  #add date axis
  axis.Date(side=1, dates, format="%m/%d")

  if (save) endSavePlot()
}
plotRmseByFP = function(d, prediction, yName, dateStr='') {
  rmses = c()
  rgRmses = c()
  interval = 1
  for (i in seq(0, max(d[[yName]]), interval)) {
    rows = which(d[[yName]] >= i)# which((d[[yName]] >= i) & (d[[yName]] < (i + interval)))
    #cat('num rows at i=', i, ': ', length(rows), '\n')
    rmses = c(rmses, computeError(d[[yName]][rows], prediction[rows], amountToAddToY))

    rgRows = intersect(rows, which(d$InRotoGrinders==1))
    rgRmses = c(rgRmses, computeError(d[[yName]][rgRows], d$RG_points[rgRows], amountToAddToY))
  }
  #cat('Max FP=', max(d[[yName]]), ', ', '\n')
  plot(rmses, xlab='Fantasy Points', main=dateStr)
  points(rgRmses, col='orange')
}

makeTeams = function(obj, data, yName, xNames, amountToAddToY, predictionName, maxCovs, numHillClimbingTeams, createTeamPrediction, contestsToPlot, startingBalance, toPlot, prodRun, useAvg) {
  cat('Now let\'s see how I would\'ve done each day...\n')

  contestData = getContestData()

  cat('    Creating teams with max covs:', paste0(paste0(names(maxCovs), '='), maxCovs, collapse=', '), '\n')
  #these are arrays to plot later
  myRmses = c()
  myRmses15 = c()
  nfRmses = c()
  rgRmses = c()
  fdRmses = c()
  teamRatios = c()
  myTeamExpectedFPs = c()
  myTeamActualFPs = c()
  myTeamRmses = c()
  myTeamGreedyExpectedFPs = c()
  myTeamHillClimbingExpectedFPs = c()
  myTeamUsingRGPointsActualFPs = c()
  rgTeamExpectedFPs = c()
  rgTeamActualFPs = c()
  highestWinningScores = c()
  lowestWinningScores = c()
  contestLowests = vector('list', length(contestsToPlot))
  for (i in 1:length(contestsToPlot)) contestLowests[[i]] = numeric()
  myTeamHillClimbingActualFPs = vector('list', numHillClimbingTeams)
  for (i in 1:numHillClimbingTeams) myTeamHillClimbingActualFPs[[i]] = numeric()
  medianActualFPs = c()
  balances = c()

  currBalance = startingBalance
  numWins = 0
  numLosses = 0

  dateStrs = getUniqueDates(data)
  dateStrs = dateStrs[(dateStrs>=PLOT_START_DATE) & (dateStrs<=END_DATE)]
  for (dateStr in dateStrs) {
    cat('    ', dateStr, ': ', sep='')

    #split data into train, test
    trainTest = splitDataIntoTrainTest(data, 'start', dateStr)
    train = trainTest$train
    test = trainTest$test

    prediction = createTeamPrediction(obj, train, test, yName, xNames, amountToAddToY, useAvg)
    test[[predictionName]] = prediction
    #plotRmseByFP(test, prediction, yName, date=dateStr)

    myRmse = computeError(test[[yName]], test[[predictionName]], amountToAddToY)
    test15 = test[test[[predictionName]] >= 15,]
    myRmse15 = computeError(test15[[yName]], test15[[predictionName]], amountToAddToY)
    nfRmse = computeError(test[[yName]], test$NF_FP, amountToAddToY)
    rgRmse = computeError(test[[yName]], test$RG_points, amountToAddToY)
    fdRmse = computeError(test[[yName]], test$FPPG, amountToAddToY)

    #create my teams for today
    myTeamGreedy = createTeam_Greedy(test, predictionName, maxCovs=maxCovs)
    foundTeam = if (is.null(myTeamGreedy)) FALSE else TRUE
    myTeamExpectedFP = if(foundTeam) computeTeamFP(myTeamGreedy, predictionName) else NA
    myTeamActualFP = if(foundTeam) computeTeamFP(myTeamGreedy, yName) else NA
    rgTeam = getRgTeam(test, yName)
    foundRGTeam = if (is.null(rgTeam)) FALSE else TRUE
    rgTeamExpectedFP = if (foundRGTeam) computeTeamFP(rgTeam, 'RG_points') else NA
    rgTeamActualFP = if (foundRGTeam) computeTeamFP(rgTeam, yName) else NA
    myTeamUsingRGPoints = createTeam_Greedy(test, 'RG_points', maxCovs=maxCovs)
    foundMyTeamUsingRGPoints = if (is.null(myTeamUsingRGPoints)) FALSE else TRUE
    myTeamUsingRGPointsActualFP = if(foundMyTeamUsingRGPoints) computeTeamFP(myTeamUsingRGPoints, yName) else NA
    myTeamRmse = if (foundTeam) computeError(myTeamGreedy[[yName]], myTeamGreedy[[predictionName]], amountToAddToY) else NA
    allMyTeamActualFPs = c(myTeamActualFP)
    # if (prodRun || toPlot == 'multiscores') {
    #   for (i in 1:numHillClimbingTeams) {
    #     hillClimbingActualFP = computeActualFP(createTeam_HillClimbing(predictionDF, yName, maxCovs=maxCovs), test, yName)
    #     myTeamHillClimbingActualFPs[[i]] = c(myTeamHillClimbingActualFPs[[i]], hillClimbingActualFP)
    #     allMyTeamActualFPs = c(allMyTeamActualFPs, hillClimbingActualFP)
    #   }
    # }
    medianActualFP = median(allMyTeamActualFPs)
    medianActualFPs = c(medianActualFPs, medianActualFP)

    #get actual fanduel winning score for currday, and compute amountWonLost
    highestWinningScore = getHighestWinningScore(contestData, dateStr)
    lowestWinningScore = getLowestWinningScore(contestData, dateStr, type='TOURNAMENT')
    amountWonLost = 0
    for (i in 1:length(contestsToPlot)) {
      contestToPlot = contestsToPlot[[i]]
      contestLow = getLowestWinningScore(contestData, dateStr, type=contestToPlot$type, entryFee=contestToPlot$entryFee, maxEntries=contestToPlot$maxEntries, maxEntriesPerUser=contestToPlot$maxEntriesPerUser)
      contestLowests[[i]] = c(contestLowests[[i]], contestLow)
      if (foundTeam && !is.na(contestLow)) {
        amountWonLost = amountWonLost + (if (medianActualFP >= contestLow) contestToPlot$winAmount else -contestToPlot$entryFee)
      }
    }

    #adjust balance
    currBalance = currBalance + amountWonLost
    balances = c(balances, currBalance)
    if (amountWonLost > 0) {
      numWins = numWins + 1
    } else if (amountWonLost < 0) {
      numLosses = numLosses + 1
    }

    #print results
    cat('allRmse=', round(myRmse, 2), sep='')
    #cat(', rgRmse=', round(rgRmse, 2), sep='')
    cat(', rmse≥15=', round(myRmse15, 2), sep='')
    cat(', teamRmse=', round(myTeamRmse, 2), sep='')
    #cat(', minFpOnTeam=', min(myTeamGreedy[[predictionName]]), sep='')
    #cat(', expected=', round(myTeamExpectedFP, 2), sep='')
    #cat(', actual=', round(myTeamActualFP, 2), sep='')
    cat(', score=', round(medianActualFP, 2), sep='')
    #cat(', lowTourn=', round(lowestWinningScore, 2), sep='')
    cat(', low=', round(contestLow, 2), sep='')
    #cat(', ', whichTeamITook, sep='')
    #cat(', high=', round(highestWinningScore, 2), sep='')
    #cat(', gain=', amountWonLost, sep='')
    cat(', balance=', currBalance, sep='')
    #cat(', te=', nrow(test), sep='')
    cat('\n')

    #add data to arrays to plot
    myRmses = c(myRmses, myRmse)
    myRmses15 = c(myRmses15, myRmse15)
    fdRmses = c(fdRmses, fdRmse)
    nfRmses = c(nfRmses, nfRmse)
    rgRmses = c(rgRmses, rgRmse)
    myTeamExpectedFPs = c(myTeamExpectedFPs, myTeamExpectedFP)
    myTeamActualFPs = c(myTeamActualFPs, myTeamActualFP)
    myTeamUsingRGPointsActualFPs = c(myTeamUsingRGPointsActualFPs, myTeamUsingRGPointsActualFP)
    rgTeamExpectedFPs = c(rgTeamExpectedFPs, rgTeamExpectedFP)
    rgTeamActualFPs = c(rgTeamActualFPs, rgTeamActualFP)
    myTeamRmses = c(myTeamRmses, myTeamRmse)
    highestWinningScores = c(highestWinningScores, highestWinningScore)
    lowestWinningScores = c(lowestWinningScores, lowestWinningScore)
  }

  #print final balance
  cat('Balance: ', getCurrencyString(currBalance), sep='')
  cat(', Gain: ', getCurrencyString(currBalance - startingBalance), sep='')
  cat(', Wins/Losses: ', numWins, '/' , numLosses, sep='')
  cat('\n')

  #print mean of rmses
  cat('Mean RMSE of all players/>15/team: ', mean(myRmses), '/', mean(myRmses15), '/', mean(myTeamRmses), '\n', sep='')

  #print myteam score / lowestWinningScore ratio, call it "scoreRatios"
  scoreRatios = myTeamActualFPs/lowestWinningScores
  cat('Mean myScore/lowestScore ratio: ', mean(scoreRatios), '\n', sep='')

  return(list(
    dateStrs=dateStrs,
    myRmses=myRmses,
    fdRmses=fdRmses,
    nfRmses=nfRmses,
    rgRmses=rgRmses,
    myTeamExpectedFPs=myTeamExpectedFPs,
    myTeamActualFPs=myTeamActualFPs,
    myTeamHillClimbingActualFPs=myTeamHillClimbingActualFPs,
    medianActualFPs=medianActualFPs,
    rgTeamExpectedFPs=rgTeamExpectedFPs,
    rgTeamActualFPs=rgTeamActualFPs,
    myTeamUsingRGPointsActualFPs=myTeamUsingRGPointsActualFPs,
    myTeamRmses=myTeamRmses,
    scoreRatios=scoreRatios,
    highestWinningScores=highestWinningScores,
    lowestWinningScores=lowestWinningScores,
    contestLowests=contestLowests,
    balances=balances
  ))
}

makePlots = function(obj, toPlot, data, yName, xNames, model, amountToAddToY, filename, contestsToPlot, teamStats=list(), prodRun) {
  cat('Creating plots...\n')
  if (length(teamStats) > 0) {
    if (prodRun || toPlot == 'bal') plotScores(teamStats$dateStrs, contestLowests=teamStats$contestLowests, contestsToPlot=contestsToPlot, greedyTeamExpected=teamStats$myTeamExpectedFPs, greedyTeamActual=teamStats$myTeamActualFPs, myTeamUsingRGPointsActual=teamStats$myTeamUsingRGPointsActualFPs, balance=teamStats$balances, main='How I Would\'ve Done', name='Balance', save=prodRun, filename=filename)
    #if (prodRun || toPlot == 'scores') plotScores(teamStats$dateStrs, teamStats$lowestWinningScores, teamStats$highestWinningScores, contestLowests=teamStats$contestLowests, contestsToPlot=contestsToPlot, greedyTeamExpected=teamStats$myTeamExpectedFPs, greedyTeamActual=teamStats$myTeamActualFPs, main='My Team Vs. Actual Contests', name='Scores', save=prodRun, filename=filename)
    #if (prodRun || toPlot == 'multiscores') plotScores(teamStats$dateStrs, teamStats$lowestWinningScores, teamStats$highestWinningScores, contestLowests=teamStats$contestLowests, contestsToPlot=contestsToPlot, greedyTeamActual=teamStats$myTeamActualFPs, hillClimbingTeams=teamStats$myTeamHillClimbingActualFPs, medianActualFPs=teamStats$medianActualFPs, main='My Teams Vs. Actual Contests', name='Multiscores', save=prodRun, filename=filename)
    #if (prodRun || toPlot == 'rmse_scoreratios') plotByDate2Axis(teamStats$dateStrs, teamStats$myRmses, ylab='RMSE', ylim=c(5, 12), y2=teamStats$scoreRatios, y2lim=c(0, 1.5), y2lab='Score Ratio', main='RMSEs and Score Ratios', save=prodRun, name='RMSE_ScoreRatios', filename=filename)
    #if (prodRun || toPlot == 'rmses') plotLinesByDate(teamStats$dateStrs, list(teamStats$myRmses, teamStats$fdRmses, teamStats$nfRmses, teamStats$rgRmses), ylab='RMSEs', labels=c('Me', 'FanDuel', 'NumberFire', 'RotoGrinder'), main='My Prediction Vs Other Sites', save=prodRun, name='RMSEs', filename=filename)
  }
  if (!is.null(obj)) {
    obj$doPlots(toPlot, prodRun, data, yName, xNames, model, amountToAddToY, filename)
  }
}

computeAmountToAddToY = function(d, yName) {
  minValue = min(d[[yName]])
  if (minValue > 0) {
    return(0)
  }
  amountToAddToY = abs(minValue) + 1
  cat('Adding ', amountToAddToY, ' to Y\n', sep='')
  return(amountToAddToY)
}

#----------------- utility functions ----------------
plotBucketRmses = function(obj, d, yName, predName, amountToAddToY, interval) {
  intervals = seq(interval, max(d[[predName]]), interval)
  rmses = c()
  for (i in intervals) {
    low = i - interval
    high = i
    subset = d[d[[predName]] > low & d[[predName]] <= high,]
    #rmse = rmse(subset[[yName]], subset[[predName]])
    rmse = computeError(subset[[yName]], subset[[predName]], amountToAddToY)
    cat(i, ', ', rmse, '\n')
    rmses = c(rmses, rmse)
  }
  plot(intervals, rmses)
}
getPredictionForDate = function(dateStr, yName) {
  d = getData()
  featuresToUse = getFeaturesToUse(d)

  sp = splitDataIntoTrainTest(d, 'start', dateStr)
  train = sp$train
  test = sp$test
  return(getPredictionDF(createTeamPrediction(obj, train, test, yName, featuresToUse), test, yName, amountToAddToY))
}
getCvPrediction = function(obj, d, yName) {
  featuresToUse = getFeaturesToUse(d)
  amountToAddToY = computeAmountToAddToY(d, yName)
  hyperParams = obj$findBestHyperParams(d, yName, featuresToUse, amountToAddToY)

  split = splitData(d, yName)
  trn = split$train
  cv = split$cv

  trnModel = obj$createModel(trn, yName, featuresToUse, amountToAddToY)
  trnError = computeError(trn[[yName]], obj$createPrediction(trnModel, trn, featuresToUse, amountToAddToY), amountToAddToY)
  cvPrediction = obj$createPrediction(trnModel, cv, featuresToUse, amountToAddToY)
  cvError = computeError(cv[[yName]], cvPrediction, amountToAddToY)
  #trainError = computeError(d[[yName]], obj$createPrediction(model, data, featuresToUse, amountToAddToY), amountToAddToY)

  cv$Pred = cvPrediction
  cv$Diff = abs(cv[[yName]] - cv$Pred)
  cv$PctDiff = cv$Diff / cv$Pred * 100

  # interval = 5
  # intervals = seq(interval, nrow(cv), interval)
  # for (i in intervals) {
  #   subset = cv[cv$Pred > low & cv$Pred <= high,]
  #   rmse = computeError(subset[[yName]], subset$Pred, amountToAddToY)
  #   rmses = c(rmses, rmse)
  # }

  cv$PredBuckets = cut(cv$Pred, breaks=10)
  #plot(Diff~PredBuckets, cv)

  return(cv)
}
getDataPrediction = function(d, yName) {
  featuresToUse = getFeaturesToUse(d)
  amountToAddToY = computeAmountToAddToY(d, yName)

  model = obj$createModel(d, yName, featuresToUse, amountToAddToY)
  prediction = obj$createPrediction(model, d, featuresToUse, amountToAddToY)

  d$Pred = prediction
  d$Diff = d[[yName]] - d$Pred
  d$PctDiff = d$Diff / d$Pred * 100

  return(d)

  #plot(PctDiff~RG_B2B_Situation, d[d$Pred > 15,])
}

getTeamForDate = function(obj, d, dateStr, yName, rg=F, maxCov=Inf, useAvg=F) {
  maxCovs = list(C=maxCov, SF=maxCov, SG=maxCov, PF=maxCov, PG=maxCov)
  #Dates investigated:
    #-11/22:
      #-Dwight Howard (38.60012 -> 21.2) - unlucky (ATL lost in a blowout, but they were supposed to win handily); however NOP's DVP vs C was execellent, so maybe I should've taken that more into account
      #-Julius Randle (29.01744 -> 9.0) - he was hurt (hip bruise), which caused him to play bad, but his injury wasn't official and he started and played a lot of minutes as expected
    #-11/18
      #-Wesley Matthews (24.21 -> 13.9)
        #-his stdev and cov is quite high (11.41, 0.56),
        #-also his team was expected to score low (RG_total=91.25)
        #-also dvp rank is 20, which is pretty strong
      #-LeBron James (47.74 -> 29.1)
        #-blowout win, which vegas odds predicted i think <-- i think this is the main cause that he had fewer minutes
        #-dvp rank is 23
        #-b2b = 3in4
      #-Isaiah Thomas (40.09 -> 25.4)
        #-blowout loss
    #----------
    #-11/21
      #-Brandon Knight (25.36 -> 11.7 (-53.86)):
        #-b2b: could be 3-in-4, or multiple away games in a row, or flight from east to west coast, something along those lines
        #-cov: is high (0.41)
        #-powpct: was only 1%
      #-Josh Richardson (24.36 -> 11.9 (-51.15)):
        #-away game?: it was the 2nd away game in a row
        #-injury?: he had an injury at the start of the season so missed the first 4 games
        #-cov: is somewhat high (0.34)
      #-Andrew Wiggins (31.28 -> 18.3 (-41.5))
        #-cov: is high at 0.40
        #-min: he did play a lot of minutes (more than expected) at 39
    #-11/19
      #-Markieff Morris (26.42 -> 6.0 (-77.29))
        #-Injury: he got injured in the second quarter, so didnt play after that
    #-11/14
      #-Kelly Olynyk (24.55 -> 14.1 (-42.57))
        #-cov: is somewhat high at 0.38
        #-dvp was strong at 20
        #-gp: only 3 games played
        #-b2b: 3in4
      #-Eric Gordon (23.58 -> 17.7 (-24.94))
        #-line: -737 (major overdogs), and it was indeed a blowout, which is probably the reason
        #-dvp: 11
      #-Ryan Anderson (22.76 -> 17.4 (-23.55))
        #-line: -737, same reasons as above since he also plays for HOU
        #-dvp: 18
    #-------
    #-11/18
      #-Kevin Love (36.28 -> 25.1 (-30.82))
        #-blowout win
        #-b2b: 3in4
    #-11/16
      #-Kelly Olynyk (23.1 -> 12.8 (-44.59))
        #-RGvNF: wide prediction spread b/n NF and RG (NF=28.2, RG=20.98)
        #-OU: low scoring game (ou=200.5)
    #-------
    #-11/19
      #-Robin Lopez (22.76 -> 19.2 (-15.64))
        #-OU: 202.5
        #-dvp: 21
    #-11/9
      #-Wesley Matthews (21.44 -> 0 (-100))
        #He did not play, and according to espn it was bc he "got the night off on the back end of a back-to-back"
        #-b2b: 3in4-B2B
        #-line: 1975 (major underdogs)
        #-dvp: 18




  xNames = getFeaturesToUse(d)

  sp = splitDataIntoTrainTest(d, 'start', dateStr)
  train = sp$train
  test = sp$test

  amountToAddToY = 3

  lm = ALGS[['lm']]
  lmPrediction = lm$createPrediction(lm$createModel(train, yName, xNames, amountToAddToY), test, xNames, amountToAddToY)
  rf = ALGS[['rf']]
  rfPrediction = rf$createPrediction(rf$createModel(train, yName, xNames, amountToAddToY), test, xNames, amountToAddToY)
  xgb = ALGS[['xgb']]
  xgbPrediction = xgb$createPrediction(xgb$createModel(train, yName, xNames, amountToAddToY), test, xNames, amountToAddToY)

  test$Pred = round(createTeamPrediction(obj, train, test, yName, xNames, amountToAddToY, useAvg), 2)
  test$lmPred = round(lmPrediction, 2)
  test$rfPred = round(rfPrediction, 2)
  test$xgbPred = round(xgbPrediction, 2)
  test$Diff = test[[yName]] - test$Pred
  test$PctDiff = round(test$Diff / test$Pred * 100, 2)

  team = if (rg) createTeam_Greedy(test, 'RG_points', maxCovs=maxCovs) else createTeam_Greedy(test, 'Pred', maxCovs=maxCovs)

  #set minFP, meanFP, and stdevFP
  team$minFP = 0
  team$meanFP = 0
  team$stDev = 0
  for (i in 1:nrow(team)) {
    name = team[i, 'Name']
    trainFPs = train[train$Name == name, yName]
    if (length(trainFPs) > 0) {
      #team[i, 'minFP'] = min(trainFPs)
      #team[i, 'meanFP'] = round(mean(trainFPs), 2)
      #team[i, 'stDev'] = round(psd(trainFPs), 2)
      team[i, 'avgMins'] = round(mean(train[train$Name == name, 'NBA_TODAY_MIN']), 2)
    }
  }
  #team$myCov = round(team$stDev / team$meanFP, 2)

  #rename some cols
  team$pos = team$Position
  team$rgPred = team$RG_points
  team$nfPred = team$NF_FP
  team$rgStDev = round(team$RG_deviation, 2)
  team$rgMins = team$RG_minutes
  team$nfMins = team$NF_Min
  team$mins = team$NBA_TODAY_MIN
  team$ovrundr = team$RG_overunder
  team$line = team$RG_line
  team$total = team$RG_total
  team$dvp = team$OPP_DVP_RANK
  team$sal = team$Salary
  team$ppdk = round(team$PPD, 2)
  team$b2b = team$RG_B2B_Situation
  team$gp = team$NBA_S_P_TRAD_GP
  team$pownp = team$RG_pownpct

  team$MeanFP = round(team$MeanFP, 2)
  team$StDevFP = round(team$StDevFP, 2)
  team$COV = round(team$COV, 2)

  return(team[order(team$PctDiff),])

  #print
  #t[, c('Name', 'pos', 'Team', 'FP', 'Pred', 'PctDiff', 'lmPred', 'rfPred', 'xgbPred', 'rgPred', 'nfPred', 'MeanFP', 'MinFP', 'StDevFP', 'COV', 'ovrundr', 'line', 'total', 'rgMins', 'nfMins', 'avgMins', 'mins', 'dvp', 'sal', 'ppdk', 'gp', 'b2b', 'pownp')]
}
