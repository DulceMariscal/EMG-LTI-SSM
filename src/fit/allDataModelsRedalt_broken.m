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
ss=datSet.split(find(Ubreaks),true);
%% Reduce data
Y=datSet.out;
U=datSet.in;
X=Y-(Y/U)*U; %Projection over input
s=var(X'); %Estimate of variance
flatIdx=s<.005; %Variables are split roughly in half at this threshold

%% Visualize:
figure('Name','Histogram of output conditional variances and rejected variables');
subplot(1,2,1)
histogram(s,0:.0005:.04)
hold on
plot(.005*[1 1],[0 40],'k--')
subplot(1,2,2) %Visualize discarded vars
imagesc(reshape(flatIdx==1,12,15)')
title(['Rejected variables, N=' num2str(sum(flatIdx))])
caxis([-1 1])
myFiguresColorMap
colormap(flipud(map))
mList={'TA','PER','SOL','LG','MG','BF','SMB','SMT','VM','VL','RF','HIP','ADM','TFL','GLU'};
set(gca,'YTick',1:15,'YTickLabel',mList(end:-1:1),'XTick',[1,4,7,10],'XTickLabel',{'DS','SINGLE','DS','SWING'});

%% Fit Models
maxOrder=4; %Fitting up to 4 states
%Opts for indentification:
opts.robustFlag=false;
opts.outlierReject=false;
opts.fastFlag=false; %Trials are too short to do fast filter
opts.logFlag=true;
opts.indD=[];
opts.indB=1;
opts.Nreps=5; %Does not matter, all reps converge rapidly to the same solution for order=3
opts.stableA=true;
%Refining to get a very precise estimate: needed because each block is
%constant in terms of inputs, so the difference in the likelihood between
%a model with outpu y=C*x+D*u and one with y=C*(x+u) +(D-C)*u, comes solely
%from the dynamics equation, and how well x(k+1)=A*x(k)+B*u(k) compares to
%x(k+1)+u(k+1)=A*(x(k)+u(k)) +B*u(k), and that difference is only a
%function of (I-A)*u(k) [u is constant within blocks], which for all large time constants may be a
%negligible term. Thus, precision matters, a lot.
%A potential post-hoc fix is to change the states by an arbitrary portion
%of u in order to enforce continuity at the condition transitions, and see
%how badly this affects the likelihood. My guess is not much.
%This also speaks to fitting a constant-term in the inpuit: while in theory
%possible, there is only a very small difference between a scale with a
%huge time constant plus a constant offset, and a different constant input
%contribution. Once again, very precise fitting would be needed, and once
%again a possible test is to try to force states to be as close to 0 as
%possible during late baseline or something like that, and see if that
%affects logL too much.
opts.refineTol=1e-5;
opts.refineMaxIter=5e4; %We want a very precise so
%opts.fixR=median(s(~flatIdx))*eye(size(datSetRed.out,1)); %R proportional to eye
%opts.fixR=corrMat(~flatIdx,~flatIdx); %Full R
opts.fixR=[]; %Free R
opts.includeOutputIdx=find(~flatIdx); 
modelRed{1}='';
ssPermuted=ss; %Passing to EM in a random order to make sure that they are not being treated as a sequence.
ssPermuted.in=ssPermuted.in([5,4,2,1,3]);
ssPermuted.out=ssPermuted.out([5,4,2,1,3]);
[modelRed(2:maxOrder+1)]=linsys.id(ssPermuted,1:maxOrder,opts);
%% Save (to avoid recomputing in the future)
nw=datestr(now,'yyyymmddTHHMMSS');
save(['../../res/allDataRedAltBroken_' nw '.mat'],'modelRed', 'datSet', 'opts','Ubreaks','flatIdx');

%% Run evaluate breaks
load ../../res/allDataRedAltBroken_20190616T001216.mat
%%
fittedLinsys.compare(modelRed(2:5))