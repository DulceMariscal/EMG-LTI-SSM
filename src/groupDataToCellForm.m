function [Y,Yasym,Ycom,U,Ubreaks]=groupDataToCellForm(subjIdx,sqrtFlag)
%% Load real data:
fName='dynamicsData.h5';
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
Y=EMGdata(:,muscPhaseIdx,subjIdx);
if nargin>1 && sqrtFlag
    Y=sqrt(Y);
end
N=size(Y,1);
M=length(muscPhaseIdx);
Ns=length(subjIdx);
Y=reshape(permute(Y,[1,3,2]),N*Ns,M);
Yasym=Y-fftshift(Y,2);
Ycom=Y-Yasym;
Yasym=Yasym(:,1:M/2);
Ycom=Ycom(:,1:M/2);

Y=mat2cell(Y',M,N*ones(Ns,1));
Yasym=mat2cell(Yasym',M/2,N*ones(Ns,1));
Ycom=mat2cell(Ycom',M/2,N*ones(Ns,1));
end
