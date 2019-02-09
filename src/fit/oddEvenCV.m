%%
addpath(genpath('../../matlab-linsys/'))
addpath(genpath('../../robustCov/'))
%%
clear all
%% Load real data:
sqrtFlag=false;
subjIdx=[2:6,8,10:16]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post), C16 has bad first trial of Adaptation (not included)
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag);

%% Get folded data
CVfolds=2; %Number of folds for cross-validation: 2=odd/even strides
[trainData] = foldSplit(Yasym,CVfolds);
trainData{end+1}=Yasym; %All data
%% Fit Models
maxOrder=6; %Fitting up to 6 states
%Opts for indentification:
opts.robustFlag=false;
opts.outlierReject=false;
opts.fastFlag=true; %Cannot do fast for NaN filled data, disable here to avoid a bunch of warnings.
opts.logFlag=true;
opts.indD=[];
opts.indB=1;
Uf=[U;ones(size(U))];
model=cell(maxOrder+1,CVfolds+1);
for i=1:CVfolds+1
   for order=0:maxOrder
       tic
       if order==0 %Flat model
        [J,B,C,D,Q,R]=getFlatModel(trainData{i}',Uf);
        name='Flat'; P=[]; logL=[]; outLog=[];
       else %Identify
        [fAh,fBh,fCh,D,fQh,R,fXh,fPh,logL,outLog]=randomStartEM(trainData{i}',Uf,order,20,opts); %Slow/true EM
        [J,B,C,X,~,Q,P] = canonize(fAh,fBh,fCh,fXh,fQh,fPh);
        name=['EM (' num2str(order)];
       end
       model{order+1,i}=autodeal(J,B,C,D,Q,R,P,logL,outLog);
       if i<=CVfolds
           model{order+1,i}.name=[name ', CV' num2str(i)];
       else
           model{order+1,i}.name=[name ', all data'];
       end
       model{order+1,i}.runtime=toc;
   end
end
%% Save (to avoid recomputing in the future)
save ../res/oddEvenCV.mat model Yasym Uf
%% To load (if necessary):
load ../res/oddEvenCV.mat
CVfolds=2; %Number of folds for cross-validation: 2=odd/even strides
[trainData] = foldSplit(Yasym,CVfolds);
trainData{end+1}=Yasym; %All data
%% Compare odd/even/all models using all data
order=5;
vizDataFit(model(order+1,:),Yasym',Uf)
%% Compare full data models of different orders using all data:
vizDataFit(model(2:end,3),Yasym',Uf)
%% Compare cross-validated results:
vizDataFit(model(2:end,1),trainData{2}',Uf) %Trained on odd, tested on even
vizDataFit(model(2:end,2),trainData{1}',Uf) %Trained on even, tested on odd
