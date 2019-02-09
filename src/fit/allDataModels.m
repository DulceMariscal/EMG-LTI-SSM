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
opts.fastFlag=true; %Cannot do fast for NaN filled data, disable here to avoid a bunch of warnings.
opts.logFlag=true;
opts.indD=[];
opts.indB=1;
opts.Nreps=10;

model=cell(maxOrder+1,1);
logs=cell(maxOrder+1,1);
nameSuffix={'odd train','even train','all data'};
for order=0:maxOrder
    [mdl,outlog]=linsys.id(datSet,order,opts);
    model{order+1}=mdl;
    logs{order+1}=outlog;
end
%% Save (to avoid recomputing in the future)
save ../../res/logs/allDataModels.mat logs
save ../../res/allDataModels.mat model datSet
