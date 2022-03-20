function pcbc_prob_3integrate()
%perform optimal feature integration given three Gaussian probability distributions
inputs=[-180:10:180];
centres=[-180:15:180];

%define weights, to produce a 2d basis function network, where nodes have gaussian RFs.
W=[];
for c=centres
  W=[W;code(c,inputs,15,0,1),code(c,inputs,15,0,1),code(c,inputs,15,0,1)];
end
W=W./3;
[n,m]=size(W);
figure(7)
plot(W)
%define test cases
stdx=20;
X=zeros(m,4);
X(:,1)=[code(-20,inputs,20,0,0,stdx),code(-25,inputs,20,0,0,stdx),code(-19,inputs,20,0,0,stdx)]'; 

%present test cases to network and record results
for k=1:size(X,2)
  x=X(:,k);
  [y,e,r]=dim_activation(W,x);
  figure(k),clf
  plot_result(x,r,y,3,inputs,inputs,inputs);
  if k<3, hold on, comb=x(1:length(inputs))'.*x(length(inputs)+[1:length(inputs)])'.*x(1+2*length(inputs):end)'; plot(comb,'LineWidth',3);  max(comb), end
  print(gcf, '-dpdf', ['probability_3integrate',int2str(k),'.pdf']);
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
  mu3=mu1+(24*rand-12);
  sigma1=20+40*rand;
  sigma2=20+40*rand;
  sigma3=20+40*rand;
  
  %for these parameters average estimates over many trials
  for trial=1:numTrials
    %batch together all trials fo faster execution of dim
    x(:,trial)=[code(mu1,inputs,sigma1,1,0,stdx),code(mu2,inputs,sigma2,1,0,stdx),code(mu3,inputs,sigma3,1,0,stdx)]';
  end
  [y,e,r]=dim_activation(W,x);
 
  mu4Mean=[];
  var4Mean=[];
  mu4estMean=[];
  var4estMean=[];
  for trial=1:numTrials
    %analyse results from each trial
    [mu1act,var1act]=decode(x(1:length(inputs),trial)',inputs);
    [mu2act,var2act]=decode(x(length(inputs)+[1:length(inputs)],trial)',inputs);
    [mu3act,var3act]=decode(x(1+2*length(inputs):end,trial)',inputs);
    
    [mu4Mean(trial),var4Mean(trial)]=stats_gaussian_combination([mu1act,mu2act,mu3act],[var1act,var2act,var3act]);
    [mu4estMean(trial),var4estMean(trial)]=decode(r(1:length(inputs),trial)',inputs,3);
  end
  %take average results across trials
  compare_means(k,:)=[nanmean(mu4Mean),nanmean(mu4estMean)];
  compare_vars(k,:)=[nanmean(var4Mean),nanmean(var4estMean)];
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
print(gcf, '-dpdf', ['probability_3integrate_mean_accuracy.pdf']);

figure(size(X,2)+2),clf
plot(compare_vars(:,1),compare_vars(:,2),'o','MarkerFaceColor','b','MarkerSize',6);
hold on
plot([100,1200],[100,1200],'k--','LineWidth',2)
set(gca,'YTick',[200:400:1000],'YTickLabel',' ','XTick',[200:400:1000],'FontSize',15)
text([100,100,100]-10,[200:400:1000],int2str([200:400:1000]'),'Rotation',90,'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize',15)
axis('equal','tight')
xlabel({'Optimal Estimate of \sigma^2  ';'  '});
ylabel({'Network Estimate of \sigma^2  ';'  '});
set(gcf,'PaperSize',[10 8],'PaperPosition',[0 0.25 10 7.5],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_3integrate_var_accuracy.pdf']);

error=abs(compare_means(:,1)-compare_means(:,2));
disp('Comparing Means (difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);

error=100.*abs(compare_vars(:,1)-compare_vars(:,2))./compare_vars(:,1);
disp('Comparing Variances (% difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);



function plot_result(x,r,y,expon,Ainputs,Binputs,Rinputs)
xA=x(1:length(Ainputs));
xB=x(length(Ainputs)+[1:length(Binputs)]);
xR=x(length(Ainputs)+length(Binputs)+[1:length(Rinputs)]);
rA=r(1:length(Ainputs));
rB=r(length(Ainputs)+[1:length(Binputs)]);
rR=r(length(Ainputs)+length(Binputs)+[1:length(Rinputs)]);
top=1.05;

tolabel=[10:9:length(Ainputs)-1];
axes('Position',[0.12,0.05,0.24,0.24]),
bar(xA,1,'k'),axis([0.5,length(xA)+0.5,0,top])
set(gca,'XTick',tolabel,'XTickLabel',Ainputs(tolabel),'FontSize',18);
plot_decode(xA,Ainputs);
text(0.03,1,'x_a','Units','normalized','color','k','FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.38,0.05,0.24,0.24]),
bar(xB,1,'k'),axis([0.5,length(xB)+0.5,0,top])
set(gca,'YTick',[],'XTick',tolabel,'XTickLabel',Binputs(tolabel),'FontSize',18);
plot_decode(xB,Binputs);
text(0.03,1,'x_b','Units','normalized','color','k','FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.64,0.05,0.24,0.24]),
bar(xR,1,'k'),axis([0.5,length(xR)+0.5,0,top])
set(gca,'YTick',[],'XTick',tolabel,'XTickLabel',Rinputs(tolabel),'FontSize',18);
plot_decode(xR,Rinputs);
text(0.03,1,'x_c','Units','normalized','color','k','FontSize',18,'FontWeight','bold','VerticalAlignment','top')


axes('Position',[0.12,0.38,0.76,0.24]),
bar(y,1,'r'),axis([0.5,length(y)+0.5,0,0.7])
set(gca,'XTick',[2:4:length(y)-1],'XTickLabel',[2:4:length(y)-1],'YTick',[0,0.5],'FontSize',18);
text(0.01,1,'y','Units','normalized','color','r','FontSize',18,'FontWeight','bold','VerticalAlignment','top')


labelVar=0;
top=1.05;
axes('Position',[0.12,0.71,0.24,0.24]),
bar(rA.^3,1,'FaceColor',[0,0.7,0]),axis([0.5,length(rA)+0.5,0,top])
set(gca,'XTick',tolabel,'XTickLabel',Ainputs(tolabel),'FontSize',18);
plot_decode(rA,Ainputs,expon,labelVar);
text(0.03,0.94,'r_a^3','Units','normalized','color',[0,0.7,0],'FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.38,0.71,0.24,0.24]),
bar(rB.^3,1,'FaceColor',[0,0.7,0]),axis([0.5,length(rB)+0.5,0,top])
set(gca,'YTick',[],'XTick',tolabel,'XTickLabel',Binputs(tolabel),'FontSize',18);
plot_decode(rB,Binputs,expon,labelVar);
text(0.03,0.94,'r_b^3','Units','normalized','color',[0,0.7,0],'FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.64,0.71,0.24,0.24]),
bar(rR.^3,1,'FaceColor',[0,0.7,0]),axis([0.5,length(rR)+0.5,0,top])
set(gca,'YTick',[],'XTick',tolabel,'XTickLabel',Rinputs(tolabel),'FontSize',18);
plot_decode(rR,Rinputs,expon,labelVar);
text(0.03,0.94,'r_c^3','Units','normalized','color',[0,0.7,0],'FontSize',18,'FontWeight','bold','VerticalAlignment','top')

set(gcf,'PaperSize',[18 16],'PaperPosition',[0 0.5 18 15],'PaperOrientation','Portrait');


