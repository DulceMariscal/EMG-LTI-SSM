addpath(genpath('../../../matlab-linsys/'))
%% First: load models fitted w/all data, look at BIC, AIC, LRT
load ../../res/allDataModels.mat model datSet

vizDataLikelihood(model(2:end),datSet) %Eliminating zero-order model, because it does not use diag R
set(gcf,'Name','Full models')
ph=findobj(gcf,'Type','Axes');
for i=1:length(ph)
  set(ph(i),'XTickLabelRotation',0,'XTickLabel',mat2cell(num2str([0:10]'),ones(11,1),2))
end

%% Second: models with imposed diagonal R
load ../../res/allDataModels_diagR.mat model datSet

vizDataLikelihood(model(2:end),datSet) %Eliminating zero-order model, because it does not use diag R
set(gcf,'Name','Diag R models')
ph=findobj(gcf,'Type','Axes');
for i=1:length(ph)
  set(ph(i),'XTickLabelRotation',0,'XTickLabel',mat2cell(num2str([0:10]'),ones(11,1),2))
end
%% Third: models with diagonal Q.
%Note: diagonal Q is a trivial imposition, there is always a model with
%diagonal Q. The true challenge would be to simultaneously diagonalize A
%and Q or something of the sort. 
load ../../res/allDataModels_diagQ.mat model datSet

vizDataLikelihood(model(2:end),datSet)
set(gcf,'Name','Diag Q models: TRIVIAL')
ph=findobj(gcf,'Type','Axes');
for i=1:length(ph)
  set(ph(i),'XTickLabelRotation',0,'XTickLabel',mat2cell(num2str([0:10]'),ones(11,1),2))
end