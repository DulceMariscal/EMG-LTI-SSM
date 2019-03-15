%%
addpath(genpath('../../../EMG-LTI-SSM/'))
addpath(genpath('../../../matlab-linsys/'))
addpath(genpath('../../../robustCov/'))
%%
clear all
%% Load real data:
sqrtFlag=false;
subjIdx=[2:6,8,10:15]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post), C16 (missed first trial of Adapt)
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag);
Uf=[U;ones(size(U))];
datSet=dset(Uf,Yasym');

%% Fit Models
maxOrder=10; %Fitting up to 10 states
%Opts for indentification:
opts.robustFlag=false;
opts.outlierReject=false;
opts.fastFlag=100; %Cannot do fast for NaN filled data, disable here to avoid a bunch of warnings.
warning('off','statKSfast:fewSamples')
opts.logFlag=true;
opts.diagR=true;
opts.indD=[];
opts.indB=1;
opts.Nreps=10;

model=cell(maxOrder+1,1);
logs=cell(maxOrder+1,1);
[model,logs]=linsys.id(datSet,0:maxOrder,opts);
%% Save (to avoid recomputing in the future)
save ../../res/logs/allDataModels_diagR.mat logs
save ../../res/allDataModels_diagR.mat model datSet
