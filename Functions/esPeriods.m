function [y, esLog] = esPeriods(shk_chan)
%
% shk_chan is the TTL volts of escapable shocks
%
esStart = [];
esStop = [];

esLog = zeros(size(shk_chan,1),1);
for i = 1:size(shk_chan,1)
    if shk_chan(i,1) > 3 %TTL volt threshold
        esLog(i,1) = 1;
    end
end
tmp = [diff(esLog); 0]; % Pad end with a zero
for i = 1:size(shk_chan,1)
    if tmp(i) == 1
        esStart = [esStart; (i+1)];
    end
    if tmp(i) == -1
        esStop = [esStop; (i+1)];
    end
end

esDuration = esStop - esStart;
y = [esStart, esDuration, esStop];
end