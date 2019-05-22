%%
addpath(genpath('../../matlab-linsys/'))
addpath(genpath('../../robustCov/'))
addpath(genpath('../../'))
%%
clear all
%% Load real data:
sqrtFlag=false;
subjIdx=[2:6,8,10:15]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post), C16 (missed first trial of Adapt)
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag);
Uf=[U;ones(size(U))];
datSet=dset(Uf,Yasym');
%% Reduce data
Y=datSet.out;
U=datSet.in;
X=Y-(Y/U)*U; %Projection over input
s=var(X'); %Estimate of variance
flatIdx=s<.005; %Variables are split roughly in half at this threshold
%% Get odd/even data
datSetOE=alternate(datSet,2);

%%
opts.Nreps=10;
opts.fastFlag=0; %No fast flag not nan
opts.indB=1;
opts.indD=[];
opts.includeOutputIdx=find(~flatIdx);
opts.stableA=true;
[fitMdlOE,outlogOE]=linsys.id([datSetOE],0:6,opts);

%% Save (to avoid recomputing in the future)
nw=datestr(now,'yyyymmddTHHMMSS');
save(['../../res/OE_CVred_' nw '.mat'],'fitMdlOE', 'outlogOE', 'datSetOE', 'opts');

%% load latest
load ../../res/OE_CVred_20190401T195118.mat
%% Visualize CV log
[fh] = vizCVDataLikelihood(fitMdlOE(:,:),datSetOE([2,1]));
ah=findobj(gcf,'Type','Axes');
ah(2).Title.String={'Odd-model CV'};
ah(2).YAxis.Label.String={'Even-data'; 'log-L'};
ah(2).XTickLabel={'Flat','1','2','3','4','5','6'};
ah(2).XLabel.String='';
ah(1).Title.String={'Even-model CV'};
ah(1).YAxis.Label.String={'Odd-data'; 'log-L'};
ah(1).XTickLabel={'Flat','1','2','3','4','5','6'};
ah(1).XLabel.String='';
set(gcf,'Name','Odd/even cross-validation','Units','Normalized','OuterPosition',[.8 .7 .2 .3]);
saveFig(gcf,'../../fig/','OEcvRed',0)
%% Visualize self-measured BIC
f1=fittedLinsys.compare(fitMdlOE(:,1));
f1.Name='Odd-models goodness-of-fit';
fittedLinsys.compare(fitMdlOE(:,2))