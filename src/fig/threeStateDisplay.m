load('/Datos/Documentos/code/EMG-LTI-SSM/res/allDataRedAlt_20190425T210335.mat')
legacy_vizSingleModelMLMC(modelRed{4},datSet.out,datSet.in)
saveFig(gcf,'../../fig/','threeState',0)