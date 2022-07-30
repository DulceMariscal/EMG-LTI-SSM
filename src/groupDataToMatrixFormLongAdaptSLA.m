function [Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixFormLongAdaptSLA(subjIdx,sqrtFlag)
%% Load real data:
% fName='dynamicsDataGroupData.h5';  
fName='dynamicsDataYL03.h5'
% fName='dynamicsDataGroupData_Mean.h5';
EMGdata=h5read(fName,'/EMGdata');
SLA=h5read(fName,'/SLA');
speedDiff=h5read(fName,'/speedDiff');
breaks=h5read(fName,'/breaks');
labels=hdf5read(fName,'/labels');

%%
U=speedDiff;
Ubreaks=breaks;

%% Some pre-proc
if nargin<1
    subjIdx=2:16; %Excluding C01 only
end
muscPhaseIdx=1:336; %11 muscles we are not inputting the HIP muscles  
% muscPhaseIdx=1:360; %All muscles
% Y=EMGdata(:,muscPhaseIdx,subjIdx);
%  Y=EMGdata(:,muscPhaseIdx);
% Y=nanmedian(Y,3); %Median across subjs
Y=SLA;
if nargin>1 && sqrtFlag
    Y=sqrt(Y);
end
Yasym=Yasym; %Y-fftshift(Y,2);
Ycom=Y-Yasym;
% Yasym=Yasym(:,1:size(Yasym,2)/2,:);
% Ycom=Ycom(:,1:size(Ycom,2)/2,:);
end
