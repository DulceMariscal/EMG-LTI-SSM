%%
addpath(genpath('../../matlab-linsys/'))
addpath(genpath('../../robustCov/'))
addpath(genpath('../../'))
%%
clear all
%% Load real data:
sqrtFlag=false;
subjIdx=[2:6,8,10:15]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post), C16 (missed first trial of Adapt)
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag);
Uf=[U;ones(size(U))];
datSet=dset(Uf,Yasym');
%% Get odd/even data
datSetOE=alternate(datSet,2);
%%
opts.Nreps=1; %Single rep, this works well enough for full (non-CV) data
opts.fastFlag=0; %Patient mode
opts.indB=1;
opts.indD=[];
warning('off','statKSfast:fewSamples') %This is needed to avoid a warning bombardment
[fitMdlOE,outlogOE]=linsys.id([datSetOE],1:6,opts);

%% Save (to avoid recomputing in the future)
save ../../res/oddEvenCV_new.mat fitMdlOE outlogOE datSetOE
