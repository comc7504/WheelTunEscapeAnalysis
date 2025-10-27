%Displays what step
disp('ITI Analysis');

%This finds ITI significant peaks
% % Requires main_mvb and load_mvb 
[eventcenter] = sigPeakFinder (fp_data(:,8),Tstart,Tfinish,sigspotWindow, ...
     fp_data(:,5),fp_data(:,7),fp_data(:,16),rats,sig_crit,WantWheelTurnITI);

 %Input
 
 %fp_data(:,8) = trial frame strt,duration, end
 %Tstart is the starting trial
 %Tfinish is the ending trial
 %sigspotWindow is for size of rolling window
 %fp_data(:,5) is the fitted dF
 %fp_data(:,7) is ES logic
 %fp_data(:,16) is wheel turn logic
 %rats gives N size info
 %sig_crit is the threshold used for significant peaks
 %WantWheelTurnITI logic for removing sig peaks during wheel events

 %Output

 %Eventcenter contains important sig peak analysis including peak frequency


 %Adds pos and neg ITI for ease of access
 ANALYSIS_FINAL.('PosITI') = eventcenter(:,8);
 ANALYSIS_FINAL.('NegITI') =eventcenter(:,9);

