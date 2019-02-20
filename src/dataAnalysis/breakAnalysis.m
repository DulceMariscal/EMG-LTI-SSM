%% Load data
addpath(genpath('../../../EMG-LTI-SSM/'))
clear all
sqrtFlag=false;
subjIdx=[2:6,8,10:15]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post), C16 (missed first trial of Adapt)
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag);

%% For each break, compare: avg. of last N strides before break to
%previous N, following (post-break) N

N=7;
idx=find(Ubreaks);
for i=1:length(idx)
    before(:,i)=median(Y(idx(i)-N-1:idx(i)-2,:)); %Last N, exempting very last one
    after(:,i)=median(Y(idx(i)+1:idx(i)+N+1,:)); %First N, exempting very first one
    prev(:,i)=median(Y(idx(i)-2*N:idx(i)-N-1,:)); %Previous N
end

%Norm of difference
sqrt(sum((before(:,2:3)-after(:,2:3)).^2)) %Actual breaks w/o input change
sqrt(sum((before(:,2:3)-prev(:,2:3)).^2)) %Control comparison
sqrt(sum((after(:,2:3)-before(:,3:4)).^2)) %Another control: data after Adapt breaks compared to data before the next break (which we don't expect to be terribly similar, given that adaptation happens)

%Checkerboards of difference
myFiguresColorMap
figure
subplot(1,3,1)
imagesc(reshape(mean(before(:,2:3)-after(:,2:3),2),12,30)')
caxis(.5*[-1 1])
title('Adapt breaks')
colormap(flipud(map))

subplot(1,3,2)
imagesc(reshape(mean(before(:,2:3)-prev(:,2:3),2),12,30)')
caxis(.5*[-1 1])
title('CONTROL (prev N)')
colormap(flipud(map))

subplot(1,3,3)
imagesc(reshape(mean(before(:,2:3)-before(:,3:4),2),12,30)')
caxis(.5*[-1 1])
title('CONTROL (next before)')
colormap(flipud(map))
colorbar
