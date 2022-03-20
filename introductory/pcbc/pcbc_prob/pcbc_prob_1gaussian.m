function pcbc_prob_1gaussian()
%Test encoding and decoding of simple, monomodal, gaussian probability distributions
inputs=[-180:5:180];
centres=[-180:10:180];

%define weights to produce a 1d basis function network where nodes have gaussian RFs.
W=[];
for c=centres
  W=[W;code(c,inputs,10,0,1)];
end
[n,m]=size(W);
n
plot(W)
%define test cases
stdx=20;
X=zeros(m,3);
X(:,1)=code(93,inputs,stdx,1,0,stdx)'; %noisy
X(:,2)=code(93,inputs,stdx.*1.5,1,0,stdx)'; %noisy
X(:,3)=code(93,inputs,stdx,0,0,stdx)'; %no noise

for k=1:size(X,2)
  x=X(:,k);
  [y,e,r,ytrace,rtrace]=dim_activation(W,x);
  %y=mean(ytrace,2);r=mean(rtrace,2);
  figure(k),clf
  plot_result1(x,r,y,inputs,centres);
  print(gcf, '-dpdf', ['probability_1gaussian',int2str(k),'.pdf']);
end



%test performance over many trials
trials=1e5
compare_means=zeros(trials,3);
compare_vars=zeros(trials,3);
for k=1:trials
  trueMean=180*rand-90;  
  trueStd=15+30*rand; 
  x=code(trueMean,inputs,trueStd,1,0,stdx)'; %noisy PPC
  [y,e,r,ytrace,rtrace]=dim_activation(W,x);
  %y=mean(ytrace,2);  r=mean(rtrace,2);
  [muact,varact]=decode(x',inputs);
  [muest,varest]=decode(r',inputs);
  compare_means(k,:)=[trueMean,muact,muest];
  compare_vars(k,:)=[trueStd^2,varact,varest];
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
print(gcf, '-dpdf', ['probability_1gaussian_mean_accuracy.pdf']);

figure(size(X,2)+2),clf
plot(compare_vars(toplot,2),compare_vars(toplot,3),'o','MarkerFaceColor','b','MarkerSize',6);
hold on
plot([100,2400],[100,2400],'k--','LineWidth',2)
set(gca,'YTick',[400:800:2000],'YTickLabel',' ','XTick',[400:800:2000],'FontSize',15)
text([100,100,100]-10,[400:800:2000],int2str([400:800:2000]'),'Rotation',90,'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize',15)
axis('equal','tight')
xlabel('Optimal Estimate of \sigma^2  ');
ylabel({'Network Estimate of \sigma^2  ';'  '});
set(gcf,'PaperSize',[10 8],'PaperPosition',[0 0.25 10 7.5],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_1gaussian_var_accuracy.pdf']);

error=abs(compare_means(:,2)-compare_means(:,3));
disp('Comparing Means (difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);

error=100.*abs(compare_vars(:,2)-compare_vars(:,3))./compare_vars(:,2);
disp('Comparing Variances (% difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);

%error=abs(compare_means(:,1)-compare_means(:,3));
%disp('Comparing Means (difference between network and true mean)')
%disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);

%error=100.*abs(compare_vars(:,1)-compare_vars(:,3))./compare_vars(:,2);
%disp('Comparing Variances (% difference between network and true variance)')
%disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);
