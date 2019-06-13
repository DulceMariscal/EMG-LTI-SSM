%% Load data and fitted model
clear all
load('/Datos/Documentos/code/EMG-LTI-SSM/res/allDataRedAlt_20190425T210335.mat')
%% Vary R by scaling, compute logL
ord=3;
m=modelRed{ord+1};
R=m.R;
figure
hold on
N=datSet.Nsamp;
d=datSet.Noutput;
l1=m.logL(datSet);
for k=.5:.1:2
    m.R=k*R;
    l=m.logL(datSet);
    plot(log2(k),l,'kx')
    %(l-l1)/(N*d*(k-1-log(k)))
    plot(log2(k),l1-.25*N*d*(k-1-log(k)),'ko')
    %plot(log(k),l1-.25*N*d*(.5*(k-1)^2-.6667*(k-1)^3),'k*')
end
