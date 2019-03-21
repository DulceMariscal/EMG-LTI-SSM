%% Load data
addpath(genpath('../../'))
clear all
sqrtFlag=false;
subjIdx=[2:6,8,10:15]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post), C16 (missed first trial of Adapt)
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag);


%% Add expected observation under some model
load ../../res/allDataModels_fixR.mat
model=cellfun(@(x) x.canonize('canonical'),model,'UniformOutput',false);
mdl=model{5}; %4th order
X=mdl.fit(datSet);
I=eye(size(mdl.A));
z=((mdl.A-I)*X.MLEstate.state+mdl.B*datSet.in);
theoretical=2*trace(mdl.R)+trace(mdl.C*mdl.Q*mdl.C')+diag(z'*mdl.C'*mdl.C*z);


%% t
varY=(sum(diff(datSet.out',[],1).^2,2));
varY(diff(datSet.in(1,:))~=0)=NaN; %Not showing the output changes at input changes
figure
plot(varY)
hold on

[sim]=mdl.simulate(datSet.in,[]); %Simulate model realization
varY=(sum(diff(sim.out',[],1).^2,2));
varY(diff(datSet.in(1,:))~=0)=NaN; %Not showing the output changes at input changes
plot(varY,'r')
plot(theoretical,'k')