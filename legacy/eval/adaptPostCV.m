%% Load real data:
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
%% Get folded data for adapt/post
datSetAP_lP=simDatSet.split([751]); %First half is 1-750, second 751-1650 (second is larger!)
%%
opts.Nreps=20; %Single rep, this works well enough for full (non-CV) data
opts.fastFlag=100;
opts.indB=1;
opts.indD=[];
warning('off','statKSfast:fewSamples') %This is needed to avoid a warning bombardment
[fitMdlAP_lP,outlogAP_lP]=linsys.id([datSetAP_lP],1:6,opts);
%%
save ../../res/adaptPostCV_longPost.mat fitMdlAP_lP outlogAP_lP datSetAP_lP
