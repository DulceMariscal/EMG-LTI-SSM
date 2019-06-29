%% Load data
addpath(genpath('../../'))
clear all
sqrtFlag=false;
subjIdx=[2:6,8,10:15]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post), C16 (missed first trial of Adapt)
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag);


%% Add expected observation under some model
load ../../res/allDataRedAlt_20190510T175706.mat
model=cellfun(@(x) x.canonize('canonical'),modelRed,'UniformOutput',false);
mdl=model{4}; %3rd order
exclude=isinf(diag(mdl.R));
mdl=mdl.excludeOutput(exclude);
datSet=dset(datSet.in,datSet.out(~exclude,:));
X=mdl.fit(datSet);
I=eye(size(mdl.A));
z=((mdl.A-I)*X.stateEstim.state+mdl.B*datSet.in);
theoretical=2*trace(mdl.R)+trace(mdl.C*mdl.Q*mdl.C')+diag(z'*mdl.C'*mdl.C*z); %For the theoretical I should use the expected value of z instead of simulated z

%% Some simulations
allVar=0;
M=1000;
for k=1:M %Many simulations
[sim]=mdl.simulate(datSet.in,[]); %Simulate model realization
varY=(sum(diff(sim.out',[],1).^2,2));
varY(diff(datSet.in(1,:))~=0)=NaN; %Not showing the output changes at input changes
allVar=allVar+varY;
end
%%
varY=(sum(diff(datSet.out',[],1).^2,2));
varY(diff(datSet.in(1,:))~=0)=NaN; %Not showing the output changes at input changes
figure
plot(varY)
hold on

plot(allVar/M,'r')
plot(theoretical,'k')
for j=1:4
pp=plot(300*(j-1)+150*[1 1],[0 10],'Color',.5*ones(1,3));
uistack(pp,'bottom')
end
ax=gca;
ax.XAxis.Limits=[0 1650];

%% A different plot: compute variance for each variable independently, and average the variances
varY=diff(datSet.out',[],1).^2