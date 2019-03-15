%%
addpath(genpath('../../../matlab-linsys/'))
addpath(genpath('../../../'))
%%
load ../../res/allDataModels.mat model
model=model(2:end);
%% See canonical models
model=cellfun(@(x) x.canonize('canonical'),model,'UniformOutput',false);
linsys.vizMany(model(1:4))
%%

%%
model=cellfun(@(x) x.canonize('diagQ'),model,'UniformOutput',false);
linsys.vizMany(model(1:4))
model=cellfun(@(x) x.canonize('eyeQ'),model,'UniformOutput',false);
linsys.vizMany(model(1:4))

%% See adapt/post models
load ../../res/CV.mat fitMdlAP
nn={'Adap','Post'};
for k=1:2
    for j=1:size(fitMdlAP,1)
        fitMdlAP{j,k}.name=[nn{k} ' ' num2str(j-1)];
    end
end
mdl=cellfun(@(x) x.canonize('canonical'),fitMdlAP(:),'UniformOutput',false);
mdl=reshape(mdl,size(fitMdlAP));
mdl=mdl(2:4,1:2);
linsys.vizMany(mdl(1:end-1)) %Adap 1,2,3; Post 1,2