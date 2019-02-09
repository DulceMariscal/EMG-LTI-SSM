%%
addpath(genpath('../../matlab-linsys/'))
%%
clear all
%% Load real data:
sqrtFlag=false;
subjIdx=[2:6,8,10:16]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post).
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag);

%% Get folded data
CVfolds=2; %Number of folds for cross-validation: 2=odd/even strides
trainData{1}=Yasym(1:750,:);
trainData{2}=Yasym(901:end,:);
Uf{1}=[U(1:750);ones(1,750)];
Uf{2}=[U(901:end);ones(1,750)];
%% Fit Models
maxOrder=4; %Fitting up to 6 states
%Opts for indentification:
opts.robustFlag=false;
opts.outlierReject=false;
opts.fastFlag=true; %Cannot do fast for NaN filled data, disable here to avoid a bunch of warnings.
opts.logFlag=true;
opts.indD=[];
opts.indB=1;

model=cell(maxOrder+1,CVfolds);
for i=1:CVfolds
   for order=0:maxOrder
       tic
       if order==0 %Flat model
        [J,B,C,D,Q,R]=getFlatModel(trainData{i}',Uf{i});
        name='Flat'; P=[]; logL=[]; outLog=[];
       else %Identify
        [fAh,fBh,fCh,D,fQh,R,fXh,fPh,logL,outLog]=randomStartEM(trainData{i}',Uf{i},order,20,opts); %Slow/true EM
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
save ../res/adaptPostCV.mat model Yasym Uf
%% Load data
load ../res/adaptPostCV.mat
trainData{1}=Yasym(1:750,:);
trainData{2}=Yasym(901:end,:);
%% Cross-validated results:
vizDataFit(model(2:end,1),trainData{2}',Uf{2}) %Trained on adapt, tested on post
vizDataFit(model(2:end,2),trainData{1}',Uf{1}) %Trained on post, tested on adapt
%% Training data results: %Suggests 3 states for each dataset, 
%although the states (timeconstants and associated vectors) do not coinicide
vizDataFit(model(2:end,1),trainData{1}',Uf{1}) 
vizDataFit(model(2:end,2),trainData{2}',Uf{2})
%% All data results
vizDataFit(model(2:end,1),Yasym',[U;ones(size(U))]) 
vizDataFit(model(2:end,2),Yasym',[U;ones(size(U))])
%% Compare models:
order=4;
vizModels(model(order+1,:))
%%
order=4;
CD1=[model{order+1,1}.C./sqrt(sum(model{order+1,1}.C.^2)) model{order+1,1}.D./sqrt(sum(model{order+1,1}.D.^2))];
CD2=[model{order+1,2}.C./sqrt(sum(model{order+1,2}.C.^2)) model{order+1,2}.D./sqrt(sum(model{order+1,2}.D.^2))];
CD1'*CD2
%[~,~,a]=pca([CD1 CD2])
trace(model{order+1,1}.Q)
trace(model{order+1,2}.Q)
trace(model{order+1,1}.R)
trace(model{order+1,2}.R)