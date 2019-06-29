%% Load real data:
sqrtFlag=false;
subjIdx=[2:6,8,10:15]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post), C16 (missed first trial of Adapt)
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag);
Uf=[U;ones(size(U))];
datSet=dset(Uf,Yasym');

%% Reduce data
Y=datSet.out;
U=datSet.in;
X=Y-(Y/U)*U; %Projection over input
s=var(X'); %Estimate of variance
flatIdx=s<.005; %Variables are split roughly in half at this threshold

%Yasym=Yasym(:,~flatIdx); %Only non-flat vars
%% Everything is gaussian
figure;
offset=[50,950,1550];
for j=1:3
    
Yb=Yasym(offset(j)+[1:100],:); %Last 100 of some epoch
clear p
for i=1:size(Yb,2)
    [~,p(i)]=lillietest(Yb(:,i));
end
[h,pTh]=BenjaminiHochberg(p,.05,true);

subplot(1,3,j)
histogram(p,0:.01:1)
title(['Rejected tests = ' num2str(sum(h))])
end
%% See z-scores, and spectrum of the data
z=zscore(Yb); %This is a shift-and-normalize approach to get all the muscles in the same basis
figure
subplot(1,2,1) %Gaussianity
qqplot(z(:))

% see spectrum at steady-state (should look flat)
figure;
offset=[50,950,1550];
for j=1:3
    
Yb=Yasym(offset(j)+[1:100],:); %Last 100 of some epoch
subplot(1,3,j)
hold on
plot(mean(abs(fft(Yb)),2))
%for i=1:size(Yb,2)
%    plot(abs(fft(Yb(:,i))))
%end
end

% see overall spectrum
figure
plot(mean(abs(fft(Yasym)),2))
hold on
for i=1:size(Yb,2)
    plot(abs(fft(Yasym(:,i))))
end

%% Evaluate drift in data:
Yb=Yasym(51:150,:); %Baseline data
Yp=Yasym(1551:1650,:); %Late post

%Mean drift:
clear p
for i=1:size(Yasym,2)
    [~,p(i)]=ttest2(Yb(:,i),Yp(:,i));
end
[h,pTh]=BenjaminiHochberg(p,.05,true);
sum(h)
figure('Name','Drift quantification')
subplot(1,2,1)
imagesc(reshape(mean(Yp-Yb),12,15)')

title(['Rejected variables, N=' num2str(sum(h)) '/' num2str(length(h))])
caxis([-1 1].*.3)
myFiguresColorMap
colormap(flipud(map))
mList={'TA','PER','SOL','LG','MG','BF','SMB','SMT','VM','VL','RF','HIP','ADM','TFL','GLU'};
set(gca,'YTick',1:15,'YTickLabel',mList(end:-1:1),'XTick',[1,4,7,10],'XTickLabel',{'DS','SINGLE','DS','SWING'});

% Evaluate drif in variances:
clear p
for i=1:size(Yasym,2)
    [~,p(i)]=vartest2(Yb(:,i),Yp(:,i)); %Using two sample F-test
end
[h,pTh]=BenjaminiHochberg(p,.05,true);
sum(h)
subplot(1,2,2)
e=var(Yp)-var(Yb);
imagesc(reshape(e,12,15)')

title(['Rejected variables, N=' num2str(sum(h)) '/' num2str(length(h)) ', reduced variances=' num2str(sum(e(h==1)<0))])
caxis([-1 1].*.01)
myFiguresColorMap
colormap(flipud(map))
mList={'TA','PER','SOL','LG','MG','BF','SMB','SMT','VM','VL','RF','HIP','ADM','TFL','GLU'};
set(gca,'YTick',1:15,'YTickLabel',mList(end:-1:1),'XTick',[1,4,7,10],'XTickLabel',{'DS','SINGLE','DS','SWING'});
m=e./var(Yb);
median(m(h==1))

%% %Look at another way of quantifying heteroskedasticity
variabiltyAnalysis