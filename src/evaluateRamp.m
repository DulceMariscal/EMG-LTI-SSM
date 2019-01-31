%% Load models:
load ../res/oddEvenCV.mat
noRamp=model(:,3);
load ../res/withRampInput.mat
simpleRamp=model;
load ../res/withRampInputALT.mat
shortRamp=model;

%% Compare
order=3;
vizModels([simpleRamp(order+1) shortRamp(order+1)])
vizModels(noRamp(order+2))
%%
order=3;
vizDataFit([simpleRamp(order+1) shortRamp(order+1)],Yasym',Uf)