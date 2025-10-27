%dF signal on a per frame basis
x=signal{k,1};

%Logic for if 0 is wheel or stress dependent 
%Then looks at whether 0 is onset or offset
if norm == false
    ev=intervalStressW;
    x1 = trig_lfpBase(signal{k,1}, ev, window);
else
    x1 = trig_lfpBase(signal{k,1}, evts{k,:}(stressInt,1), window);
    if onset == true  
        ev=evts{k,:}(:,1);
    else
        ev=evts{k,:}(:,3);  
    end
end

%Gets mean and stdev of prestress baseline to use for zscoring dF signal
m = mean(x1,2);
s = std(x1,[],2);

% For row location in loops
z=1;

%Loop for zscoring each trial
for r=stressInt

    %Sets first frame of window (frame at 0 - window size)  
    w=ev(r)-window;
   
    %Zscore loop for each frame in a trial
    for c= 1:wintot
        
        %Zscores each frame for each trial for ZscoreMeanShock output
        setZscore {k,c}(z,1) = (x(w)-m(z))/s(z);

        %Zscores each frame for each trial for heatmap output
        an(z,c) =(x(w)-m(z))/s(z);
        
        %Increase frame by 1
        w=w+1;
    end

    % Increase row by 1
    z=z+1;
end

%Loop for meaning each frame and putting in correct N, frame
for c= 1:wintot
    setZscoreMean (k,c)= mean(setZscore {k,c});
end