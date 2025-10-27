table = readtable('/Users/g6bon/OneDrive/Documents/MATLAB/MVB_lab1/csvfiles/GRABDA_F21_IS.csv');
GRABDA_F21_IS_FIX = table(100:3220160,:);  %remove end
writetable(GRABDA_F21_IS_FIX, 'PL_DMS_M24_ES_fix.csv')