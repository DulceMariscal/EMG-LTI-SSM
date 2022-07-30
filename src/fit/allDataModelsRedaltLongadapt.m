%%
% addpath(genpath('../../../EMG-LTI-SSM/'))
% addpath(genpath('../../../matlab-linsys/'))
% addpath(genpath('../../../robustCov/'))
%%
clear all
%% Load real data:
sqrtFlag=false;
subjIdx=0; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post), C16 (missed first trial of Adapt)
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixFormLongAdapt(subjIdx,sqrtFlag);
% [Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixFormLongAdaptSLA(subjIdx,sqrtFlag);
Uf=[U;ones(size(U))];
% Uf=[U];
datSet=dset(Uf,Yasym');

%% Reduce data
Y=datSet.out;
U=datSet.in;
X=Y-(Y/U)*U; %Projection over input
s=var(X'); %Estimate of variance
flatIdx=s<.005; %Variables are split roughly in half at this threshold
 

%% Fit Models
maxOrder=4; %Fitting up to 10 states
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
[modelRed]=linsys.id(datSet, 0:maxOrder,opts);
%% Save (to avoid recomputing in the future)
nw=datestr(now,'yyyymmddTHHMMSS');
% save(['../../res/allDataRedAltIndivs_' nw '.mat'],'modelRed', 'datSet', 'opts');
save(['allDataRedAlt_' nw '.mat'],'modelRed', 'datSet', 'opts');


%%
% load ../../res/allDataRedAltIndivs_20190710T003814.mat

%% For each subj, do the BIC:
for j=1:maxOrder
    j
    b(:,j)=cellfun(@(x) x.BIC,modelRed(j));
%     taus=-1./log(eig(modelRed{3,j}.A));
    taus{j}=-1./log(eig(modelRed{j}.A));
end
%% Compare models
% for i=1:maxOrder
% modelRed{i}.name=num2str(i-1);
% end
maxOrder=length(modelRed);
fittedLinsys.compare(modelRed(1:maxOrder))
set(gcf,'Units','Normalized','OuterPosition',[.4 .7 .6 .3])
% saveFig(gcf,'../../fig/','allDataModelsRedAltCompare',0)
%% visualize structure
modelRed2=cellfun(@(x) x.canonize,modelRed,'UniformOutput',false);
datSet.vizFit(modelRed2(1:maxOrder))
% datSet.vizFit(modelRed{1})
%%
linsys.vizMany(modelRed2(1:maxOrder))
% linsys.vizMany(modelRed{1})
%%
maxOrder=length(modelRed);
for  j=1:maxOrder
legacy_vizSingleModelMLMC(modelRed{j},datSet.out,datSet.in)
end


