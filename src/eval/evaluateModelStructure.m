%%
addpath(genpath('../../../matlab-linsys/'))
addpath(genpath('../../../'))
%%
clear all
load ../../res/allDataRedAlt_20190510T175706.mat
%% Select model order
ord=4;
mdl=modelRed{ord+1};

%% Make a pretty plot of the model's characteristics
mdl=mdl.canonize('canonicalAlt');
k=sqrt(sum(mdl.D(:,1).^2));
mdl=mdl.scale(1/k); %Scaling C so that the columns add up to the same as the first column of D
%This results in better scaling for visualization, but is completely
%arbitrary and changes nothing

%%
%legacy_vizSingleModelMLMC(mdl,datSet.out,datSet.in)

%%
[f1]=mdl.vizSingleFit(datSet);


% Fix state plot:
lg=findobj(f1,'Type','Legend');
lg.Position(1)=.085;
lg.Position(2)=.73;
lg.AutoUpdate='off';

mList={'TA','PER','SOL','LG','MG','BF','SMB','SMT','VM','VL','RF','HIP','ADM','TFL','GLU'};
mList=mList(end:-1:1);
p=findobj(f1,'Type','Axes');
set(p,'FontSize',16)
%For the timecourse plots, remove XTicks
for i=2:2:length(p)
    p(i).XAxis.TickValues=[];
    %p(i).FontSize=12;
    p(i).FontName='OpenSans';
    axes(p(i))
        ll=findobj(p(i),'Type','Line');
    set(ll,'Color','k')
        ll=findobj(p(i),'Type','Patch');
    set(ll,'FaceColor','k','FaceAlpha',.5)
    ps=p(i).YAxis.Limits;
    pp=patch([150 1050 1050 150],[-1 -1 2 2],.8*ones(1,3),'FaceAlpha',.5,'EdgeColor','none','DisplayName','');
    uistack(pp,'bottom')
    p(i).YAxis.Limits=ps;
    ll=findobj(p(i),'Type','Line');
    set(ll,'Color','k')
    ttl=p(i).Title.String;
    p(i).Title.String=regexprep(lower(ttl), 'b',['B_' num2str(ceil((8-i)/2))]);
    p(i).Title.FontWeight='normal';
    p(i).Title.FontSize=22;
    p(i).Position(2)=.7;
end

%For the checkerboards, add XTicks for all, YTicks for the first
for i=1:2:length(p)
    %if i==7
    p(i).YAxis.TickValues=1:15;
    p(i).YAxis.TickLabels=mList;
    %else
    %    p(i).YAxis.TickValues=[];
    %   p(i).YAxis.TickLabels={}; 
    %end
    p(i).XAxis.TickValues=[1,4,7,10]+.5;
    p(i).XAxis.TickLabels={'DS','SINGLE','DS','SWING'};

    p(i).XAxis.FontSize=18;
    p(i).YAxis.FontSize=18;
    p(i).FontName='OpenSans';
    p(i).XAxis.FontWeight='bold';
    p(i).CLim=[-1 1];
    
    %Add lines to separate DS, SINGLE, DS, SWING
    axes(p(i))
    hold on
    plot([.1 1.9]+.5,15.7*[1 1],'LineWidth',4,'Color','k','Clipping','off')
    plot([.1 1.9]+.5+6,15.7*[1 1],'LineWidth',4,'Color','k','Clipping','off')
    plot([.1 3.9]+.5+2,15.7*[1 1],'LineWidth',4,'Color','k','Clipping','off')
    plot([.1 3.9]+.5+8,15.7*[1 1],'LineWidth',4,'Color','k','Clipping','off')
    p(i).XAxis.Label.Position(2)=.02;
    p(i).Position(2)=.05;
    if i>1
    p(i).Title.String=['C_{i' num2str(ceil((8-i)/2)) '}'];
    else
        p(i).Title.String='D';
    end
end

%Ticks in colorbar:
cb=findobj(f1,'Type','Colorbar');
cb.Ticks=[-1 -.9 0 .9 1];
cb.TickLabels={'dom.','+100%', '0%', 'n.d.', '+100%'};
cb.TickLength=[0];
cb.FontSize=15;
cb.FontWeight='bold';
cb.FontName='OpenSans';

%saveFig(f1,'../../fig/','3stateModelStructure',0)
%export_fig ../../fig/3stateModelStructure.png -png -c[0 5 0 5] -transparent -r100
export_fig ../../fig/4stateModelStructure.png -png -c[0 5 0 5] -transparent -r100
%pause(10)
%error('')
%%
close all
wins=[141,151,201,601,1041,1051,1101,1301];
[f2]=mdl.vizSingleRes(datSet,[],wins);
% Fix residual plot:
p=findobj(f2,'Type','Axes');
set(p,'FontSize',12,'FontWeight','normal','FontName','OpenSans')

ll=findobj(p(3),'Type','Line');
%delete(ll(2))
ll(2).Color=.3*ones(1,3);
ll(3).Color=.8*ones(1,3);

mList={'TA','PER','SOL','LG','MG','BF','SMB','SMT','VM','VL','RF','HIP','ADM','TFL','GLU'};
mList=mList(end:-1:1);
set(p,'CLim',[-1 1])
%Add window markers:
axes(p(3))
for i=1:length(wins)
    annotation('arrow',.061+.79*wins(i)*[1 1]/1650,[.4 .37],'LineWidth',2)
end
p(2).YAxis.TickValues=[-.1 0 .1];
p(2).YAxis.FontSize=9;
p(2).YAxis.Label.FontSize=11;
p(2).Position(1)=.06;
p(2).Position(3)=.79;
axes(p(2))
ps=p(2).YAxis.Limits;
pp=patch([150 1050 1050 150],[-1 -1 2 2],.8*ones(1,3),'FaceAlpha',.5,'EdgeColor','none','DisplayName','');
uistack(pp,'bottom')
p(2).YAxis.Limits=ps;
p(2).XAxis.TickValues=[150,600,1050,1500];
p(2).XAxis.FontSize=10;
p(2).XAxis.TickLength=[0 0];
%ll=findobj(p(2),'Type','Line');
%ll.LineWidth=1;
%ll.Color='k';

ll=findobj(p(3),'Type','Line','LineWidth',2);
ll.Color='k';
uistack(ll,'bottom')
ll=findobj(p(3),'Type','Line');
cc=get(gca,'ColorOrder');
ll(1).Color='k';
ll(3).LineWidth=1;
ll(3).Color=cc(1,:);
ll(2).Color=.4*ones(1,3);
p(3).YAxis.Limits(2)=4;
p(3).YAxis.TickValues=[1 2 3];
p(3).YAxis.Label.FontSize=11;
p(3).Position(1)=.06;
p(3).Position(3)=.79;
lg=findobj(f2,'Type','legend');
lg.AutoUpdate='off';
axes(p(3))
ps=p(3).YAxis.Limits;
pp=patch([150 1050 1050 150],[.1 .1 5 5],.8*ones(1,3),'FaceAlpha',.5,'EdgeColor','none','DisplayName','');
uistack(pp,'bottom')
p(3).YAxis.Limits=ps;

for i=[1,4:18]
    p(i).YAxis.TickValues=1:15;
    p(i).YAxis.TickLabels={};
    p(i).YAxis.FontSize=12;
    p(i).YAxis.FontWeight='bold';
    if i==1
        p(i).XAxis.TickValues=[1,4,7,10]+.5;
        p(i).XAxis.TickLabels={'DS','SINGLE','DS','SWING'};
        p(1).XAxis.FontSize=8;
        p(i).YAxis.TickLabels={};%mList;
        p(i).YAxis.FontName='OpenSans';
        p(1).Position(1)=.87;
        p(1).Position(4)=.16;
        p(1).Title.FontWeight='normal';
        %p(1).Title.String='PC1 of residual';
        p(1).Title.FontSize=11;
        p(i).YAxis.FontSize=9;
    else
       p(i).XAxis.TickValues=[];
       p(i).XAxis.TickLabels={};
    end
end

%Colorbar fix:
cb=findobj(f2,'Type','Colorbar');
cb.Ticks=[-1 -.9 0 .9 1];
cb.TickLabels={'dom.','+100%', '0%', 'n.d.', '+100%'};
cb.TickLength=[0];
cb.FontSize=14;
cb.FontWeight='bold';
cb.FontName='OpenSans';
cb.Position(2)=.41;
cb.Position(3)=.02;
cb.Position(4)=.52;

%Legend fix:
lg=findobj(f2,'Type','legend');
lg.Box='off';
lg.Position(2)=.32;
lg.Position(1)=.7;
lg.FontSize=11;
lg.FontWeight='normal';

%saveFig(f2,'../../fig/','3stateModelResiduals',0)
%export_fig ../../fig/3stateModelResiduals.png -png -c[0 5 0 5] -transparent -r100