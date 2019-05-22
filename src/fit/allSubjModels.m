%%
addpath(genpath('../../../EMG-LTI-SSM/'))
addpath(genpath('../../../matlab-linsys/'))
addpath(genpath('../../../robustCov/'))
%%
clear all
%% Load real data:
sqrtFlag=false;
subjIdx=[2:6,8,10:15]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post), C16 (missed first trial of Adapt)
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToCellForm(subjIdx,sqrtFlag);
Uf=[U;ones(size(U))];
datSetSep=cellfun(@(x) dset(Uf,x),Yasym,'UniformOutput',false);
datSetTog=dset(Uf,Yasym);

%% Get grouped data to identify flat variables at group level
[~,Yasym,~,~,~]=groupDataToMatrixForm(subjIdx,sqrtFlag);
datSet=dset(Uf,Yasym');
Y=datSet.out;
U=datSet.in;
X=Y-(Y/U)*U; %Projection over input
s=var(X'); %Estimate of variance
flatIdx=s<.005; %Variables are split roughly in half at this threshold
%% Fit Models
%Opts for indentification:
opts.robustFlag=false;
opts.outlierReject=false;
opts.fastFlag=100; %Cannot do fast for NaN filled data, disable here to avoid a bunch of warnings.
opts.logFlag=true;
opts.indD=[];
opts.indB=1;
opts.Nreps=5;
opts.stableA=true;
opts.refineMaxIter=1e4; %More iters, to guarantee convergence
defaultOpts.refineTol=1e-5; % Lower tol, seems to end suddenly for the 'together' case

[modelSep]=linsys.id(datSetSep,0:4,opts); %This fits all cells  in datSet independently, not through a single model
modelTog=linsys.id(datSetTog,1:4,opts); %Fits a single model for all subjs

%% Save (to avoid recomputing in the future)
nw=datestr(now,'yyyymmddTHHMMSS');
save(['../../res/allSubjModels_' nw '.mat'],'modelTog','modelSep','datSetSep','datSetTog', 'opts');

%%
%fittedLinsys.compare(model(1:end))