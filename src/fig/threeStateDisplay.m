load('/Datos/Documentos/code/EMG-LTI-SSM/res/allDataRedAlt_20190510T175706.mat')

%%
legacy_vizSingleModelMLMC(modelRed{4},datSet.out,datSet.in)
%%saveFig(gcf,'../../fig/','threeState',0)
export_fig ../../fig/threeState.png -png -c[0 5 0 5] -transparent -r600

%%

legacy_vizSingleModelMLMC(modelRed{5},datSet.out,datSet.in)
%%saveFig(gcf,'../../fig/','threeState',0)
export_fig ../../fig/fourState.png -png -c[0 5 0 5] -transparent -r600

%%
legacy_vizSingleModelMLMC(modelRed{3},datSet.out,datSet.in)
%%saveFig(gcf,'../../fig/','threeState',0)
export_fig ../../fig/twoState.png -png -c[0 5 0 5] -transparent -r600

%% Compare to other models
binw=51;
smoother=@(x) conv(x,ones(1,binw)/binw,'valid');
smoother=@(x) medfilt1(x,binw,[],2,'truncate');

figure('Units','Pixels','InnerPosition',[100 100 300*3 2*300])
Y=datSet.out;
dd=Y(:,1:150); %Baseline data only
dd=dd-mean(dd,2); %Baseline residuals under flat model
meanVar=mean(sum(dd.^2,1),2); %Variance during baseline
smoothedY=smoother(Y);
subplot(1,1,1)
hold on
for i=1:5
    dd=modelRed{i}.fit(datSet,[],'KF').oneAheadResidual;
    %do=modelRed{i}.fit(datSet,[],'KF').oneAheadOutput;
    %dd=Y-CD*projY;
aux1=sqrt(sum(dd.^2))/sqrt(meanVar);
%aux1=sqrt(sum((do-smoothedY).^2))/sqrt(meanVar);
aux1=smoother(aux1);
p1=plot(aux1,'LineWidth',1,'DisplayName',[num2str(i-1) '-state model']);
end

%title('MLE one-ahead output error (RMSE, mov. avg.)')
axis tight
grid on
set(gca,'YScale','log')
%Add previous stride model:
%ind=find(diff(U(1,:))~=0);
%Y2=Y;
%Y(:,ind)=nan;
%aux1=(Y(:,2:end)-Y(:,1:end-1));%/sqrt(2);
%aux1=sqrt(sum(aux1.^2))/sqrt(meanVar);
%aux1=conv(aux1,ones(1,binw)/binw,'valid'); %Smoothing
%plot(aux1,'LineWidth',1,'DisplayName','Prev. datapoint','Color',.5*ones(1,3)) ;
%ylabel({'residual';' RMSE'})
ax=gca;
ax.YAxis.Label.FontSize=12;
ax.YAxis.Label.FontWeight='bold';
ax.YTick=[.8,1,1.5,2];
%Add flat model:
%aux1=Y2-Y2/U*U;
%aux1=sqrt(sum(aux1.^2))/sqrt(meanVar);
%aux1=conv(aux1,ones(1,binw)/binw,'valid'); %Smoothing
%plot(aux1,'LineWidth',1,'DisplayName','Flat','Color','k') ;
legend('Location','NorthEast')

export_fig ../../fig/allStateComparison.png -png -c[0 5 0 5] -transparent -r600
