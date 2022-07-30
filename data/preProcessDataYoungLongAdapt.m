%%
%Running this script requires labTools (github.com/pittSMLlab/labTools/)
%% Aux vars:
% groupName='controls';
% groupName='YoungAbuptTM';
% matDataDir='./';
% loadName=[matDataDir groupName];
% load(loadName)

%%
% group=controls;
% group=TMFullAbrupt;
% group={adaptData};

group=adaptationData.createGroupAdaptData({'YL03params'});
age=group.getSubjectAgeAtExperimentDate/12;


%% Define epochs
baseEp=getBaseEpoch;
%Adaptation epochs
strides=[-90 2100 500];
exemptFirst=[0];
exemptLast=[0]; %Strides needed 
names={};
shortNames={};
% cond={'TM Base','Adapt1','Adapt2','Adapt3','Washout'};
% cond={'TM base','gradual adaptation','TM post'}; %Conditions for this group 
cond={'TM base','Adaptation','Post adapt'}; %Conditions for this group 
% ep=defineEpochs(cond,cond,strides,exemptFirst,exemptLast,'nanmedian',{'B','A1','A2','A3','P'});
ep=defineEpochs(cond,cond,strides,exemptFirst,exemptLast,'nanmean',{'Base','Adapt','Post'}); %epochs 
%% Define params we care about:
mOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'HIP', 'TFL', 'GLU'};
% mOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'ADM', 'TFL', 'GLU'};

% mOrder={'TA', 'MG', 'SEMT', 'VL','RF'}; %Muscles of interest 
nMusc=length(mOrder);
type='s';
labelPrefix=fliplr([strcat('f',mOrder) strcat('s',mOrder)]); %To display
labelPrefixLong= strcat(labelPrefix,['_' type]); %Actual names

%Adding alternative normalization parameters:
l2=group.adaptData{1}.data.getLabelsThatMatch('^Norm');
group=group.renameParams(l2,strcat('N',l2)).normalizeToBaselineEpoch(labelPrefixLong,baseEp,true); %Normalization to max=1 but not min=0

%Renaming normalized parameters, for convenience:
ll=group.adaptData{1}.data.getLabelsThatMatch('^Norm');
l2=regexprep(regexprep(ll,'^Norm',''),'_s','s');
group=group.renameParams(ll,l2);
newLabelPrefix=strcat(labelPrefix,'s');

%% get data:
padWithNaNFlag=true;
[dataEMG,labels,allDataEMG]=group.getPrefixedEpochData(newLabelPrefix,ep,padWithNaNFlag);
%Flipping EMG:
for i=1:length(allDataEMG)
    aux=reshape(allDataEMG{i},size(allDataEMG{i},1),size(labels,1),size(labels,2),size(allDataEMG{i},3));
    allDataEMG{i}=reshape(flipEMGdata(aux,2,3),size(aux,1),numel(labels),size(aux,4));
end

[~,~,dataContribs]=group.getEpochData(ep,{'netContributionNorm2'},padWithNaNFlag);

%% Save to hdf5 format for sharing with non-Matlab users
EMGdata=cell2mat(allDataEMG);
name='dynamicsDataYL03.h5';
h5create(name,'/EMGdata',size(EMGdata))
h5write(name,'/EMGdata',EMGdata)
SLA=squeeze(cell2mat(dataContribs));
h5create(name,'/SLA',size(SLA))
h5write(name,'/SLA',SLA)
% % speedDiff=[zeros(1,150),ones(1,900),zeros(1,600)];
speedDiff=[zeros(1,139),ones(1,2000),zeros(1,551)];
h5create(name,'/speedDiff',size(speedDiff))
h5write(name,'/speedDiff',speedDiff)
% breaks=[zeros(1,150),1,zeros(1,299),1,zeros(1,299),1,zeros(1,299),1,zeros(1,599)];
breaks=zeros(1,2190);
h5create(name,'/breaks',size(breaks))
h5write(name,'/breaks',breaks)
hdf5write(name,'/labels',l2,'WriteMode','append')
