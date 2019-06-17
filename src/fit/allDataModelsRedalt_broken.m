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
ssPermuted=ss;
ssPermuted.in=ssPermuted.in([5,4,2,1,3]);
ssPermuted.out=ssPermuted.out([5,4,2,1,3]);
[modelRed(2:maxOrder+1)]=linsys.id(ssPermuted,1:maxOrder,opts);
%% Save (to avoid recomputing in the future)
nw=datestr(now,'yyyymmddTHHMMSS');
save(['../../res/allDataRedAltBroken_' nw '.mat'],'modelRed', 'datSet', 'opts','Ubreaks','flatIdx');

%% Compare continuously fitted model and broken model for estimating blocks individually
clear all
figure;
load ../../res/allDataRedAlt_20190510T175706.mat %Orders from 0 to 6
contModel=modelRed; %Model fitted to data as single block
load ../../res/allDataRedAltBroken_20190616T001216.mat
blockedModel=modelRed; %Model fitted to individual blocks
ss=datSet.split(find(Ubreaks),true);
ord=4; %three-state

for kk=1:2
    switch kk
        case 1
            %Option 1: load the model fitted to the continous data:
            mdl=contModel{ord};
            %ll=modelRed{4}.logL(datSet)
            %ll=modelRed{4}.logL(ss) %Does not work
            ttl='Continuous dataset model fit';
         case 2
             %Option 2: load the model fitted to the broken data:
            mdl=blockedModel{ord};
            %Need to pad,  not sure why it didnt happen at EM time:
            Dpad=datSet.out/datSet.in;
            Dpad=Dpad(flatIdx,:);
            mdl=mdl.pad(flatIdx,Dpad);
            mdl=mdl.canonize('canonicalAlt');
            %Shift states by an arbitrary portion of the inputs
            l1=mdl.logL(ss);
            K=[[3.3;2.15;0],[0;0;.4]];
            mdl.D=mdl.D-mdl.C*K;
            mdl.B=mdl.B-(mdl.A-eye(3))*K;
            %To Do: linsys function that given K makes this transform
            %To Do: linsys function to automate K selection to maximize logL of some
            %target dataset.
            %Check that shift does not change likelihood:
            l2=mdl.logL(ss);
            deltaL=l2-l1 %Should be 0 (numerically)
            ttl='Blocked dataset model fit';
    end
    % For each block, get the smoothed/MLE state estimate
    subplot(2,1,kk)
    hold on
    x1=0;
    mdl=mdl.canonize('canonicalAlt');
    for i=1:length(ss.in) %Each block
        single=ss.extractSingle(i);
        mleState{i}=mdl.Ksmooth(single);
        if i==1
            iC=[];
        else
            iC=dsstate.getSample(dsstate.Nsamp); %Last sample of fit to previous block
            iC=mleState{i}.getSample(1); %First sample of the MLE states
        end
        [dsout,dsstate]=mdl.simulate(single.in,iC,true,true); %Deterministic simulation from last point
        mleState{i}.plot(x1);
        %dsstate.plot(x1)
        %To do: add taus in legend

        x1=x1+mleState{i}.Nsamp;
    end
    title(ttl)
    if kk==2
        xlabel('Strides')
    end
    ylabel('State value (a.u.)')
end

%% Compare model orders for the broken data
load ../../res/allDataRedAltBroken_20190616T001216.mat
for i=2:5
modelRed{i}.name=num2str(i-1);
end
fittedLinsys.compare(modelRed(2:5))
set(gcf,'Units','Normalized','OuterPosition',[.4 .7 .6 .3])
%saveFig(gcf,'../../fig/','allDataModelsRedAltCompare_broken',0)
%% visualize structure
modelRed2=cellfun(@(x) x.canonize,modelRed,'UniformOutput',false);
datSet.vizFit(modelRed2(1:11))
%%
linsys.vizMany(modelRed2(2:6))