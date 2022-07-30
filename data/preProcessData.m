%%
%Running this script requires labTools (github.com/pittSMLlab/labTools/)
%% Aux vars:
% groupName='controls';
% matDataDir='./';
% loadName=[matDataDir 'controlData'];
% load(loadName)

%%
group=adaptationData.createGroupAdaptData({'C0002params','C0003params','C0004params','C0005params','C0006params','C0007params','C0008params','C0009params','C0010params',...
    'C0011params','C0012params','C0013params','C0014params','C0015params','C0016params'});
age=group.getSubjectAgeAtExperimentDate/12;

%% Change Adaptation condition to Adapt1,2,3
for i=1:length(group.adaptData)
  N=length(group.adaptData{i}.metaData.conditionName);
  idx=find(strcmp('Adaptation',group.adaptData{i}.metaData.conditionName)); %Idx of Adaptation condition
  group.adaptData{i}.metaData.conditionName(idx:N+2)=[{'Adapt1','Adapt2','Adapt3'} group.adaptData{i}.metaData.conditionName(idx+1:N)];
  trialIdx=group.adaptData{i}.metaData.trialsInCondition{idx}
  aux=mat2cell(trialIdx,1,ones(1,3));
  group.adaptData{i}.metaData.trialsInCondition(idx:N+2)=[aux group.adaptData{i}.metaData.trialsInCondition(idx+1:N)];
end

%% Define epochs
baseEp=getBaseEpoch;
%Adaptation epochs
strides=[-50 300 300 300 300];exemptFirst=[0];exemptLast=[0];
names={};
shortNames={};
cond={'TM Base','Adapt1','Adapt2','Adapt3','Washout'};
ep=defineEpochs(cond,cond,strides,exemptFirst,exemptLast,'nanmedian',{'B','A1','A2','A3','P'});

%% Define params we care about:
mOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'HIP', 'ADM', 'TFL', 'GLU'};
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
h5create('dynamicsData.h5','/EMGdata',size(EMGdata))
h5write('dynamicsData.h5','/EMGdata',EMGdata)
SLA=squeeze(cell2mat(dataContribs));
h5create('dynamicsData.h5','/SLA',size(SLA))
h5write('dynamicsData.h5','/SLA',SLA)
speedDiff=[zeros(1,50),ones(1,900),zeros(1,300)];
h5create('dynamicsData.h5','/speedDiff',size(speedDiff))
h5write('dynamicsData.h5','/speedDiff',speedDiff)
breaks=[zeros(1,50),1,zeros(1,299),1,zeros(1,299),1,zeros(1,299),1,zeros(1,299)];
h5create('dynamicsData.h5','/breaks',size(breaks))
h5write('dynamicsData.h5','/breaks',breaks)
hdf5write('dynamicsData.h5','/labels',l2,'WriteMode','append')