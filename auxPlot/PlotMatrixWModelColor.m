%plotting matrices with color of model 

% load('allDataRedAlt_ATR01-04_DefaultCode.mat')
figure 
% aC=prctile(abs(datSet.out(:)),98);
% CD=[modelRed{2}.C];% modelRed{3}.D(:,1)];
% newC=sum(CD,2);

% data=nanmedian(datSet.out(:,52:57),1);
% data=nanmedian(Y(6:45,:),1);

% imagesc((reshape(modelRed{3}.D(:,1),12,168/12)'))
imagesc((reshape(AdaptationEarly,12,15)'))

%%
ex1=[1,0,0];
ex2=[0,0,1];
cc=[0    0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840];
ex1=cc(2,:);
ex2=cc(5,:);
mid=ones(1,3);
N=100;
gamma=1.5; %gamma > 1 expands the white (mid) part of the map, 'hiding' low values. Gamma<1 does the opposite
gamma=1;
map=[flipud(mid+ (ex1-mid).*([1:N]'/N).^gamma); mid; (mid+ (ex2-mid).*([1:N]'/N).^gamma)];

%%
colormap(flipud(map))
% caxis([-aC aC])
caxis([-1 1])
axis tight
colorbar

%%
ytl={'GLU','HIP','TFL','RF','VL','VM','SMT','SMB','BF','MG','LG','SOL','PER','TA'};

% ytl={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'HIP','TFL', 'GLU'};
% ytl={'fTA', 'fPER', 'fSOL', 'fLG', 'fMG', 'fBF', 'fSEMB', 'fSEMT', 'fVM', 'fVL', 'fRF', 'fHIP','fTFL', 'fGLU', ...
%     'sTA', 'sPER', 'sSOL', 'sLG', 'sMG', 'sBF', 'sSEMB', 'sSEMT', 'sVM', 'sVL', 'sRF', 'sHIP','sTFL', 'sGLU'};
yt=1:14;
fs=7;
set(gca,'XTick',[],'YTick',yt,'YTickLabel',ytl,'FontSize',fs)
ax=gca;
ax.YAxis.Label.FontSize=12;
colorbar

%%
%% Load data and Plot checkerboard for all conditions.
clear; close all; clc;

% set script parameters, SHOULD CHANGE/CHECK THIS EVERY TIME.
groupID = 'ATR';
saveResAndFigure = false;
plotAllEpoch = true;
plotIndSubjects = true;
plotGroup = true;
bootstrap=true;

scriptDir = fileparts(matlab.desktop.editor.getActiveFilename);
files = dir ([scriptDir '/data/' groupID '*params.mat']);

% n_subjects = size(files,1);
n_subjects = size(files,1);
% p = randperm(4,4);
ii=0;
subID = cell(1, n_subjects);
sub=cell(1,n_subjects);
% for i = 1:n_subjects
%     sub{i} = files(i).name;
%     subID{i} = sub{i}(1:end-10);
%    
% end

for i =1:n_subjects
    ii=1+ii;
    sub{ii} = files(i).name;
    subID{ii} = sub{ii}(1:end-10);
end

subID

regModelVersion =  'default';
%% load and prep data

% muscleOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'HIP', 'GLU'};
muscleOrder={'GLU','TFL','HIP','RF','VL','VM','BF', 'SEMB','MG','LG','SOL','PER','TA'};
muscleOrder(end:-1:1) = muscleOrder(:);

% muscleOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'HIP', 'ADM', 'TFL', 'GLU'};
% muscleOrder={'GLU','HIP','TFL','RF','VL','VM','SEMT','SEMB','BF','MG','LG','SOL','PER','TA'};

n_muscles = length(muscleOrder);

% ep=defineEpochs_regressionYA('nanmean');
ep=defineEpochs_regression('nanmean');
refEpTM = defineReferenceEpoch('TM base',ep);
refEpOG = defineReferenceEpoch('OG base',ep);

%% Prepare data for regressor checkerboards and regression model


usefft = 0; %Turn on to use the transpose of the EMG(+) as the estimated for EMG(-)
normalizeData = 0; %Vector lenght normalization

%type of regression that we want to run
regModelVersion='default';

% In case that we have multiple cases. Let see if this needs to be updated
splitCount=1;

%For group data try to use the median to be consistnace with Pablo's

summaryflag='nanmean';

% Defining the epochs of interest
ep=defineEpochs_regressionYA(summaryflag);

%Getting the names for specific epochs
OGbase=defineReferenceEpoch('OG base',ep);
TMbase= defineReferenceEpoch('TM base',ep);
TMbeforePos= defineReferenceEpoch('TM_{beforePos}',ep);
PosShort= defineReferenceEpoch('PosShort_{early}',ep);
TMbeforeNeg=defineReferenceEpoch('TM_{beforeNeg}',ep);
NegShort=defineReferenceEpoch('NegShort_{early}',ep);
Pos1_Early=defineReferenceEpoch('Post1_{Early}',ep);
AdaptLate=defineReferenceEpoch('Adaptation',ep);
Adaptearly=defineReferenceEpoch('Adaptation_{early}',ep);
Pos1_Late=defineReferenceEpoch('Post1_{Late}',ep);
Pos2_Early=defineReferenceEpoch('Post2_{Early}',ep);

if (contains(groupID, 'ATR'))
    AfterPos= defineReferenceEpoch('TM_{afterPos}',ep);
    AfterNeg=defineReferenceEpoch('TM_{afterNeg}',ep);
    
elseif (contains(groupID, 'ATS'))
    AfterPos= defineReferenceEpoch('OG_{afterPos}',ep);
    AfterNeg=defineReferenceEpoch('OG_{afterNeg}',ep);
end

refEpPost1Early= defineReferenceEpoch('Post1_{Early}',ep);
% if contains(groupID,'ATR')
%     refEp= defineReferenceEpoch('TM base',ep);
% elseif contains(groupID,'ATS')
    refEp= defineReferenceEpoch('OG base',ep);
% end

%% Bootstrapping section
saveResAndFigure=0;
n_subjects = length(subID);


GroupData=adaptationData.createGroupAdaptData(sub); %loading the data
GroupData=GroupData.removeBadStrides; %Removing bad strides

% GroupData=group;

newLabelPrefix = defineMuscleList(muscleOrder);
normalizedGroupData = GroupData.normalizeToBaselineEpoch(newLabelPrefix,refEpTM); %Normalized by OG base same as nimbus data
ll=normalizedGroupData.adaptData{1}.data.getLabelsThatMatch('^Norm');
l2=regexprep(regexprep(ll,'^Norm',''),'_s','');
normalizedGroupData=normalizedGroupData.renameParams(ll,l2);
newLabelPrefix = regexprep(newLabelPrefix,'_s','');
flip=1;
Data=cell(7,1);
Data2=cell(5,1);
group=cell(5,1);
summFlag='nanmedian';
% [data,~,~,groupData] = normalizedGroupData.getCheckerboardsData(newLabelPrefix,PosShort,TMbeforePos,2,summFlag);


% epochOfInterest={'TM base','Adaptation_{early}','Adaptation','Post1_{Early}','NegShort_{early}'};
% epochOfInterest={'Post1_{Early}','NegShort_{early}'};
%%
% epochOfInterest={'TM base','Adaptation_{early}','Adaptation','Post1_{Early}'};
epochOfInterest={'Adaptation','Split20','Adaptation_{early}','PosShort_{early}'};
% epochOfInterest={'Adaptation_{early}'};
fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
ph=tight_subplot(1,length(epochOfInterest),[.03 .005],.04,.04);

for l=1:length(epochOfInterest)
ep2=defineReferenceEpoch(epochOfInterest{l},ep);
% [~,~,~,Data{l}]=
normalizedGroupData.plotCheckerboards(newLabelPrefix,ep2,fh,ph(1,l),[],2,summFlag);
[~,~,~,Data{l}]=normalizedGroupData.getCheckerboardsData(newLabelPrefix,ep2,[],2,summFlag);

end 
PosShort= defineReferenceEpoch('PosShort_{early}',ep);
% AdaptLate=defineReferenceEpoch('Adaptation',ep);
Adaptearly=defineReferenceEpoch('Adaptation_{early}',ep);
% NegShort=defineReferenceEpoch('NegShort_{early}',ep);
% % Fast=defineReferenceEpoch('TM fast',ep);
% % Slow=defineReferenceEpoch('TM slow',ep);
% 
% % [~,~,~,Data{l+1}]=normalizedGroupData.plotCheckerboards(newLabelPrefix,PosShort,fh,ph(1,l+1),TMbeforePos,2,summFlag);
% % title('TM_{beforePos}-Short_{Pos}')
% [~,~,~,Data{l+1}]=normalizedGroupData.getCheckerboardsData(newLabelPrefix,PosShort,[],2,summFlag);
% [~,~,~,Data{l+2}]=normalizedGroupData.getCheckerboardsData(newLabelPrefix,NegShort,[],2,summFlag);
% [~,~,~,Data{l+3}]=normalizedGroupData.getCheckerboardsData(newLabelPrefix,Adaptearly,[],2,summFlag);
% [~,~,~,Data{l+5}]=normalizedGroupData.getCheckerboardsData(newLabelPrefix,Fast,[],2,summFlag);
% [~,~,labels2,Data{l+6}]=normalizedGroupData.getCheckerboardsData(newLabelPrefix,Slow,[],2,summFlag);

%%
colormap(flipud(map))
% colormap((map))
set(gcf,'color','w');
colorbar                                                                                                                                                                                         
set(ph(:,1),'CLim',[-1 1]*1);
set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1]*1);
% colorbar
% ytl={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'TFL', 'HIP', 'GLU'};
% yt=.5:1:14;
% fs=14;
% set(gca,'XTick',[],'YTick',yt,'YTickLabel',ytl,'FontSize',fs)