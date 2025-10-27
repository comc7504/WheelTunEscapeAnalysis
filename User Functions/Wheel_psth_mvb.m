%Displays what step
disp('Wheel Analysis');

% Does analysis by event locking wheel bouts
% % Requires main_mvb and load_mvb 
[WheelAns,trig_time,ZscoreMeanWheel] = wheelAnalysis(fp_data(:,5), ...
    fp_data(:,8),fp_data(:,13), fp_data(:,15), win, sr, Tstart, ...
    Tfinish, ITIb,rats);

 %Input

 %fp_data(:,5) is the fitted dF
 %fp_data(:,8) = trial frame strt,duration, end
 %fp_data(:,13) is start frame of wheel bout during trial
 %fp_data(:,15) is start frame of wheel bout during ITI
 %win is the window in frames
 %sr is sampling rate
 %Tstart is the starting trial
 %Tfinish is the ending trial
 %ITIb is for if analysis occurs during trial or ITI
 %rats gives N size info

 %Output

 %WheelAns gives each N trial intervial analysis
 %trig_time is evently spaced window in sec with wheel bout start =0
 %ZscoreMeanWheel is meaned analysis for each N for trial interval

 %Adds ZscoreMeanWheel for ease of access
 ANALYSIS_FINAL.('zscoreMeanWheel') = ZscoreMeanWheel;

 