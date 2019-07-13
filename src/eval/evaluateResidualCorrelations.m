%%
addpath(genpath('../../../matlab-linsys/'))
addpath(genpath('../../../'))
%%
clear all
load ../../res/allDataRedAlt_20190510T175706.mat
%% Select model order
ord=3;
mdl=modelRed{ord+1};

%% Make a pretty plot of the model's characteristics
mdl=mdl.canonize('canonicalAlt');
k=sqrt(sum(mdl.D(:,1).^2));
mdl=mdl.scale(1/k); %Scaling C so that the columns add up to the same as the first column of D
%This results in better scaling for visualization, but is completely
%arbitrary and changes nothing

%% 1: evaluate correlations between state and obs noise
%This should be done with care: the effects of breaks probably dominate
%some of the estimated noises. Further, transient effects may also play a
%role. Perhaps it would be optimal to only consider steady-state values?
df=mdl.fit(datSet);
on=df.obsNoise;
sn=df.stateNoise;
S=(sn*on(:,1:end-1)')/size(sn,2); %Empirical covariance

%Some stats on how likely the correlations observed are:
rho=nan(size(S));
pval=nan(size(S));
for i=1:size(S,1)
    for j=1:size(S,2)
        [rho(i,j),pval(i,j)]=corr(sn(i,:)',on(j,1:end-1)');
    end
end
figure; histogram(pval(:),0:.01:1)
figure; 
for i=1:3
subplot(1,4,i); imagesc(reshape(-log10(pval(i,:))>3,12,15)');
end
subplot(1,4,4); imagesc(reshape(var(on'),12,15)')


%Idea: given a model using the exogneous input to drive the system:
%1) get rid of the feedthrough term by shifting outputs by D*u, and setting
%D=0
%2) Define e=u-H*y=u-H*(C*x+w), where H is an arbitrarily defined matrix
%3) Compute new values for A,B,Q that result in the same output

%Define new model: start by removing the feedthrough term from
%consideration
ds2=datSet;
ds2.out=ds2.out-mdl.D*ds2.in; %Removing the feedthrough term
mdl2=mdl;
mdl2.D=zeros(size(mdl2.D));
mdl.logL(datSet)-mdl2.logL(ds2) %Checking that log-L does not change

%Find params for maximally decorrelated 
invR=inv(mdl.R);
SinvR=S*invR;
oldB=mdl.B(:,1);
H=-oldB\SinvR;
newS=(SinvR+oldB*H)*mdl.R; %This reduces the rank of S by one. It will be in general not possible to make it exactly 0.
newS(isnan(newS))=0;
newB=oldB;
mdl2.A=mdl.A+newB*H*mdl.C;
RR=mdl.R;
RR(isinf(RR))=0; %Necessary to compute the product
mdl2.Q=mdl.Q+ newB*H*S' + S*H'*newB' + newB*H*RR*H'*newB'; %This should be PSD. Enforce?
mdl2.B=newB;
mdl2.D=zeros(size(mdl.D(:,1)));
%mdl2.Q=mdl.Q+newS*invR*newS'-S*invR*S'; %If my math is right, this should be equivalent.
ds2.in=datSet.in(1,:)-H*ds2.out; %e=u-Hy

%error('This does not work, revise math')

%Check new log-L: (should improve, because of smaller unexplained state
%innovation)
mdl2.logL(ds2) %Does not improve, why?

%Check new empirical S:
df2=mdl2.fit(ds2);
on2=df2.obsNoise;
sn2=df2.stateNoise;
S2=sn2*on2(:,1:end-1)' /size(sn2,2); %Should be the same as newS

%Find params for maximally decorrelated 


%
%sn=sn./(sqrt(size(sn,2)-1)*std(sn')');
%on=on./(sqrt(size(on,2)-1)*std(on')'); %Normalizing for this analysis
%H=sn*on(:,1:end-1)'; %Correlation matrix

%% 2: evaluate auto-correlations (spectrum) in obs noise


%% 3: evaluate auto-corr (spectrum) in state noise


%%

%export_fig ../../fig/3stateModelResiduals.png -png -c[0 5 0 5] -transparent -r100