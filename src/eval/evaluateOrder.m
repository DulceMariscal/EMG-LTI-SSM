addpath(genpath('../../../matlab-linsys/'))
addpath(genpath('../../../robustCov/'))
addpath(genpath('../../'))
%% Load models
clear all
load ../../res/allDataRedAlt_20190510T175706.mat
%load ../../res/old/allDataRedAlt_20190425T210335.mat %This cointains model estimates up to order 10
modelAll=modelRed;
load ../../res/blocked20_CVred_20190403T141344.mat
mdlBlk20=fitMdlBlocked;
dsBlk20=datSetBlocked;
load ../../res/blocked100_CVred_20190425T215717.mat
mdlBlk100=fitMdlBlocked;
dsBlk100=datSetBlocked;
load ../../res/OE_CVred_20190401T195118.mat
mdlBlk1=fitMdlOE;
dsBlk1=datSetBlocked;
load ../../res/AP_CV_20190405T182510.mat
mdlAP=fitMdlAP;
dsAP=datSetAP;
%% Compare relevant metrics for full-data fit
for i=1:length(modelRed)
    modelAll{i}.name=num2str(i-1);
end
fittedLinsys.compare(modelRed)
f1=gcf;
ph=findobj(f1,'Type','Axes');
for i=1:length(ph)
   ph(i).XAxis.Label.String='Model order';
   ph(i).GridLineStyle='none';
end

%% Compare CV log-L
mdlList=[mdlBlk1,mdlBlk20,mdlBlk100,[mdlAP;mdlAP(6,:)]];
namePrefix={'Odd samples','Even samples','Odd blocks [20]','Even blocks [20]','Odd blocks [100]','Even blocks [100]','First half','Second half'};
for i=1:size(mdlList,1)
    for j=1:size(mdlList,2)
        mdlList{i,j}.name=[namePrefix{j} num2str(i-1)];
        D=mdlList{i,j}.D;
        D(isnan(D))=0;
        mdlList{i,j}.D=D;
    end
end
cvDSlist=[dsBlk1([2,1]);dsBlk20([2,1])';dsBlk100([2,1]);dsAP([2,1])];
mdlList=mdlList(:,1:6); %Ignoring the A/P cross val
cvDSlist=cvDSlist(1:6);
[fh] = vizCVDataLikelihood(mdlList,cvDSlist);
%% Residual plots:
for i=1:length(modelAll)
    D=modelAll{i}.D;
    D(isnan(D))=0;
    modelAll{i}.D=D;
end
    
f2=linsys.compareResiduals(modelAll,datSet,'det');
title('Deterministic residuals');
ax=gca;
ax.XAxis.TickLabels={'0','1','2','3','4','5','6'};
ax.YAxis.TickValues=[];
ax.XAxis.TickLabelRotation=90;
f3=linsys.compareResiduals(modelAll,datSet,'oneAhead');
title('One ahead residuals')
ax.XAxis.TickLabels={'0','1','2','3','4','5','6'};

%% Put everything in single figure:
f=figure('Units','Pixels','InnerPosition',[100 100 300*4 300*1.5]);
p1=findobj(f1,'Type','Axes');
p=copyobj(p1(end-1),f);
p.Position=[.05 .08 .17 .85];
p.XAxis.TickValues=[100:100:700];
p.XAxis.TickLabels=strcat('\color[rgb]{0,0,0}  ', {'0','1','2','3','4','5','6'});
p.Title.String='BIC';
p.XAxis.Label.String='';
p.YAxis.TickValues=[];
p.YAxis.Limits(1)=0;
p.XAxis.TickLength=[0 0];
%Deterministic residuals:
p1=findobj(f2,'Type','Axes');
p=copyobj(p1,f);
p.Position=[.26 .08 .17 .86];
p.FontSize=8;
p.Box='off';
p.XAxis.TickLabels=strcat('\color[rgb]{0,0,0}  ', {'0','1','2','3','4','5','6'});
p.XAxis.TickLength=[0 0];
p.Title.String='Det. residuals';
p.XAxis.Color='w';
ph=findobj(fh,'Type','Axes');
ph=copyobj(ph,f);
ph=ph(end:-1:1);
for i=1:length(ph)
   ph(i).Position=[.48+.17*mod(floor((i-1)/2),4) .08+.45*(mod(i,2)) .15 .42];
   ph(i).YAxis.Label.String=namePrefix{i};
   if i==3
   ph(i).Title.String='CV logL';
   else
       ph(i).Title.String='';
   end
   tt=findobj(ph(i),'Type','text');
   delete(tt)
   bb=findobj(ph(i),'Type','bar');
   if mod(i,2)==0
       ph(i).XAxis.TickValues=100:100:700;
       ph(i).XAxis.TickLabels={'0','1','2','3','4','5','6'};
   else
       ph(i).XAxis.TickValues=[];
   end
   if i==4
      ph(i).XAxis.Label.String='Model order';
   end
end

p=findobj(f,'Type','Axes');
for i=1:length(p)
    p(i).YAxis.Color='w';
    p(i).YAxis.Label.Color='k';
    p(i).FontName='OpenSans';
    p(i).FontSize=10;
    tt=findobj(p(i),'Type','text');
    set(tt,'FontSize',10)
end
saveFig(f,'../../fig/','evaluateOrder',0)
%%
linsys.summaryTable([modelAll(4),mdlList(4,:)])
