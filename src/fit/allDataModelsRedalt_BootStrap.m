%%
addpath(genpath('../../../EMG-LTI-SSM/'))
addpath(genpath('../../../matlab-linsys/'))
addpath(genpath('../../../robustCov/'))
%%
clear all
%% Load real data:
tic
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

%% Load real data: Bootstraping
sqrtFlag=false;
subjIdx=[2:6,8,10:15]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post), C16 (missed first trial of Adapt)

clear datSet
n=1000; %number of iterations
 for i=1:n
Bt_Sub=datasample(subjIdx,12,'Replace',true);
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(Bt_Sub,sqrtFlag);
datSet{i}=dset(Uf,Yasym');
 end 

%% Fit Models
maxOrder=3;%6; %Fitting up to 10 states
%Opts for indentification:
opts.robustFlag=false;
opts.outlierReject=false;
opts.fastFlag=200; %Cannot do fast for NaN filled data, disable here to avoid a bunch of warnings.
opts.logFlag=true;
opts.indD=[];
opts.indB=1;
opts.Nreps=20;
opts.stableA=true;
%opts.fixR=median(s(~flatIdx))*eye(size(datSetRed.out,1)); %R proportional to eye
%opts.fixR=corrMat(~flatIdx,~flatIdx); %Full R
opts.fixR=[]; %Free R
opts.includeOutputIdx=find(~flatIdx); 
[modelRed]=linsys.id(datSet1, maxOrder,opts);
toc
%% Save (to avoid recomputing in the future)
nw=datestr(now,'yyyymmddTHHMMSS');
% save(['../../res/allDataRedAltIndivs_' nw '.mat'],'modelRed', 'datSet', 'opts');
save(['allDataRedAlt_BootStrap_',num2str(n) ,'_', nw '.mat'],'modelRed', 'datSet', 'opts');


%%
% load ../../res/allDataRedAltIndivs_20190710T003814.mat

%% For each subj, do the BIC:
for j=1:12
    j
    b(:,j)=cellfun(@(x) x.BIC,modelRed(:,j));
%     taus=-1./log(eig(modelRed{3,j}.A));
    taus=-1./log(eig(modelRed{1,j}.A))
end
%% Compare models
for i=2:12
modelRed{i}.name=num2str(i-1);
end
fittedLinsys.compare(modelRed(1:11))
set(gcf,'Units','Normalized','OuterPosition',[.4 .7 .6 .3])
% saveFig(gcf,'../../fig/','allDataModelsRedAltCompare',0)
%% visualize structure
modelRed2=cellfun(@(x) x.canonize,modelRed,'UniformOutput',false);
% datSet.vizFit(modelRed2(1:11))
datSet{1}.vizFit(modelRed2(1:11))
%%
% linsys.vizMany(modelRed2(2:6))
linsys.vizMany(modelRed2(1:12))