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
datSet{3}=dset(Uf,Yasym');
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

model=cell(maxOrder+1,CVfolds+1);
logs=cell(maxOrder+1,CVfolds+1);
nameSuffix={'odd train','even train','all data'};
for i=1:CVfolds+1
   for order=0:maxOrder
       if order==0 %Flat model
        [J,B,C,D,Q,R]=getFlatModel(datSet{i}.out,datSet{i}.in); 
        model{order+1,i}=linsys.struct2linsys(autodeal(J,B,C,D,Q,R));
        name=['Flat, ' nameSuffix{i}]; 
       else %Identify
        [model{order+1,i},logs{order+1,i}]=linsys.id(datSet{i},order,opts);
        name=['EM (' num2str(order) '), ' nameSuffix{i}];
       end
   end
end
%% Save (to avoid recomputing in the future)
save ../res/logs/oddEvenCV.mat logs
save ../res/oddEvenCV_.mat model datSet