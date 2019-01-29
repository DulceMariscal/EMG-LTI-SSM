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
[trainData] = foldSplit(Yasym,CVfolds);
trainData{end+1}=Yasym; %All data
%% Fit Models
maxOrder=4; %Fitting up to 4 states
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
save ../res/oddEvenCV.mat model Yasym
%% To load (if necessary):
load ../res/oddEvenCV.mat
CVfolds=2; %Number of folds for cross-validation: 2=odd/even strides
[trainData] = foldSplit(Yasym,CVfolds);
trainData{end+1}=Yasym; %All data
%% Compare odd/even/all models using all data
order=1;
vizDataFit(model(order+1,:),Yasym',Uf)
vizModels(model(order+1,:))
%% REmoving constant offset:
for k=1:3 %odd, even, all
    aux=model{2,k};
    %data=trainData{k}';
    data=trainData{k}'-aux.D(:,2);
    aux.D=aux.D(:,1);
    aux.B=aux.B(:,1);
    vizDataFit({aux},data,U)
    set(gcf,'Name',['CV' num2str(k) ', training data'])
end
%%
% %% Test set:
% for k=1:3
%     Yaux=Yf;
%     Yaux(:,k:3:end)=NaN;
%     vizDataFit(model(2:5,4-k),Yaux,Uf)
% set(gcf,'Name',['CV' num2str(4-k) ', testing data'])
% end
% %%All:
% for k=1:3
%     vizDataFit(model(2:5,k),Yf,Uf)
%     set(gcf,'Name',['CV' num2str(k) ', ALL data'])
% end
% %% See models
% for k=1:3
%     vizModels(model(2:5,k))
%     set(gcf,'Name',['CV' num2str(k) ', model viz'])
% end
