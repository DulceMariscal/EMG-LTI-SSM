%%
addpath(genpath('../../matlab-linsys/'))
%%
clear all
%% Load real data:
sqrtFlag=false;
subjIdx=[2:6,8,10:15]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post).
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag);

%% Get folded data
CVfolds=2; %Number of folds for cross-validation: 2=odd/even strides
trainData{1}=Yasym(1:750,:);
trainData{2}=Yasym(901:end,:);
Uf{1}=[U(1:750);ones(1,750)];
Uf{2}=[U(901:end);ones(1,750)];
datSet{1}=dset(Uf{1},trainData{1}');
datSet{2}=dset(Uf{2},trainData{2}');

%% Fit Models
maxOrder=6; %Fitting up to 6 states
%Opts for indentification:
opts.robustFlag=false;
opts.outlierReject=false;
opts.fastFlag=100; %Enforcing fast filter after 100 samples (except for refinement stage). May not be a great idea, but will be fast!
%Because we are doing EM, it is to be *expected* that initial state
%estimation uncertainty converges to the steady-state filter/smoother uncertainty
%value, so the fast filter becomes almost exact, and there is no loss in
%precision by doing this. The convergence would need to be proved.
warning('statKSfast:fewSamples','off') %This is needed to avoid a warning bombardment
opts.logFlag=true;
opts.indD=[];
opts.indB=1;
opts.Nreps=20;

model=cell(maxOrder+1,CVfolds);
logs=cell(maxOrder+1,CVfolds);
nameSuffix={'First 750 train','last 750 train'};
for i=1:CVfolds
   for order=0:maxOrder
       [mdl,outlog]=linsys.id(datSet{i},order,opts);
       model{order+1,i}=mdl;
       logs{order+1,i}=outlog;
   end
end
%% Save (to avoid recomputing in the future)
save ../../res/logs/adaptPostCV.mat logs
save ../../res/adaptPostCV.mat model datSet