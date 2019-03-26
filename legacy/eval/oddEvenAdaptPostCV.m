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
%% Get folded data for adapt/post
datSetAP=datSet.split([751,901]); %First half is 1-750, last part 901-1650
datSetAP=datSetAP([1,3]); %Discarding the middle part
%%
opts.Nreps=20;
opts.fastFlag=0; %Patient mode
opts.indB=1;
opts.indD=[];
[fitMdl,outlog]=linsys.id([datSetOE,datSetAP],0:6,opts);

fitMdlOE=fitMdl(:,1:2);
fitMdlAP=fitMdl(:,3:4);
outlogOE=outlog(:,1:2);
outlogAP=outlog(:,3:4);

%% Save (to avoid recomputing in the future)
save ../../res/CV.mat fitMdlOE fitMdlAP outlogAP outlogOE datSetOE datSetAP
