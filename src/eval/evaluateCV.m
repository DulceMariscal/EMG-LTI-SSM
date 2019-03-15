addpath(genpath('../../../matlab-linsys/'))
addpath(genpath('../../../robustCov/'))
addpath(genpath('../../'))

%% Second: load models trained on odd/even, look at cross-val logL
load('../../res/CV.mat')

f1=vizDataLikelihood(fitMdlOE(:,1),datSetOE);
ph=findobj(gcf,'Type','Axes');
f2=vizDataLikelihood(fitMdlOE(:,2),datSetOE);
ph1=findobj(gcf,'Type','Axes');

fh=figure;
ah=copyobj(ph([2,3]),fh);
ah(1).Title.String={'Odd-model';'Cross-validation'};
ah(1).YAxis.Label.String={'Even-data'; 'log-L'};
ah(2).Title.String={'Odd-model';'-BIC/2'};
ah(2).XTickLabel={'0','1','2','3','4','5','6'};
ah(1).XTickLabel={'0','1','2','3','4','5','6'};
ah1=copyobj(ph1([1,4]),fh);
ah1(2).Title.String={'Even-model';'Cross-validation'};
ah1(2).YAxis.Label.String={'Odd-data';'log-L'};
ah1(2).XAxis.Label.String={'Model Order'};
ah1(2).XTickLabel={'0','1','2','3','4','5','6'};
ah1(1).XAxis.Label.String={'Model Order'};
ah1(1).XTickLabel={'0','1','2','3','4','5','6'};
ah1(1).Title.String={'Even-model';'-BIC/2'};
set(gcf,'Name','Odd/even cross-validation');


%% Fourth: load models trained on adapt/post, look at cross-val

f1=vizDataLikelihood(fitMdlAP(:,1),datSetAP);
ph=findobj(gcf,'Type','Axes');
f2=vizDataLikelihood(fitMdlAP(:,2),datSetAP);
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

%%
mdl=cellfun(@(x) x.canonize('canonical'),fitMdlAP(:),'UniformOutput',false);
mdl=reshape(mdl,size(fitMdlAP));

%On trained data:
f1=datSetAP{1}.vizFit(mdl(2:5,1));
f2=datSetAP{2}.vizFit(mdl(2:5,2));
%crossval
f1=datSetAP{2}.vizFit(mdl(2:5,1));
f2=datSetAP{1}.vizFit(mdl(2:5,2));
