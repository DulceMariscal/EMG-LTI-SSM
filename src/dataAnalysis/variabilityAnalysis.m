%% Load data
addpath(genpath('../../../EMG-LTI-SSM/'))
clear all
sqrtFlag=false;
subjIdx=[2:6,8,10:15]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post), C16 (missed first trial of Adapt)
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag);

%% t
varY=sqrt(sum(diff(Y,[],1).^2,2));
varY(diff(U)~=0)=NaN; %Not showing the output changes at input changes
figure
plot(varY)
