addpath(genpath('../../matlab-linsys/'))
addpath(genpath('../../robustCov/'))
clearvars
%% Load models:
load ../res/oddEvenCV.mat
noRamp=model(:,3);
load ../res/withRampInput.mat
simpleRamp=model;
srIn=Uf;
nrIn=Uf(1:2,:);
load ../res/withRampInputALT.mat
shortRamp=model;
shIn=Uf;
load ../res/withPostOffset.mat
postOff=model;
poIn=Uf;
models=[simpleRamp shortRamp noRamp(2:end,:) postOff(:,1)];
%% Put the no-ramp models in equal footing to Compare
order=3;
[expandedModels,expandedInputs]=matchModelInputs(models(order+1,:),{srIn,shIn,nrIn,poIn});
vizModels(expandedModels)
vizDataFit(expandedModels,Yasym',expandedInputs)
%for i=1:length(noRamp)
%noRamp{i}.B=[noRamp{i}.B zeros(size(noRamp{i}.B,1),1)];
%noRamp{i}.D=[noRamp{i}.D zeros(size(noRamp{i}.D,1),1)];
%end
%% Compare

%vizModels([simpleRamp(order+1) shortRamp(order+1) noRamp(order+2)])
%%
%order=3;
%vizDataFit([simpleRamp(order+1) shortRamp(order+1) noRamp(order+2)],Yasym',Uf)
