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

%% Reduce data
Y=datSet.out;
U=datSet.in;
X=Y-(Y/U)*U; %Projection over input
s=var(X'); %Estimate of variance
flatIdx=s<.005; %Variables are split roughly in half at this threshold
datSetRed=dset(U,Y(~flatIdx,:));

%% Fit Models
maxOrder=6; %Fitting up to 10 states
%Opts for indentification:
opts.robustFlag=false;
opts.outlierReject=false;
opts.fastFlag=true; %Cannot do fast for NaN filled data, disable here to avoid a bunch of warnings.
opts.logFlag=true;
opts.indD=[];
opts.indB=1;
opts.Nreps=5;
corrMat=cov(X');
opts.fixR=median(s(~flatIdx))*eye(size(datSetRed.out,1)); %R proportional to eye
opts.fixR=corrMat(~flatIdx,~flatIdx); %Full R
opts.fixR=[]; %Free R

[modelRed,logs]=linsys.id(datSetRed,0:maxOrder,opts);
%% Save (to avoid recomputing in the future)
save ../../res/allDataModelsRed_freeR.mat modelRed datSetRed logs opts

%%
modelRed=cellfun(@(x) x.canonize('canonical'),modelRed,'UniformOutput',false);
vizDataLikelihood(modelRed,datSetRed)
datSetRed.vizFit(modelRed)
linsys.vizMany(modelRed)