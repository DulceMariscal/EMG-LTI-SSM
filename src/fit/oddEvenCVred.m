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
%% Reduce data
Y=datSet.out;
U=datSet.in;
X=Y-(Y/U)*U; %Projection over input
s=var(X'); %Estimate of variance
flatIdx=s<.005; %Variables are split roughly in half at this threshold
%% Get odd/even data
datSetOE=alternate(datSet,2);

%%
opts.Nreps=20;
opts.fastFlag=0; %No fast flag not nan
opts.indB=1;
opts.indD=[];
opts.includeOutputIdx=find(~flatIdx);
[fitMdlOE,outlogOE]=linsys.id([datSetOE],0:6,opts);

%% Save (to avoid recomputing in the future)
save ../../res/OE_CVred.mat fitMdlOE outlogOE datSetOE opts

%% Visualize CV logL

%% Visualize self-measured BIC
%for %Each of the four fit sets
%    f(i)= %Generate fig
%end

%Copy all panels onto single fig:
%fh=figure;
