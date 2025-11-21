function PhotometryAnalysis(source,TRANGE,savename,normalization,BL)
    STREAM_STORE1 = 'x65S';
    STREAM_STORE2 = 'x05S';
if isfield(source.streams,STREAM_STORE1) == 0 %check which version we are using
    STREAM_STORE1 = 'x654';
    STREAM_STORE2 = 'x054';
end

%samples are sometimes off by 1, trim to be equal
minLength1 = min(cellfun('prodofsize', source.streams.(STREAM_STORE2).filtered));
minLength2 = min(cellfun('prodofsize', source.streams.(STREAM_STORE1).filtered));
source.streams.(STREAM_STORE2).filtered = cellfun(@(x) x(1:minLength1), source.streams.(STREAM_STORE2).filtered, 'UniformOutput',false);
source.streams.(STREAM_STORE1).filtered = cellfun(@(x) x(1:minLength2), source.streams.(STREAM_STORE1).filtered, 'UniformOutput',false);

allSignals = cell2mat(source.streams.(STREAM_STORE2).filtered');

%downsample 10x by averaging N samples
N = 10;
allSignals = cell2mat(source.streams.(STREAM_STORE2).filtered');
F405 = zeros(size(allSignals(:,1:N:end-N+1)));
for ii = 1:size(allSignals,1)
    F405(ii,:) = arrayfun(@(i) mean(allSignals(ii,i:i+N-1)),1:N:length(allSignals)-N+1);
end
minLength1 = size(F405,2);

% Create mean signal, standard error of signal, and DC offset of 405 signal
meanSignal1 = mean(F405);
stdSignal1 = std(double(F405))/sqrt(size(F405,1));
dcSignal1 = mean(meanSignal1);

%same for 474 channel
allSignals = cell2mat(source.streams.(STREAM_STORE1).filtered');
F474 = zeros(size(allSignals(:,1:N:end-N+1)));
for ii = 1:size(allSignals,1)
    F474(ii,:) = arrayfun(@(i) mean(allSignals(ii,i:i+N-1)),1:N:length(allSignals)-N+1);
end
minLength2 = size(F474,2);

meanSignal2 = mean(F474);
stdSignal2 = std(double(F474))/sqrt(size(F474,1));
dcSignal2 = mean(meanSignal2);

% make a timerange, fit the trials
ts1 = TRANGE(1) + (1:minLength1) / source.streams.(STREAM_STORE2).fs*N;
ts2 = TRANGE(1) + (1:minLength2) / source.streams.(STREAM_STORE1).fs*N;

% Subtract DC offset to get signals on top of one another
meanSignal1 = meanSignal1 - dcSignal1;
meanSignal2 = meanSignal2 - dcSignal2;

%index specified normalization times, grab 474 and 405 data
idxNorm = ts2(1,:) < normalization(2) & ts2(1,:) > normalization(1);
F474Norm=F474(:,idxNorm);
F405Norm=F405(:,idxNorm);

%for every trial, subtract the linear fit of 405 data onto 474 data within the
%normalization period from the raw 474 data
for i = 1:size(F474,1)
    mxbNorm(i,1:2) = polyfit(F405Norm(i,1:end), F474Norm(i,1:end), 1);
    Y_fit_all(i,:) = mxbNorm(i,1) .* F405(i,:) + mxbNorm(i,2);
    Y_dF_all(i,:) = F474(i,:) - Y_fit_all(i,:); %dF (for dF/F divide by fit)
end

%z-score based on normalization period mean and sd
zall = zeros(size(Y_dF_all));
tmp = 0;
zbsave=[];
zsdsave=[];
for i = 1:size(Y_dF_all,1)
    zb = mean(Y_dF_all(i,idxNorm)); % normalization period mean
    zbsave(end+1,:)=zb;
    zsd = std(Y_dF_all(i,idxNorm)); % normalization period stdev
    zsdsave(end+1,:)=zsd;
    for j = 1:size(Y_dF_all,2) % Z score per bin
        tmp = tmp + 1;
        zall(i,tmp)=(Y_dF_all(i,j) - zb)/zsd;
    end
    tmp=0;
end

% Standard error of the z-score
zerror = std(zall)/sqrt(size(zall,1));

% Plot heat map
subplot(2,1,1)
imagesc(ts2, 1, zall);
colormap('jet'); 
c1 = colorbar; lims=caxis; set(c1,'Position',[0.913333336737305,0.582857142857143,0.038095238095239,0.339047619047619]);
ylabel('Trials', 'FontSize', 12);
set(gca,'xtick',[])

% Fill band values for second subplot. Doing here to scale onset bar correctly
XX = [ts2, fliplr(ts2)];
YY = [mean(zall)-zerror, fliplr(mean(zall)+zerror)];

subplot(2,1,2)
plot(ts2, mean(zall), 'color',[0.4660, 0.6740, 0.1880], 'LineWidth', 3); hold on;
line([0 0], [min(YY), max(YY)], 'color', [.7 .7 .7], 'LineWidth', 2)
if size(YY,1) > 1
    h = fill(XX, YY, 'r');
    set(h, 'facealpha',.25,'edgecolor','none')
end
limz=ylim;

% Finish up the plot
axis tight
xlabel('Time, s','FontSize',12)
ylabel('Z-score', 'FontSize', 12)
title(savename, 'FontSize', 12);

%save ts2(timeline) zall(trial-by-trial) mean zerror
if size(zerror,2) > 1
    saveddata=[ts1;zall;mean(zall);zerror];
else %fixes an error when there is only one trial and hence no mean or error calculated
    spacer=[];
    spacer(1:size(zall,2))=NaN;
    saveddata=[ts1;zall;spacer;spacer];
end

dlmwrite([savename '.txt'],saveddata,'delimiter','\t');
print('-djpeg','-r300',[savename '.jpg']);

%these data quantify in several ways a few epochs (mean median max min AUC)
%for stat baseline, at initial event, and around mid event
tmpmean=mean(zall);
ind = ts2(1,:) <= BL(2)& ts2(1,:) >= BL(1); 
baselinequant=[mean(tmpmean(1,ind)) median(tmpmean(1,ind)) max(tmpmean(1,ind)) min(tmpmean(1,ind)) trapz(tmpmean(1,ind))]; % statistical baseline period stats
ind2 = ts2(1,:) <= 5 & ts2(1,:) >= 0; %first half of event
eventquant=[mean(tmpmean(1,ind2)) median(tmpmean(1,ind2)) max(tmpmean(1,ind2)) min(tmpmean(1,ind2)) trapz(tmpmean(1,ind2))]; % initial event period stats
ind3 = ts2(1,:) <= 10 & ts2(1,:) >= 5; %second half of event
mideventquant=[mean(tmpmean(1,ind3)) median(tmpmean(1,ind3)) max(tmpmean(1,ind3)) min(tmpmean(1,ind3)) trapz(tmpmean(1,ind3))]; % mid-event period stats
quant=[baselinequant eventquant mideventquant];
dlmwrite([savename '-quant.txt'],quant,'delimiter','\t');
close all