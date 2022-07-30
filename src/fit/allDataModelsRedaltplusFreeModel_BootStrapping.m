%%
% addpath(genpath('../../../EMG-LTI-SSM/'))
% addpath(genpath('../../../matlab-linsys/'))
% addpath(genpath('../../../robustCov/'))
%%
% clear all;clc;close all
%% Load real data:
sqrtFlag=false;
% subjIdx=[2:6,8,10:15]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post), C16 (missed first trial of Adapt)
X1=[];X2=[];i=0;
for s=[1:12]
    
% p = datasample([1:7],4,'Replace',true);
i=i+1;    
% subjIdx=[2:6,8,10:15];
subjIdx=[s];
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag);
Uf=[U;ones(size(U))];
% Looking in to asymmetry 
% datSet=dset(Uf,Yasym');

%looking into individual legs
% datSet=dset(Uf,Y');
binwith=5;
%% Reduce data
% Y=datSet.out;
% U=datSet.in;
% X=Y-(Y/U)*U; %Projection over input
% s=var(X'); %Estimate of variance
% flatIdx=s<.005; %Variables are split roughly in half at this threshold


%% Free model - Linear regression - Asymmetry 
 

% load('ATS_11_Asym_EarlyLateAdaptation.mat')
% load('allDataRedAlt_ATS_fixCandD1_280322T212228.mat')
% load('AUF_7_Asym_EarlyLateAdaptation')
% load('ATS_11_Asym_EarlyLate5Adaptation.mat')
% load('AUFV4_5_Asym_EarlyLateAdaptation.mat')
% load('NTS_5_Asym_AdaptationPosShort.mat')
% load('NTR_4_Asym_AdaptationPosShort.mat')
% load('ATR_4_Asym_EarlyLate10Adaptation.mat')

% load('CTS_5_Asym_AdaptationPosShort.mat')
% load('CTR_4_Asym_AdaptationPosShort.mat')
% load('OA_TR_fixDandC_160322T155119.mat')
% load('C_12_Asym_EarlyLate40Adaptation.mat')
% figure 

% model.C=C;
model.C=modelRed.C;
%  Yasym=Yasym(100:1200,:);
% Y=datSet.out;
Cinv=pinv(model.C)';
X2asym = Yasym*Cinv; %x= y/C
Y2asym= model.C * X2asym' ; %yhat = C 
   

subplot(2,1,1)
hold on
plot( movmean(X2asym(:,1),binwith))
pp=patch([50 600 600 50],[-0.5 -0.5 1.6 1.6],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
uistack(pp,'bottom')
X1(:,i)=X2asym(:,1);

% title('C_1 = Early Adaptation')
% yline(0)

subplot(2,1,2)
plot(movmean(X2asym(:,2),binwith))
hold on
legend('reactive','adaptive','AutoUpdate','off')
X2(:,i)=X2asym(:,2);
% pp=patch([50 939 939 50],[-0.5 -0.5 1.6 1.6],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
pp=patch([50 600 600 50],[-0.5 -0.5 1.6 1.6],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
uistack(pp,'bottom')
axis tight
yline(0)
yline(1)
% title('C_2 = Late Adaptation')

set(gcf,'color','w')

% subplot(2,1,2)
% RMSEasym= sqrt(mean((Yasym-Y2asym').^2,2));
% plot(movmean(RMSEasym,binwith))
% ylabel('RMES')
% % pp=patch([50 939 939 50],[0 0 1 1],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
% pp=patch([50 600 600 50],[-0.5 -0.5 1.6 1.6],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
% uistack(pp,'bottom')
% axis tight

end
%%


 
 %%

figure 
subplot(2,1,1)
hold on
temp=movmean(X1,5);
y=nanmedian(temp,2)';
condLength=length(y);
x=1:condLength;
E=std(temp,0,2,'omitnan')./sqrt(size(temp,2));
% color=[0.4940 0.1840 0.5560];
 color=[0.9290 0.6940 0.1250];
Opacity=0.5;
idx=[51; 951];

nanJackKnife(x,y,E',color,color+0.5.*abs(color-1),Opacity);
pp=patch([50 950 950 50],[-0.5 -0.5 1.6 1.6],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
uistack(pp,'bottom')
% title('C_1 = Early Adaptation')
% yline(0)


subplot(2,1,2)
hold on
temp=movmean(X2,5);
y=nanmedian(temp,2)';
condLength=length(y);
x=1:condLength;
E=std(temp,0,2,'omitnan')./sqrt(size(temp,2));
% color=[0.4940 0.1840 0.5560];
Opacity=0.5;
idx=[51; 951];
y(:,idx)=nan;
x(:,idx)=nan;
E(idx,1)=nan;
nanJackKnife(x,y,E',color,color+0.5.*abs(color-1),Opacity);
pp=patch([50 950 950 50],[-0.5 -0.5 1.6 1.6],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
uistack(pp,'bottom')


% subplot(2,1,2)
% plot(movmean(nanmean(X2(:,2),2),binwith))
% hold on
% legend('reactive','adaptive','AutoUpdate','off')
% X2(:,s)=X2asym(:,2);
% % pp=patch([50 939 939 50],[-0.5 -0.5 1.6 1.6],.7*ones(1,3),'FaceAlpha',.2,'EdgeColor','none');
% uistack(pp,'bottom')
% axis tight
% yline(0)
% yline(1)
% % title('C_2 = Late Adaptation')
% 
% set(gcf,'color','w')


%%
%         y=nanmedian(temp-offset,2)';
%         condLength=length(y);
%         x=Xstart:Xstart+condLength-1;
%         E=std(temp,0,2,'omitnan')./sqrt(length(temp));
%         
%         %         if c=1
%         [Pa, Li{g}]=nanJackKnife(x,y,E',ColorOrder(g,:),ColorOrder(g,:)+0.5.*abs(ColorOrder(g,:)-1),Opacity);

% legacy_vizSingleModelMLMC_FreeModel(model,Yasym',Uf)
%% Free model - Linear regression - Indv Legs

% % load('ATS_11_IndvLegs_EarlyLateAdaptation.mat')
% % 
% % C=[C(1:size(C,1)/2,:) C(size(C,1)/2+1:end,:)];
% % Cinv=pinv(C)';
% % Ys=Y(:,size(Y,2)/2+1:end);
% % % Cinv=pinv(C)';
% % X2 = Ys*Cinv; %x= y/C
% % Y2= C * X2' ; %yhat = C 
% %    
% % figure 
% % subplot(2,1,1)
% % plot( movmean(X2(:,1),binwith))
% % hold on
% % % title('C_1 = Early Adaptation')
% % 
% % 
% % 
% % % subplot(2,1,2)
% % plot(movmean(X2(:,2),binwith))
% % plot(movmean(X2(:,3),binwith))
% % plot(movmean(X2(:,4),binwith))
% % hold on
% % % title('C_2 = Late Adaptation')
% % title('L -Individual leg analysis')
% % set(gcf,'color','w')
% % yline(0)
% % legend('R_{reactive}','R_{adaptive}','L_{reactive}','L_{adaptive}')
% % 
% % subplot(2,1,2)
% % RMSE= sqrt(mean((Ys-Y2').^2,2));
% % 
% % plot(movmean(RMSE,binwith))
% % ylabel('RMES')
% % % legacy_vizSingleModelMLMC_FreeModel(model,Y',Uf)
% % 
% % 
% % 
% % %%
% % % figure
% % subplot(2,1,2)
% % plot(movmean(RMSE,binwith))
% % hold on 
% % plot(movmean(RMSEasym,binwith))
% % ylabel('RMES')
% % legend('Indv Legs','Asym')

%% Fit Models
% maxOrder=3; %Fitting up to 10 states
% %Opts for indentification:
% opts.robustFlag=false;
% opts.outlierReject=false;
% opts.fastFlag=200; %Cannot do fast for NaN filled data, disable here to avoid a bunch of warnings.
% opts.logFlag=true;
% opts.indD=[];
% opts.indB=1;
% opts.Nreps=20;
% opts.stableA=true;
% % opts.fixR=median(s(~flatIdx))*eye(size(datSetRed.out,1)); %R proportional to eye
% % opts.fixR=corrMat(~flatIdx,~flatIdx); %Full R
% % opts.fixR=[]; %Free R
% load('PATS_FixC.mat')
% opts.fixC=C;
% % load('D1_fastBase-slowBase.mat')
% % opts.fixD=[D1 zeros(12*14,1)];
% opts.fixD=[zeros(12*13,2)];
% opts.includeOutputIdx=find(~flatIdx); 
% [modelRed]=linsys.id(datSet,2,opts);
% %% Save (to avoid recomputing in the future)
% nw=datestr(now,'ddmmyyTHHMMSS');
% % save(['../../res/allDataRedAlt_' nw '.mat'],'modelRed', 'datSet', 'opts');
% save(['allDataRedAlt_PATS_fixCandD_Adaptation' nw '.mat'],'modelRed', 'datSet', 'opts');
%% Add dummy model:
% opts1=opts;
% opts1.fixA=eye(180);
% opts1.fixC=eye(180);
% opts1.includeOutputIdx=1:180;
% opts1.stableA=false;
% opts1.Nreps=0;
% opts1.refineMaxIter=10; %Giant model, cannot afford too many iterations
% [modelDummy]=linsys.id(datSet,180,opts1);
% dummyFit=modelDummy.fit(datSet,[],'KF');
% save('../../res/allDataDummyModel.mat','modelDummy','opts1','datSet','dummyFit')
% %%
% load ../../res/allDataRedAlt_20190510T175706.mat
% %% Compare models
% for i=1:maxOrder
% modelRed{i}.name=num2str(i-1);
% end
% fittedLinsys.compare(modelRed(1:11))
% set(gcf,'Units','Normalized','OuterPosition',[.4 .7 .6 .3])
% % saveFig(gcf,'../../fig/','allDataModelsRedAltCompare',0)
% %% visualize structure
% modelRed2=cellfun(@(x) x.canonize,modelRed,'UniformOutput',false);
% datSet.vizFit(modelRed2(1:10))
% %%
% linsys.vizMany(modelRed(2:6))