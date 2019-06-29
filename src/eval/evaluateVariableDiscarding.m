%% Load real data:
sqrtFlag=false;
subjIdx=[2:6,8,10:15]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post), C16 (missed first trial of Adapt)
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag);
Uf=[U;ones(size(U))];
datSet=dset(Uf,Yasym');

%% Split dset
ss=datSet.split(find(Ubreaks),true);
%% Reduce data
Y=datSet.out;
U=datSet.in;
X=Y-(Y/U)*U; %Projection over input
s=var(X'); %Estimate of variance
flatIdx=s<.005; %Variables are split roughly in half at this threshold

%% Visualize:
figure('Name','Histogram of output conditional variances and rejected variables');
subplot(1,2,1)
histogram(s,0:.0005:.04)
hold on
plot(.005*[1 1],[0 40],'k--')
subplot(1,2,2) %Visualize discarded vars
imagesc(reshape(flatIdx==1,12,15)')
title(['Rejected variables, N=' num2str(sum(flatIdx))])
caxis([-1 1])
myFiguresColorMap
colormap(flipud(map))
mList={'TA','PER','SOL','LG','MG','BF','SMB','SMT','VM','VL','RF','HIP','ADM','TFL','GLU'};
set(gca,'YTick',1:15,'YTickLabel',mList(end:-1:1),'XTick',[1,4,7,10],'XTickLabel',{'DS','SINGLE','DS','SWING'});
