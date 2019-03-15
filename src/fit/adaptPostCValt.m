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
datSetAP=datSet.split([601,1201]); %First half is 1-600, second 600-1200: kind of symmetric: both have 450 of adapt and 150 of post-transition data
datSetAPalt=datSetAP(1:2); %Discarding strides from 1201 on
datSetAP_lP=datSet.split([751]); %First half is 1-750, second 751-1650 (second is larger!)
%%
opts.Nreps=20; %Single rep, this works well enough for full (non-CV) data
opts.fastFlag=100;
opts.indB=1;
opts.indD=[];
warning('off','statKSfast:fewSamples') %This is needed to avoid a warning bombardment
[fitMdlAP,outlogAP]=linsys.id([datSetAPalt;datSetAP_lP],1:6,opts);
fitMdlAPalt=fitMdlAP(:,1);
fitMdlAP_lP=fitMdlAP(:,2);
outlogAPalt=outlogAP(:,1);
outlogAP_lP=outlogAP(:,2);
%%
save ../../res/adaptPostCValt.mat fitMdlAPalt outlogAPalt datSetAPalt fitMdlAP_lP outlogAP_lP datSetAP_lP
