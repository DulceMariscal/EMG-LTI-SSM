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
opts.indD=[1:2];
opts.indB=[1,3];
Uf=[U;ones(size(U));zeros(1,149),1,zeros(1,899),1,zeros(1,600)]; %RAMP STARTING AT STRIDE 151 (Adaptation)
model=cell(maxOrder+1,1);
for order=0:maxOrder
   tic
   if order==0 %Flat model
    [J,B,C,D,Q,R]=getFlatModel(Yasym',Uf);
    name='Flat'; P=[]; logL=[]; outLog=[];
   else %Identify
    [fAh,fBh,fCh,D,fQh,R,fXh,fPh,logL,outLog]=randomStartEM(Yasym',Uf,order,10,opts); %Slow/true EM
    [J,B,C,X,~,Q,P] = canonize(fAh,fBh,fCh,fXh,fQh,fPh);
    name=['EM (' num2str(order)];
   end
   model{order+1}=autodeal(J,B,C,D,Q,R,P,logL,outLog);
   model{order+1}.name=[name ', all data, w/startle'];
   model{order+1}.runtime=toc;
end

%% Save (to avoid recomputing in the future)
save ../res/withStartleInput.mat model Yasym Uf

%% Viz:
vizDataFit(model(2:6),Yasym',Uf)
vizDataRes(model(2:6),Yasym',Uf)

%% Is the startle input worth it?
load ../res/withStartleInput.mat
wStartle=model;
load ../res/oddEvenCV.mat model
noStartle=model(:,3);
%%
order=4;
[expandedModels,expandedInputs]=matchModelInputs([wStartle(order+1); noStartle(order+1)],{Uf; Uf(1:2,:)});
vizDataFit(expandedModels,Yasym',expandedInputs)
vizDataRes(expandedModels,Yasym',expandedInputs)
