%%
addpath(genpath('../../matlab-linsys/'))
addpath(genpath('../../robustCov/'))
%%
clear all
%% Load real data:
sqrtFlag=false;
subjIdx=[2:6,8,10:15]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post), C16 (missed first trial of Adapt)
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag);

%% Get folded data
CVfolds=2; %Number of folds for cross-validation: 2=odd/even strides
[trainData] = foldSplit(Yasym,CVfolds);
Uf=[U;ones(size(U))];
datSet{1}=dset(Uf,trainData{1}');
datSet{2}=dset(Uf,trainData{2}');

%% Fit Models
maxOrder=6; %Fitting up to 6 states
%Opts for indentification:
opts.robustFlag=false;
opts.outlierReject=false;
opts.fastFlag=true; %Cannot do fast for NaN filled data, disable here to avoid a bunch of warnings.
opts.logFlag=true;
opts.indD=[];
opts.indB=1;
opts.Nreps=10;

model=cell(maxOrder+1,CVfolds);
logs=cell(maxOrder+1,CVfolds);
nameSuffix={'odd train','even train','all data'};
for i=1:CVfolds
   for order=0:maxOrder
       [mdl,outlog]=linsys.id(datSet{i},order,opts);
       model{order+1,i}=mdl;
       logs{order+1,i}=outlog;
   end
end
%% Save (to avoid recomputing in the future)
save ../res/logs/oddEvenCV_.mat logs
save ../res/oddEvenCV_.mat model datSet
