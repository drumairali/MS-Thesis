function pcbc_prob_2integrate()
%perform optimal feature integration given two Gaussian probability distributions
inputs=[randi([-10 10],1,2)];
centres=[-180:15:180];

%define weights, to produce a 2d basis function network, where nodes have gaussian RFs.
W=[];
for c=centres
  W=[W;code(c,inputs,15,0,1),code(c,inputs,15,0,1)];
end
W=W./2;
[n,m]=size(W);

%define test cases
stdx=20;
X=zeros(m,4);
X(:,1)=[code(-20,inputs,20,0,0,stdx),code(-10,inputs,20,0,0,stdx)]'; 
X(:,2)=[code(-20,inputs,20,0,0,stdx),code(-10,inputs,40,0,0,stdx)]'; 
X(:,3)=[code(-20,inputs,20,0,0,stdx),code(70,inputs,20,0,0,stdx)]'; 
X(:,4)=[code(-20,inputs,20,0,0,stdx)+code(50,inputs,20,0,0,stdx),code(70,inputs,20,0,0,stdx)]'; 

%present test cases to network and record results
for k=1:size(X,2)
  x=X(:,k);
  [y,e,r]=dim_activation(W,x);
  figure(k),clf
  plot_result2(x,r,y,2,inputs,centres);
  if k<3, hold on, plot(x(1:length(inputs))'.*x(1+length(inputs):end)','LineWidth',3); end
  print(gcf, '-dpdf', ['probability_2integrate',int2str(k),'.pdf']);
end



%test accuracy across many random trials (Ma et al's method)
numTrials=1008
numTests=100
compare_means=zeros(numTests,2);
compare_vars=zeros(numTests,2);
for k=1:numTests
  fprintf(1,'.%i.',k); 
  %select parameters of input
  mu1=0; 
  mu2=mu1+(24*rand-12);
  sigma1=20+40*rand;
  sigma2=20+40*rand;
  
  %for these parameters average estimates over many trials
  for trial=1:numTrials
    %batch together all trials fo faster execution of dim
    x(:,trial)=[code(mu1,inputs,sigma1,1,0,stdx),code(mu2,inputs,sigma2,1,0,stdx)]';
  end
  [y,e,r]=dim_activation(W,x);
 
  mu3Mean=[];
  var3Mean=[];
  mu3estMean=[];
  var3estMean=[];
  for trial=1:numTrials
    %analyse results from each trial
    [mu1act,var1act]=decode(x(1:length(inputs),trial)',inputs);
    [mu2act,var2act]=decode(x(1+length(inputs):end,trial)',inputs);
    
    [mu3Mean(trial),var3Mean(trial)]=stats_gaussian_combination([mu1act,mu2act],[var1act,var2act]);
    [mu3estMean(trial),var3estMean(trial)]=decode(r(1:length(inputs),trial)',inputs,2);
  end
  %take average results across trials
  compare_means(k,:)=[nanmean(mu3Mean),nanmean(mu3estMean)];
  compare_vars(k,:)=[nanmean(var3Mean),nanmean(var3estMean)];
end
disp(' ')

figure(size(X,2)+1),clf
plot(compare_means(:,1),compare_means(:,2),'o','MarkerFaceColor','b','MarkerSize',6);
hold on
plot([-10,10],[-10,10],'k--','LineWidth',2)
set(gca,'YTick',[-8:8:8],'XTick',[-8:8:8],'FontSize',15)
axis('equal','tight')
xlabel('Optimal Estimate of Mean  ');
ylabel('Network Estimate of Mean  ')
set(gcf,'PaperSize',[10 8],'PaperPosition',[0 0.25 10 7.5],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_2integrate_mean_accuracy.pdf']);

figure(size(X,2)+2),clf
plot(compare_vars(:,1),compare_vars(:,2),'o','MarkerFaceColor','b','MarkerSize',6);
hold on
plot([100,1800],[100,1800],'k--','LineWidth',2)
set(gca,'YTick',[500:500:1500],'YTickLabel',' ','XTick',[500:500:1500],'FontSize',15)
text([100,100,100]-10,[500:500:1500],int2str([500:500:1500]'),'Rotation',90,'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize',15)
axis('equal','tight')
xlabel({'Optimal Estimate of \sigma^2  ';'  '});
ylabel({'Network Estimate of \sigma^2  ';'  '});
set(gcf,'PaperSize',[10 8],'PaperPosition',[0 0.25 10 7.5],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_2integrate_var_accuracy.pdf']);

error=abs(compare_means(:,1)-compare_means(:,2));
disp('Comparing Means (difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);

error=100.*abs(compare_vars(:,1)-compare_vars(:,2))./compare_vars(:,1);
disp('Comparing Variances (% difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);
