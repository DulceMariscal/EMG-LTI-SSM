%%
addpath(genpath('../../matlab-linsys/'))
%%
clear all
%% Load real data:
sqrtFlag=false;
subjIdx=[2:6,8,10:16]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post).
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag);

%% Fit Models
maxOrder=5; %Fitting up to 3 states
%Opts for indentification:
opts.robustFlag=false;
opts.outlierReject=false;
opts.fastFlag=true; %Cannot do fast for NaN filled data, disable here to avoid a bunch of warnings.
opts.logFlag=true;
opts.indD=[];
opts.indB=1;
Uf=[U;ones(size(U));zeros(1,1050),ones(1,600)];
model=cell(maxOrder+1);
for order=0:maxOrder
   tic
   if order==0 %Flat model
    [J,B,C,D,Q,R]=getFlatModel(Yasym',Uf);
    name='Flat'; P=[]; logL=[]; outLog=[];
   else %Identify
    [fAh,fBh,fCh,D,fQh,R,fXh,fPh,logL,outLog]=randomStartEM(Yasym',Uf,order,10,opts); %Slow/true EM
    [J,B,C,X,~,Q,P] = canonize(fAh,fBh,fCh,fXh,fQh,fPh);
    name=['EM(' num2str(order) ')'];
   end
   model{order+1}=autodeal(J,B,C,D,Q,R,P,logL,outLog);
   model{order+1}.name=[name ', all data, w/postOffset'];
   model{order+1}.runtime=toc;
end

%% Save (to avoid recomputing in the future)
save ../res/withPostOffset.mat model Yasym Uf
