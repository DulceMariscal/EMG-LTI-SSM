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

%% Split dset
ss=datSet.split(find(Ubreaks));
%% Reduce data
Y=datSet.out;
U=datSet.in;
X=Y-(Y/U)*U; %Projection over input
s=var(X'); %Estimate of variance
flatIdx=s<.005; %Variables are split roughly in half at this threshold

%% Fit Models
maxOrder=6; %Fitting up to 10 states
%Opts for indentification:
opts.robustFlag=false;
opts.outlierReject=false;
opts.fastFlag=200;
opts.logFlag=true;
opts.indD=[];
opts.indB=1;
opts.Nreps=20;
opts.stableA=true;
%opts.fixR=median(s(~flatIdx))*eye(size(datSetRed.out,1)); %R proportional to eye
%opts.fixR=corrMat(~flatIdx,~flatIdx); %Full R
opts.fixR=[]; %Free R
opts.includeOutputIdx=find(~flatIdx); 
[modelRed]=linsys.id(datSet,0:3,opts);
%% Save (to avoid recomputing in the future)
nw=datestr(now,'yyyymmddTHHMMSS');
save(['../../res/allDataRedAltBroken_' nw '.mat'],'modelRed', 'datSet', 'opts');

%%
%load('/Datos/Documentos/code/EMG-LTI-SSM/res/allDataRedAlt_20190425T210335.mat')
%% For each block, get the smoothed/MLE state estimate
ord=3;
figure;
hold on
x1=0;
modelRed{ord}=modelRed{ord}.canonize;
for i=1:length(ss)
    mleState{i}=modelRed{ord}.Ksmooth(ss{i});
    if i==1
        iC=[];
    else
        iC=dsstate.getSample(dsstate.Nsamp);
        iC=mleState{i}.getSample(1);
    end
    [dsout,dsstate]=modelRed{ord}.simulate(ss{i}.in,iC,true,true); %Deterministic simulation from last point
    mleState{i}.plot(x1);
    hold on
    %dsstate.plot(x1)
    %To do: add taus in legend

    x1=x1+mleState{i}.Nsamp;
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
datSet.vizFit(modelRed2(1:11))
%%
linsys.vizMany(modelRed2(2:6))