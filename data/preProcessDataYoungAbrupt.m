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
group=TMFullAbrupt;
age=group.getSubjectAgeAtExperimentDate/12;

%% %this section is not necesary for the young adult data 
%Change Adaptation condition to Adapt1,2,3

% for i=1:length(group.adaptData)
%   N=length(group.adaptData{i}.metaData.conditionName);
%   idx=find(strcmp('adaptation',group.adaptData{i}.metaData.conditionName)); %Idx of Adaptation condition
%   group.adaptData{i}.metaData.conditionName(idx:N+2)=[{'Adapt1','Adapt2','Adapt3'} group.adaptData{i}.metaData.conditionName(idx+1:N)];
% %   group.adaptData{i}.metaData.conditionName(idx)=[{'gradual adaptation'} group.adaptData{i}.metaData.conditionName(idx)];
%   trialIdx=group.adaptData{i}.metaData.trialsInCondition{idx}
%   aux=mat2cell(trialIdx,1,ones(1,3));
%   group.adaptData{i}.metaData.trialsInCondition(idx:N+2)=[aux group.adaptData{i}.metaData.trialsInCondition(idx+1:N)];
% end
%% Define epochs
baseEp=getBaseEpoch;
%Adaptation epochs
% strides=[-150 300 300 300 600];exemptFirst=[0];exemptLast=[0];
strides=[-100 900 300];exemptFirst=[0];exemptLast=[0]; %Strides needed
names={};
shortNames={};
% cond={'TM Base','Adapt1','Adapt2','Adapt3','Washout'};
cond={'TM base','gradual adaptation','TM post'}; %Conditions for this group 
% ep=defineEpochs(cond,cond,strides,exemptFirst,exemptLast,'nanmedian',{'B','A1','A2','A3','P'});
ep=defineEpochs(cond,cond,strides,exemptFirst,exemptLast,'nanmedian',{'B','A1','P'}); %epochs 
%% Define params we care about:
% mOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'HIP', 'ADM', 'TFL', 'GLU'};
mOrder={'TA', 'MG', 'SEMT', 'VL','RF'}; %Muscles of interest 
nMusc=length(mOrder);
type='s';
labelPrefix=fliplr([strcat('f',mOrder) strcat('s',mOrder)]); %To display
labelPrefixLong= strcat(labelPrefix,['_' type]); %Actual names

%Adding alternative normaliza tion parameters:
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
name='dynamicsDataRedMuscleYoung.h5';
h5create(name,'/EMGdata',size(EMGdata))
h5write(name,'/EMGdata',EMGdata)
SLA=squeeze(cell2mat(dataContribs));
h5create(name,'/SLA',size(SLA))
h5write(name,'/SLA',SLA)
% speedDiff=[zeros(1,150),ones(1,900),zeros(1,600)];
speedDiff=[zeros(1,100),ones(1,900),zeros(1,300)];
h5create(name,'/speedDiff',size(speedDiff))
h5write(name,'/speedDiff',speedDiff)
% breaks=[zeros(1,150),1,zeros(1,299),1,zeros(1,299),1,zeros(1,299),1,zeros(1,599)];
breaks=[zeros(1,1300)];
h5create(name,'/breaks',size(breaks))
h5write(name,'/breaks',breaks)
hdf5write(name,'/labels',l2,'WriteMode','append')
