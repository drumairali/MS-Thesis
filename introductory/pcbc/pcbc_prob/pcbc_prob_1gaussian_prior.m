function pcbc_prob_1gaussian_prior()
%Test encoding and decoding of simple, monomodal, gaussian probability distributions when network weights are modified so as to include a prior
inputs=[-180:5:180];
centres=[-180:10:180];

priorMean=0;
priorStd=60;
priorDist=code(priorMean,inputs,priorStd);

%define weights, to produce a 1d basis function network, where nodes have gaussian RFs. Strength of RFs is modulated by prior distribution. 
W=[];
for c=centres
  W=[W;code(c,inputs,10,0,1).*priorDist];
end
[n,m]=size(W);

%define test cases
stdx=20;
X=zeros(m,3);
X(:,1)=code(93,inputs,20,0,0,stdx)'; 
X(:,2)=code(93,inputs,30,0,0,stdx)'; 
X(:,3)=code(-30,inputs,20,0,0,stdx)';
X(:,4)=code(-30,inputs,40,0,0,stdx)';

for k=1:size(X,2)
  x=X(:,k);
  [y,e,r]=dim_activation(W,x);
  figure(k),clf
  plot_result1(x,r,y,inputs,centres);
  plot(x'.*priorDist,'LineWidth',3); %plot true posterior
  print(gcf, '-dpdf', ['probability_1gaussian_prior',int2str(k),'.pdf']); 
end



%test performance over many trials
trials=1e5
compare_means=zeros(trials,3);
compare_vars=zeros(trials,3);
for k=1:trials
  likelihoodMean=180*rand-90;
  likelihoodStd=15+30*rand;
  x=code(likelihoodMean,inputs,likelihoodStd,1,0,stdx)'; %noisy PPC
  [y,e,r]=dim_activation(W,x);
  
  [posteriortrueMean,posteriortrueVar]=stats_gaussian_combination([likelihoodMean,priorMean],[likelihoodStd.^2,priorStd.^2]);
  [likelihoodmuact,likelihoodvaract]=decode(x',inputs);
  [posteriormuact, posteriorvaract]=stats_gaussian_combination([likelihoodmuact,priorMean],[likelihoodvaract,priorStd.^2]);
  [posteriormuest,posteriorvarest]=decode(r',inputs);

  compare_means(k,:)=[posteriortrueMean,posteriormuact,posteriormuest];
  compare_vars(k,:)=[posteriortrueVar,posteriorvaract,posteriorvarest];
end
toplot=1:100;
figure(size(X,2)+1),clf
plot(compare_means(toplot,2),compare_means(toplot,3),'o','MarkerFaceColor','b','MarkerSize',6);
hold on
plot([-100,100],[-100,100],'k--','LineWidth',2)
set(gca,'YTick',[-90:90:90],'XTick',[-90:90:90],'FontSize',15)
axis('equal','tight')
xlabel('Optimal Estimate of Mean  ');
ylabel('Network Estimate of Mean  ')
set(gcf,'PaperSize',[10 8],'PaperPosition',[0 0.25 10 7.5],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_1gaussian_prior_mean_accuracy.pdf']);

figure(size(X,2)+2),clf
plot(compare_vars(toplot,2),compare_vars(toplot,3),'o','MarkerFaceColor','b','MarkerSize',6);
hold on
plot([100,1500],[100,1500],'k--','LineWidth',2)
set(gca,'YTick',[400:400:1200],'YTickLabel',' ','XTick',[400:400:1200],'FontSize',15)
text([100,100,100]-10,[400:400:1200],int2str([400:400:1200]'),'Rotation',90,'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize',15)
axis('equal','tight')
xlabel({'Optimal Estimate of \sigma^2  ';'  '});
ylabel({'Network Estimate of \sigma^2  ';'  '});
set(gcf,'PaperSize',[10 8],'PaperPosition',[0 0.25 10 7.5],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_1gaussian_prior_var_accuracy.pdf']);

error=abs(compare_means(:,2)-compare_means(:,3));
disp('Comparing Means (difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);

error=100.*abs(compare_vars(:,2)-compare_vars(:,3))./compare_vars(:,2);
disp('Comparing Variances (% difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);
