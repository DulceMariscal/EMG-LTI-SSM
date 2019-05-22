%%
addpath(genpath('../../../matlab-linsys/'))
addpath(genpath('../../../robustCov/'))
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
%% Get folded data for adapt/post
blkSize=55; %Arbitrary size, divides the set into 30 blocks, each transition falls in a different set, but barely
blkSize=11; %This leaves the first ~5 after each transition in a different set.
blkSize=20; %This discards the last 10 samples, leaves the first 10 (exactly) after each transition on a different set
blkSize=100; %This discards last 50, leaves the first 50 (exactly) after each transition on a different set
%blkSize=60;
datSetBlocked=datSet.blockSplit(blkSize,2); 
%%
opts.Nreps=10;
opts.fastFlag=0; %Data includes NaN
opts.indB=1;
opts.indD=[];
opts.stableA=true;
opts.includeOutputIdx=find(~flatIdx);
[fitMdlBlocked,outlogBlocked]=linsys.id([datSetBlocked],0:6,opts);

%% Save (to avoid recomputing in the future)
nw=datestr(now,'yyyymmddTHHMMSS');
save(['../../res/blocked' num2str(blkSize) '_CVred_' nw '.mat'],'fitMdlBlocked', 'outlogBlocked', 'datSetBlocked', 'opts');

%%
load ../../res/blocked20_CVred_20190403T141344.mat
%% Visualize CV log
[fh] = vizCVDataLikelihood(fitMdlBlocked(:,:),datSetBlocked([2,1]));
ah=findobj(gcf,'Type','Axes');
ah(2).Title.String={'Odd-blocks model CV'};
ah(2).YAxis.Label.String={'Even-blocks data'; 'log-L'};
ah(2).XTickLabel={'0','1','2','3','4','5','6'};
ah(2).XLabel.String='';
set(gcf,'Name','Alternating blocks cross-validation');
%% Visualize self-measured BIC
f1=fittedLinsys.compare(fitMdlBlocked(:,1));
f1.Name='Odd-blocks fit';
f2=fittedLinsys.compare(fitMdlBlocked(:,2)); %Can't make it converge to non-singular solutions for some orders
f2.Name='Even-blocks fit';
%% Visualize data fits:
f1=datSetBlocked{2}.vizFit(cellfun(@(x) x.canonize,fitMdlBlocked(2:5,1),'UniformOutput',false));
f1.Name='Odd-blocks model on even-blocks data';
f2=datSetBlocked{1}.vizFit(cellfun(@(x) x.canonize,fitMdlBlocked(2:5,2),'UniformOutput',false));
f2.Name='Even-blocks model on odd-blocks data';