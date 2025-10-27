function [arrayStruct,trig_time,setZscoreMean] = wheelAnalysis(signal, StressShock, StressW, ITIW, window, sr, Tstart, Tfinish, ITIb,rats)
    % signal is row vector, eg fp_data{k,5}
    % evts are start of event, eg fp_data{k,8}(:,1)
    % window is time (sec) before & after event start, eg win
    % sr is the sampling rate, eg sr

    %Var for whole window frame duration
    wintot= (window*2+1); 

    %Var for N size
    arraySize=size(signal,1); 
  
    %Evenly spaced window
    trig_time = linspace(-window/sr, window/sr, wintot); 

    %Cell for getting the zscore for stress x window interval per N
    setZscore = cell([arraySize wintot]);

    %Cell for getting the mean zscore for stress x window interval per N
    setZscoreMean = [arraySize wintot]; 
   
    % True for shock, false for wheel in main
    norm=false; 

    %Analysis for each N
    for k = 1:arraySize

        % Var for starting stress trial frame
        stressStartThreshold = StressShock{k,:}(Tstart,1);  

        % Var for ending stress trial frame
        endStartThreshold = StressShock{k,:}(Tfinish,3);  
        
        %Logic to determine if inluded wheel bouts are in ITI or stress 
        if ITIb == false
            intervalStressW = StressW{k}(StressW{k} >= stressStartThreshold & StressW{k} <= endStartThreshold);
        else 
            intervalStressW = ITIW{k}(ITIW{k} >= stressStartThreshold & ITIW{k} <= endStartThreshold);
        end

        %Var for index of wheel bout for trig_lfpZscore
        stressInt = 1:length(intervalStressW);

        %Runs wheel zscore analysis. Doesn't depend on onset logic
        trig_lfpZscore; 
         
        %Stores each wheel trail per N
        arrayStruct.(['WheelAn_' num2str(k)]) = an;
        
        %Displays which N is finished
        rats(k).name 
    end
 end