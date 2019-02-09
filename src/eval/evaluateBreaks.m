addpath(genpath('../../matlab-linsys/'))
addpath(genpath('../../robustCov/'))
%% First: load models fitted w/o breaks, filter each block independently, compare states
sqrtFlag=false;
subjIdx=[2:6,8,10:16]; %Excluding C01 (outlier), C07, C09 (less than 600
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag);
Uf=[U;ones(size(U))];
load ../res/oddEvenCV.mat model
noStartle=model(:,3);
load ../res/withBreaks.mat model
wBreaks=model;5
datSet=dset(Uf,Yasym');

i=4; %Order +1
nS=linsys.struct2linsys(noStartle{i}).canonize('canonicalAlt');
wB=linsys.struct2linsys(wBreaks{i}).canonize('canonicalAlt');
%Smooth all data:
[Xs,Ps,Pt,Xf,Pf,Xp,Pp,rejSamples,logL]=nS.Ksmooth(datSet);
%Smooth in blocks:
breaks=[1,151,451,751,1051,1651];
multiSet=datSet.split(breaks);
[XsBreaks,~,~,~,~,~,~,~,logl]=nS.Ksmooth(multiSet);
[XsBreaksWith,~,~,~,~,~,~,~,loglB]=wB.Ksmooth(multiSet);

figure;
projX=nS.C\(Yasym'-nS.D*Uf);
projXb=wB.C\(Yasym'-wB.D*Uf);
myFiguresColorMap
set(gcf,'Colormap',flipud(map))
cscale=.5;
for l=1:i-1
  subplot(i-1,6,6*(l-1)+1)
  imagesc(reshape(nS.C(:,l),12,15)')
  if l==1
    title(['log-L = ' num2str(sum(logl))])
  end
  caxis([-1 1]*cscale)
  subplot(i-1,6,6*(l-1)+[2:3])
  hold on
  plot(Xs(l,:),'LineWidth',3,'DisplayName','No breaks')
  title(['\tau= ' num2str(-1./log(nS.A(l,l)))])
  scatter(1:size(projX,2),projX(l,:),10,'filled','MarkerFaceAlpha',.5,'MarkerEdgeColor','none')
  for k=1:5
    plot([breaks(k):breaks(k+1)-1],XsBreaks{k}(l,:),'k','DisplayName','By blocks','LineWidth',2)
    ptc=patch([breaks(k) breaks(k+1) breaks(k+1) breaks(k)],[-1 -1 2 2]*.7,.7+.3*((-1).^k)*ones(1,3),'FaceAlpha',.5,'EdgeColor','none');
    ptc=uistack(ptc,'bottom');
  end
  grid on

subplot(i-1,6,6*(l-1)+4)
  imagesc(reshape(wB.C(:,l),12,15)')
    caxis([-1 1]*cscale)
    if l==1
      title(['log-L = ' num2str(sum(loglB))])
    end
  subplot(i-1,6,6*(l-1)+[5:6])
  hold on
  scatter(1:size(projX,2),projXb(l,:),10,'filled','MarkerFaceAlpha',.5,'MarkerEdgeColor','none')
  title(['\tau= ' num2str(-1./log(wB.A(l,l)))])
  for k=1:5
    plot([breaks(k):breaks(k+1)-1],XsBreaksWith{k}(l,:),'r','DisplayName','Fitted w/breaks','LineWidth',2)
    ptc=patch([breaks(k) breaks(k+1) breaks(k+1) breaks(k)],[-1 -1 2 2]*.7,.7+.3*((-1).^k)*ones(1,3),'FaceAlpha',.5,'EdgeColor','none');
    ptc=uistack(ptc,'bottom');
  end
  grid on
end

%% Second: load models fitted w breaks, Compare

%% Third, load models with startle and breaks/start markers?

%% Fourth, strictly data-based: compare activity before and after each break, maybe plot projection/regression onto matrix C of different models?
