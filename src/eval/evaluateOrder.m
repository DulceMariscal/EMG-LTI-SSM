addpath(genpath('../../matlab-linsys/'))
addpath(genpath('../../robustCov/'))
%% First: load models fitted w/o breaks, filter each block independently, compare states
load ../../res/allDataModels.mat model datSet

vizDataLikelihood(model,datSet)
ph=findobj(gcf,'Type','Axes');
for i=1:length(ph)
  set(ph(i),'XTickLabelRotation',0,'XTickLabel',mat2cell(num2str([0:10]'),ones(11,1),2))
end
