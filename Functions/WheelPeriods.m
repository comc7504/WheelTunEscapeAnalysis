function [wStartStress, wLogStress, wStartITI, wLogITI, wEvents] = WheelPeriods(turns, esLog)
% WheelPeriods identifies wheel-turning bouts during stress and ITI periods.
%
% Inputs:
%   turns - TTL voltages from wheel (Nx1 double)
%   esLog - logical array (Nx1) where 1 = stress period, 0 = ITI
%
% Outputs:
%   wStartStress - frame indices of wheel bout starts during stress
%   wLogStress   - logical array marking frames of wheel turning during stress
%   wStartITI    - frame indices of wheel bout starts during ITI
%   wLogITI      - logical array marking frames of wheel turning during ITI
%   wEvents      - all frame indices where wheel turning occurred (stress + ITI)
%
% Notes:
%   A "wheel bout" is defined as a turn (>3V TTL) that occurs after ≥1 s
%   of inactivity, lasting until ≥1 s of no turns are detected.

    % ---- Parameters ----
    fs = 30;              % Frames per second
    turnThresh = 3;       % TTL voltage threshold for wheel movement

    % ---- Initialize logical arrays ----
    wLog = turns > turnThresh;     % 1 = wheel moving
    wLogITI = false(size(wLog));   % frames of ITI wheel bouts
    wLogStress = false(size(wLog));% frames of stress wheel bouts

    % ---- Initialize outputs ----
    wStartStress = [];
    wStartITI = [];
    wEvents = [];

    % ---- Control flags ----
    stopP = false;
    stopWStress = false;
    stopWITI = false;

    % ---- Counters ----
    markStress = 0;
    markITI = 0;

    % ---- Main loop ----
    for i = fs:(numel(wLog) - fs)
        % Detect start of a new wheel bout
        if (wLog(i) && ~stopP && sum(wLog(i-fs+1:i)) == 1)
            stopP = true;

            if esLog(i) == 1
                % Start of stress bout
                markStress = markStress + 1;
                wStartStress(end+1) = i;
                stopWStress = true;
            else
                % Start of ITI bout
                markITI = markITI + 1;
                wStartITI(end+1) = i;
                stopWITI = true;
            end
        end

        % Detect end of a wheel bout (no turns for 1 sec)
        if wLog(i) && stopP && sum(wLog(i:i+fs-1)) == 1
            if stopWStress
                wLogStress(wStartStress(markStress):i) = true;
                stopWStress = false;
            end
            if stopWITI
                wLogITI(wStartITI(markITI):i) = true;
                stopWITI = false;
            end
            stopP = false;
        end
    end

    % ---- Collect all wheel event frames ----
    wEvents = find(wLogStress | wLogITI);
end