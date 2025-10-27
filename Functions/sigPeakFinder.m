function [eventcenter] = sigPeakFinder(ESframe, Tstart, Tfinish, sigspotWindow, dF, ESLog, WLog, rats, sig_crit, WITI)

    % Assign "calcium spikes" to photometry signal
    % Requires load_csvs_mvb
    
    % Sampling rate (frames/sec)
    sr = 30;  
    
    % Convert window (sec) to frames
    window_size = sr * sigspotWindow;  % e.g., 15 sec * 30 fps = 450 frames
    
    % Preallocate results container
    eventcenter = cell([size(rats,1) 10]);

    % Sanity check
    if Tfinish >= 101
        error('Please select finish value less than 101');
    end

    % Loop for each rat
    for k = 1:size(rats,1)

        stressLength = Tfinish - Tstart + 1;

        % Find closest start & stop indices safely
        [~, strtIdx] = min(abs(ESframe{k}(:,1) - ESframe{k}(Tstart,1)));
        [~, stpIdx]  = min(abs(ESframe{k}(:,3) - ESframe{k}(Tfinish,3)));


               % --- Bound checking across all signal lengths ---
        maxLen = min([numel(dF{k}), numel(ESLog{k}), numel(WLog{k})]);
        
        strt = max(ESframe{k}(strtIdx,1), 1);
        stp  = min(ESframe{k}(stpIdx,3) + 3000, maxLen);
        
        if strt >= stp
            warning('Rat %d: invalid range (strt=%d >= stp=%d). Skipping...', k, strt, stp);
            continue;
        end
        
        % --- Trim signals safely ---
        eventcenter{k,1} = dF{k}(strt:stp);
        eventcenter{k,2} = ESLog{k}(strt:stp);
        eventcenter{k,3} = WLog{k}(strt:stp);

        % Holders
        n = 1; % positive peaks
        y = 1; % negative peaks

        % Build ITI start/stop times
        for p = Tstart:Tfinish
            if p == numel(ESframe{k}(:,1))
                nextStart = ESframe{k}(p,3) + 2700; % fallback for last trial
            else
                nextStart = ESframe{k}(p+1,1);
            end

            if (nextStart - ESframe{k}(p,3)) > 2700
                eventcenter{k,7}(p-Tstart+1,1) = ESframe{k}(p,3) - strt; % ITI start
                eventcenter{k,7}(p-Tstart+1,2) = ESframe{k}(p,3) + 2700 - strt; % ITI end (90s)
            else
                eventcenter{k,7}(p-Tstart+1,1) = ESframe{k}(p,3) - strt;
                eventcenter{k,7}(p-Tstart+1,2) = nextStart - strt;
            end

            % ITI duration
            eventcenter{k,7}(p-Tstart+1,3) = ...
                eventcenter{k,7}(p-Tstart+1,2) - eventcenter{k,7}(p-Tstart+1,1);
        end

        ITItime = 0;

        % Loop through ITIs
        for j = 1:stressLength-1

            start_index = eventcenter{k,7}(j,1);
            loopTimes = round(eventcenter{k,7}(j,3) / window_size);
            ITItime = ITItime + loopTimes;

            % Iterate across sliding windows
            for f = 1:loopTimes

                slidingStrt = f * window_size - window_size;
                slidingEnd  = f * window_size;

                % Bound check
                if (start_index + slidingEnd) > numel(eventcenter{k,1})
                    continue; % skip incomplete final window
                end

                % Zscore within window
                zsig = zscore(detrend(eventcenter{k,1}(start_index + slidingStrt : start_index + slidingEnd)), 1);

                % Safe peak detection (avoid invalid MinPeakHeight warnings)
                if all(zsig < sig_crit) && all(-zsig < sig_crit)
                    continue;
                end

                % Positive peaks
                [~, plocs] = findpeaks(zsig, ...
                    'MinPeakHeight', sig_crit, ...
                    'MinPeakDistance', sr);  % 30-frame min spacing (~1s)

                % Negative peaks
                [~, nlocs] = findpeaks(-zsig, ...
                    'MinPeakHeight', sig_crit, ...
                    'MinPeakDistance', sr);

                % Check positive peaks
                for t = 1:numel(plocs)
                    idx = plocs(t) + start_index + slidingStrt - 1;
                    if idx <= numel(eventcenter{k,2}) && eventcenter{k,2}(idx) == 0
                        if (WITI && eventcenter{k,3}(idx) == 0) || ~WITI
                            eventcenter{k,4}(n,1) = 1;
                            n = n + 1;
                        end
                    end
                end

                % Check negative peaks
                for t = 1:numel(nlocs)
                    idx = nlocs(t) + start_index + slidingStrt - 1;
                    if idx <= numel(eventcenter{k,2}) && eventcenter{k,2}(idx) == 0
                        if (WITI && eventcenter{k,3}(idx) == 0) || ~WITI
                            eventcenter{k,5}(y,1) = 1;
                            y = y + 1;
                        end
                    end
                end
            end
        end

        % Positive peaks total
        eventcenter{k,4} = sum(eventcenter{k,4}, 'omitnan');

        % Negative peaks total
        eventcenter{k,5} = sum(eventcenter{k,5}, 'omitnan');

        % Total ITI time (seconds)
        eventcenter{k,6} = ITItime * sigspotWindow;

        % Positive peak frequency (Hz)
        eventcenter{k,8} = eventcenter{k,4} / eventcenter{k,6}; 

        % Negative peak frequency (Hz)
        eventcenter{k,9} = eventcenter{k,5} / eventcenter{k,6};

        % Display progress
        fprintf('Finished %s (%.0f ITI windows)\n', rats(k).name, ITItime);
    end
end
