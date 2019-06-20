%% Compare continuously fitted model and broken model for estimating blocks individually
clear all
load ../../res/allDataRedAlt_20190510T175706.mat %Orders from 0 to 6
contModel=modelRed; %Model fitted to data as single block
load ../../res/allDataRedAltBroken_20190616T001216.mat
blockedModel=modelRed; %Model fitted to individual blocks
ss=datSet.split(find(Ubreaks),true);

%% Some model fixing:
ord=4; %three-state

mdl=blockedModel{ord};
%Need to pad,  not sure why it didnt happen at EM time:
Dpad=datSet.out/datSet.in;
Dpad=Dpad(flatIdx,:);
mdl=mdl.pad(flatIdx,Dpad);
mdl=mdl.canonize('canonicalAlt');
%Shift states by an arbitrary portion of the inputs
l1=mdl.logL(ss);
lc1=mdl.logL(datSet);
[mdl,K]=mdl.EMrefine(ss).mleShift(datSet); %Optimal shift to explain datSet
%Check that shift does not change likelihood:
l2=mdl.logL(ss);
lc2=mdl.logL(datSet);
deltaL=l2-l1 %Should be 0 (numerically)
models{2}=mdl;
models{1}=contModel{ord}.mleShift(datSet).EMrefine(datSet); %Doing the shift here for fairness, should change nothing.

%%
figure('Units','Pixels','InnerPosition',[100 100 300*4 300*2])
for kk=1:2
    mdl=models{kk};
    switch kk
        case 1
            %Option 1: load the model fitted to the continous data:
            ttl='Continuous dataset model fit';
         case 2
             %Option 2: load the model fitted to the broken data:
            ttl='Blocked dataset model fit';
    end
    % For each block, get the smoothed/MLE state estimate
    subplot(2,1,kk)
    hold on
    x1=0;
    mdl=mdl.canonize('canonicalAlt');
    k=sqrt(sum(mdl.D(:,1).^2));
    mdl=mdl.scale(1/k);
    iC=[];
    for i=1:length(ss.in) %Each block
        single=ss.extractSingle(i); %single block
        mleState{i}=mdl.Ksmooth(single); %Smoothing from infinite uncertainty
        %Adding an estimate for the next state at each block
        %which is to be compared to the first state in the prev block
        mleStateX0=mdl.A*mleState{i}.state(:,end)+mdl.B*ss.in{i}(:,end);
        mleStateP0=mdl.A*mleState{i}.covar(:,:,1)*mdl.A' + mdl.Q;
        mleState{i}=stateEstimate([mleState{i}.state mleStateX0],cat(3,mleState{i}.covar,mleStateP0));
        mleState{i}.plot(x1,99); %99% CI
        
%         %Deterministic states:
%         %%Deterministic simulation from last point, needs to be computed
%         %%from a better estimate: KF or KS when Q=0;
%         if i==1
%             iC=[];
%         else
%             %iC=dsstate.getSample(dsstate.Nsamp); %Last sample of fit to previous block
%             iC=mleState{i}.getSample(1); %First sample of the MLE states
%         end
%         %[dsout,dsstate]=mdl.simulate(single.in,iC,true,true);
%         %dsstate.plot(x1)
        
        %To do: add taus in legend
        x1=x1+mleState{i}.Nsamp-1;
    end
    % Add all data fit:
    %mls=mdl.Ksmooth(datSet);
    %mls.plot(0,0);
    title(ttl)
    if kk==2
        xlabel('strides')
    end
    pp=patch([151 1051 1051 151],[-1 -1 1 1],.3*ones(1,3),'EdgeColor','none','FaceAlpha',.3);
    uistack(pp,'bottom')
    axis([0 1650 -.15 .65])
    for i=0:4
        pp=plot(i*300+151*[1 1],[-.2 .8],'k');
        uistack(pp,'bottom');
    end
    ylabel('state value (a.u.)')
    ll=findobj(gca,'Type','Line');
    set(ll,'LineWidth',1)
    
    %Change colors:
    cc=get(gca,'ColorOrder');
    newColors=[.2,.4,.55]'*ones(1,3);
    for jj=1:3
        ll=findobj(gca,'Color',cc(jj,:));
        set(ll,'Color',newColors(jj,:),'LineWidth',2)
        pp=findobj(gca,'FaceColor',cc(jj,:));
        set(pp,'FaceColor',newColors(jj,:))
    end
end

%For each plot: copy it 4 times, show only a zoomed version around the
%breaks
ph=findobj(gcf,'Type','Axes');
for i=1:length(ph)
    for j=1:4
       ax=copyobj(ph(i),gcf);
       ax.Position=[.08+(j-1)*.235 ph(i).Position(2) .2 ph(i).Position(4)];
        ax.XAxis.Limits=151+[-12,12]+(j-1)*300;
        ax.XAxis.TickValues=151+[-150:10:1500];
        axes(ax)
        set(ax,'FontSize',12,'FontName','OpenSans')
        grid on
        if j>1
           ax.YAxis.TickLabels={};
           ax.YAxis.Label.String='';
        else
            
            if i==2
            ylabel({'continuous dataset model';'state value (a.u.)'})
            ll=findobj(ax,'Type','Line');
            pp=findobj(ax,'Type','Patch');
            legend([ll([6,11,1]); pp(end)],{'state 1','state 2','state 3','99% CI'},'Location','NorthWest','Box','off')
            else
               ylabel({'blocked dataset model';'state value (a.u.)'}) 
            end
        end
        if i>1
            ax.XAxis.TickLabels={};
            title(['break ' num2str(j)])
        else
            title('')
        end
    end
    delete(ph(i))
end
saveFig(gcf,'../../fig/','breaks',0)
%% If curious: compare model orders for the broken data
load ../../res/allDataRedAltBroken_20190616T001216.mat
for i=2:5
modelRed{i}.name=num2str(i-1);
end
fittedLinsys.compare(modelRed(2:5))
set(gcf,'Units','Normalized','OuterPosition',[.4 .7 .6 .3])
%saveFig(gcf,'../../fig/','allDataModelsRedAltCompare_broken',0)
