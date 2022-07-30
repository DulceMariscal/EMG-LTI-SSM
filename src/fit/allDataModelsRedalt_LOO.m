%%
addpath(genpath('../../../EMG-LTI-SSM/'))
addpath(genpath('../../../matlab-linsys/'))
addpath(genpath('../../../robustCov/'))
%%
clear all
%% Load real data:
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

%% Load real data: Leaving one subject out 
sqrtFlag=false;
subjIdx=[2:6,8,10:15]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post), C16 (missed first trial of Adapt)
idx=[2:12 ;1 3:12 ;1:2 4:12 ;1:3 5:12;1:4 6:12;1:5 7:12; 1:6 8:12; 1:7 9:12; 1:8 10:12; 1:9 11:12;1:10 12;1:11];
% Uf=[U;ones(size(U))];

% datSet2{1}=datSet;
clear datSet
 for i=1:12
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx(idx(i,:)),sqrtFlag);
datSet{i}=dset(Uf,Yasym');
 end 

% datSet=datSet2;

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
[modelRed]=linsys.id(datSet, maxOrder,opts);
%% Save (to avoid recomputing in the future)
nw=datestr(now,'yyyymmddTHHMMSS');
% save(['../../res/allDataRedAltIndivs_' nw '.mat'],'modelRed', 'datSet', 'opts');
save(['allDataRedAlt_LOO_' nw '.mat'],'modelRed', 'datSet', 'opts');


%%
% load ../../res/allDataRedAltIndivs_20190710T003814.mat

%% For each subj, do the BIC:
for j=1:12
    j
    b(:,j)=cellfun(@(x) x.BIC,modelRed(:,j));
%     taus=-1./log(eig(modelRed{3,j}.A));
    taus=-1./log(eig(modelRed{1,j}.A));
end
%% Compare models
for i=2:11
modelRed{i}.name=num2str(i-1);
end
fittedLinsys.compare(modelRed(1:11))
set(gcf,'Units','Normalized','OuterPosition',[.4 .7 .6 .3])
saveFig(gcf,'../../fig/','allDataModelsRedAltCompare',0)
%% visualize structure
modelRed2=cellfun(@(x) x.canonize,modelRed,'UniformOutput',false);
% datSet.vizFit(modelRed2(1:11))
datSet.vizFit(modelRed2(1:3))
%%
% linsys.vizMany(modelRed2(2:6))
linsys.vizMany(modelRed2(1:12))