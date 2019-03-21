addpath(genpath('../../../matlab-linsys/'))
addpath(genpath('../../../robustCov/'))
addpath(genpath('../../'))
%% First: load models fitted w/all data, look at BIC, AIC, LRT
load ../../res/allDataModels.mat model datSet
model=cellfun(@(x) x.canonize('canonical'),model,'UniformOutput',false);
vizDataLikelihood(model,datSet)
ph=findobj(gcf,'Type','Axes');
for i=1:length(ph)
  set(ph(i),'XTickLabelRotation',0,'XTickLabel',mat2cell(num2str([0:10]'),ones(11,1),2))
end
datSet.vizFit(model(2:5))
%% Second: load models trained on odd/even, look at cross-val logL
load('../../res/oddEvenCV_new.mat') %This dataset has the first stride of
%both adapt and post in the odd-fold.
%load('../../res/oddEvenCV2.mat') %These datasets contain the first stride 
%of adapt in the odd-fold, and the first of post in the even-fold

f1=vizDataLikelihood(fitMdlOE(:,1),datSetOE);
ph=findobj(gcf,'Type','Axes');
f2=vizDataLikelihood(fitMdlOE(:,2),datSetOE);
ph1=findobj(gcf,'Type','Axes');

fh=figure;
ah=copyobj(ph([2,3]),fh);
ah(1).Title.String={'Odd-model';'Cross-validation'};
ah(1).YAxis.Label.String={'Even-data'; 'log-L'};
ah(2).Title.String={'Odd-model';'-BIC/2'};
ah(2).XTickLabel={'1','2','3','4','5','6'};
ah(1).XTickLabel={'1','2','3','4','5','6'};
ah1=copyobj(ph1([1,4]),fh);
ah1(2).Title.String={'Even-model';'Cross-validation'};
ah1(2).YAxis.Label.String={'Odd-data';'log-L'};
ah1(2).XAxis.Label.String={'Model Order'};
ah1(2).XTickLabel={'1','2','3','4','5','6'};
ah1(1).XAxis.Label.String={'Model Order'};
ah1(1).XTickLabel={'1','2','3','4','5','6'};
ah1(1).Title.String={'Even-model';'-BIC/2'};
set(gcf,'Name','Odd/even cross-validation');


%% Third: load models trained on adapt/post, look at cross-val
%This dataset includes subject 16
% clear all
% load('../../res/adaptPostCVw16.mat')
% %Adapt data-trained, eval on post
% vizDataLikelihood(model(:,1),datSet)
% set(gcf,'Name','Adapt-data trained models');
% ph=findobj(gcf,'Type','Axes');
% ph(end).YAxis.Label.String='Adapt data';
% ph(end-3).YAxis.Label.String='Post data';
% %The opposite
% vizDataLikelihood(model(1:6,2),datSet) %The script failed before fitting the order 6 model, thus, we just 
% set(gcf,'Name','Post-data trained models');
% ph=findobj(gcf,'Type','Axes');
% ph(end).YAxis.Label.String='Adapt data';
% ph(end-3).YAxis.Label.String='Post data';
%% Fourth: load models trained on adapt/post, look at cross-val
clear all
load('../../res/adaptPostCV.mat')
f1=vizDataLikelihood(model(:,1),datSet);
ph=findobj(gcf,'Type','Axes');
f2=vizDataLikelihood(model(:,2),datSet);
ph1=findobj(gcf,'Type','Axes');

fh=figure;
ah=copyobj(ph([2,3]),fh);
ah(1).Title.String={'Adapt-model';'Cross-validation'};
ah(1).YAxis.Label.String={'Post-data'; 'log-L'};
ah(2).Title.String={'Adapt-model';'-BIC/2'};
ah(2).XTickLabel={'0','1','2','3','4','5','6'};
ah(1).XTickLabel={'0','1','2','3','4','5','6'};
ah1=copyobj(ph1([1,4]),fh);
ah1(2).Title.String={'Post-model';'Cross-validation'};
ah1(2).YAxis.Label.String={'Adapt-data';'log-L'};
ah1(2).XAxis.Label.String={'Model Order'};
ah1(2).XTickLabel={'0','1','2','3','4','5','6'};
ah1(1).XAxis.Label.String={'Model Order'};
ah1(1).XTickLabel={'0','1','2','3','4','5','6'};
ah1(1).Title.String={'Post-model';'-BIC/2'};
set(gcf,'Name','Adapt/Post cross-validation');

%% sqrt data: to check that the long tail of the data does not affect results
load ../../res/allDataModelsSqrt.mat model datSet

vizDataLikelihood(model(1:9),datSet)
ph=findobj(gcf,'Type','Axes');
for i=1:length(ph)
  set(ph(i),'XTickLabelRotation',0,'XTickLabel',mat2cell(num2str([0:10]'),ones(11,1),2))
end