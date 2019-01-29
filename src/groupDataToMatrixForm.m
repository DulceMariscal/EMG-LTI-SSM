function [Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag)
%% Load real data:
fName='../data/dynamicsData.h5';
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
muscPhaseIdx=1:360; %All muscles
Y=nanmedian(EMGdata(:,muscPhaseIdx,subjIdx),3);
if nargin>1 && sqrtFlag
    Y=sqrt(Y);
end
Yasym=Y-fftshift(Y,2);
Ycom=Y-Yasym;
Yasym=Yasym(:,1:size(Yasym,2)/2,:);
Ycom=Ycom(:,1:size(Ycom,2)/2,:);
end
