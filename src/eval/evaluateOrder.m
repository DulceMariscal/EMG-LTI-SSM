addpath(genpath('../../matlab-linsys/'))
addpath(genpath('../../robustCov/'))
%% First: load models fitted w/all data, look at BIC, AIC, LRT
load ../../res/allDataModels.mat model datSet

vizDataLikelihood(model,datSet)
ph=findobj(gcf,'Type','Axes');
for i=1:length(ph)
  set(ph(i),'XTickLabelRotation',0,'XTickLabel',mat2cell(num2str([0:10]'),ones(11,1),2))
end

%% Second: load models trained on odd/even, look at cross-val logL
load('../../res/oddEvenCV_.mat')

%Odd-trained on even data
vizDataLikelihood(model(:,1),datSet)
set(gcf,'Name','Odd-data trained models');
ph=findobj(gcf,'Type','Axes');
ph(end).YAxis.Label.String='Odd data';
ph(end-3).YAxis.Label.String='Even data';
%The opposite
vizDataLikelihood(model(:,2),datSet)
set(gcf,'Name','Even-data trained models');
ph=findobj(gcf,'Type','Axes');
ph(end).YAxis.Label.String='Odd data';
ph(end-3).YAxis.Label.String='Even data';

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
%Adapt data-trained, eval on post
vizDataLikelihood(model(:,1),datSet)
set(gcf,'Name','Adapt-data trained models');
ph=findobj(gcf,'Type','Axes');
ph(end).YAxis.Label.String='Adapt data';
ph(end-3).YAxis.Label.String='Post data';
%The opposite
vizDataLikelihood(model(:,2),datSet) 
set(gcf,'Name','Post-data trained models');
ph=findobj(gcf,'Type','Axes');
ph(end).YAxis.Label.String='Adapt data';
ph(end-3).YAxis.Label.String='Post data';