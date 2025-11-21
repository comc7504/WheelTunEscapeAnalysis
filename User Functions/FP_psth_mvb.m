%Displays what step
disp('Trial Analysis');

% % Requires main_mvb and load_mvb
[StressAns,ZscoreMeanStress,trig_time, ...
    dFAUC, dfPeak, heatmap, tHalfRise, peakFWHM] = trialAnalysis(fp_data(:,5), ...
fp_data(:,8), win, sr, onset, Tstart, Tfinish,rats, latWin,basePeakfr);

 %Input

 %fp_data(:,5) is the fitted dF
 %fp_data(:,8) = trial frame start,duration, end
 %win is the window in frames
 %sr is sampling rate
 %onset is logic for if trial event lock is at the start or end of period
 %Tstart is the starting trial
 %Tfinish is the ending trial
 %rats gives N size info
 %latWin is the window in frames for AUC
 %basePeakfr is the period in frames where baseline peak will be analyzed

 %Output

 %StressAns gives each N trial intervial analysis
 %ZscoreMeanStress is meaned analysis for each N for trial interval
 %trig_time is evently spaced window in sec with wheel bout start =0
 %dFAUC gives AUC for pre and during trial 
 %dfPeak gives max peak for pre and during trial
 %peakFWHM is the width of half of the absolute max peak
 %heatmap gives the each meaned trial information over whole frame


%Adds ZscoreMeanShock, AUC, peaks, response width, and heatmap to one variable for ease of access
ANALYSIS_FINAL.('zscoreMeanStress') = ZscoreMeanStress;
ANALYSIS_FINAL.('AUC') = dFAUC;
ANALYSIS_FINAL.('Peak') = dfPeak;
ANALYSIS_FINAL.('ResponseWidth') = peakFWHM;
ANALYSIS_FINAL.('heatmap') = heatmap;


