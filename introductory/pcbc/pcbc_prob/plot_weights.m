function plot_weights()
%Test encoding and decoding of simple, monomodal, gaussian probability distributions
inputs=[-180:1:180];
centres=[-180:20:180];

%define weights, to produce a 1d basis function network, where nodes have gaussian RFs.
W=[];
for c=centres
  W=[W;code(c,inputs,10,0,1)];
end

figure(1),clf, plot(W','LineWidth',2)
set(gca,'XTick',[1:90:360],'XTickLabel',[-180:90:179],'FontSize',14);
axis([1,360,0,0.041])
set(gcf,'PaperSize',[12 5],'PaperPosition',[0 0.25 12 4.5],'PaperOrientation','Portrait');
print(gcf, '-dpdf', 'weights_noprior.pdf');

%define weights, to produce a 1d basis function network, where nodes have gaussian RFs. Strength of RFs is modulated by prior distribution. 
priorMean=0;
priorStd=60;
priorDist=code(priorMean,inputs,priorStd);
W=[];
for c=centres
  W=[W;code(c,inputs,10,0,1).*priorDist];
end

figure(2), clf, plot(W','LineWidth',2)
set(gca,'XTick',[1:90:360],'XTickLabel',[-180:90:179],'FontSize',14);
axis([1,360,0,0.041])
set(gcf,'PaperSize',[12 5],'PaperPosition',[0 0.25 12 4.5],'PaperOrientation','Portrait');
print(gcf, '-dpdf', 'weights_prior.pdf');

