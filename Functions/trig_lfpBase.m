% INPUT: 
% x: LFP signal (1D or 2D). If 2D, : channels x time
% ev: events to trigger
% d: number of samples before/after (symmetric)
% 
% OUTPUT
% Matrix of trial X prestress dimensions of raw dF (row X column)

function [out,excluded] = trig_lfpBase(x,ev,d)
if nargin<3; d=500; end; % default: 500 samples --> usually 500 ms for 1kHz SR

% Remove the events that fall outside the length of the signal
if isvector(x);
    excluded = (ev-d)<1 | (ev+d)>length(x); %sets frame to exclude frames before and after 
    ev(excluded) = []; %things to be excluded
    out = zeros(length(ev),d); %out array that is set to the have the amount of rows of stress and columns of total frame
    for c=1:length(ev);
        out(c,:) = x(ev(c)-d:ev(c)-1);
    end 
else
    if numel(size(x))==2;
        excluded = (ev-d)<1 | (ev+d)>size(x,2);
        ev(excluded) = [];
        out = zeros(size(x,1),d,length(ev));
        for c=1:length(ev);
            out(:,:,c) = x(:,ev(c)-d:ev(c)-1);
        end
    end
end