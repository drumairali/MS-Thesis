function pcbc_prob_4basis()
%calculate fn(a,b,c), where a, b and c are real numbers (in a limited range) and fn is +
Ainputs=[-60:5:60];
Binputs=[-60:5:60];
Cinputs=[-60:5:60];
Dinputs=[min(Ainputs)+min(Binputs)+min(Cinputs):10:max(Ainputs)+max(Binputs)+max(Cinputs)];
Acentres=[-60:5:60];
Bcentres=[-60:5:60];
Ccentres=[-60:5:60];

%define weights, to produce a 3d basis function network, where nodes have gaussian RFs.
W=[];
for a=Acentres
  for b=Bcentres
    for c=Ccentres
      d=a+b+c;
      W=[W;code(a,Ainputs,5,0,1),code(b,Binputs,5,0,1),code(c,Cinputs,5,0,1),code(d,Dinputs,5,0,1)];
    end
  end
end
W=W./4;
[n,m]=size(W);
n

%define test cases
stdx=10;
X=zeros(m,4);
null=zeros(1,length(Dinputs));
%function approximation:
X(:,1)=[code(-30,Ainputs,stdx),code(20,Binputs,stdx),code(20,Cinputs,stdx),null]'; %-30+20+20=?
X(:,2)=[code(-30,Ainputs,stdx),zeros(1,length(Binputs)),code(20,Cinputs,stdx),code(10,Dinputs,stdx)]'; %-30+?+20=10?
X(:,3)=[code(30,Ainputs,stdx)+code(-30,Ainputs,stdx),code(20,Binputs,stdx),code(20,Cinputs,stdx),null]'; %(30 &-30)+20+20=?
X(:,4)=[code(-30,Ainputs,stdx),zeros(1,length(Binputs)),code(20,Cinputs,stdx),null]'; %-30+20+20=?
%feature integration:
X(:,5)=[code(-30,Ainputs,stdx),code(20,Binputs,stdx),code(20,Cinputs,stdx),code(0,Dinputs,stdx)]'; %-30+20+20=0!
X(:,6)=[code(-30,Ainputs,stdx),code(20,Binputs,stdx),code(20,Cinputs,stdx),code(0,Dinputs,stdx*2,0,0,stdx)]'; %-30+20+20=0!
expon=[1,1,1,1,2,2];

for k=1:size(X,2)
  x=X(:,k);
  [y,e,r]=dim_activation(W,x);
  figure(k),clf
  plot_result4(x,r,y,expon(k),Ainputs,Binputs,Cinputs,Dinputs);
  print(gcf, '-dpdf', ['probability_4basis',int2str(k),'.pdf']);
end


%test performance over many trials
trials=1e5
range=25;
%test accuracy of calculating d=a+b+c using noisy population codes
disp('test d=a+b+c');
compare_means=zeros(trials,3);
compare_vars=zeros(trials,3);
for k=1:trials
  a=(2*range)*rand-range;
  b=(2*range)*rand-range;
  c=(2*range)*rand-range;
  astd=10+10*rand; 
  bstd=10+10*rand; 
  cstd=10+10*rand; 
  x=[code(a,Ainputs,astd,1,0,stdx),code(b,Binputs,bstd,1,0,stdx),code(c,Cinputs,cstd,1,0,stdx),null]'; %noisy input PPCs
  [amu,avar]=decode(x(1:length(Ainputs))',Ainputs);
  [bmu,bvar]=decode(x(length(Ainputs)+[1:length(Binputs)])',Binputs);
  [cmu,cvar]=decode(x(length(Ainputs)+length(Binputs)+[1:length(Cinputs)])',Cinputs);

  [y,e,r]=dim_activation(W,x);
  [estmu,estvar]=decode(r(1+length(Ainputs)+length(Binputs)+length(Cinputs):end)',Dinputs);

  compare_means(k,:)=[a+b+c,amu+bmu+cmu,estmu];
  compare_vars(k,:)=[astd^2+bstd^2+cstd^2,avar+bvar+cvar,estvar];
end
toplot=1:100;
figure(size(X,2)+1),clf
plot(compare_means(toplot,2),compare_means(toplot,3),'o','MarkerFaceColor','b','MarkerSize',6);
hold on
plot([-80,80],[-80,80],'k--','LineWidth',2)
set(gca,'YTick',[-70:70:70],'XTick',[-70:70:70],'FontSize',15)
axis('equal','tight')
xlabel({'Optimal Estimate of Mean  ';'  '});
ylabel('Network Estimate of Mean  ')
set(gcf,'PaperSize',[10 8],'PaperPosition',[0 0.25 10 7.5],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_4basis_mean_accuracy.pdf']);

figure(size(X,2)+2),clf
plot(compare_vars(toplot,2),compare_vars(toplot,3),'o','MarkerFaceColor','b','MarkerSize',6);
hold on
plot([100,1200],[100,1200],'k--','LineWidth',2)
set(gca,'YTick',[200:400:1000],'YTickLabel',' ','XTick',[200:400:1000],'FontSize',15)
text([100,100,100]-10,[200:400:1000],int2str([200:400:1000]'),'Rotation',90,'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize',15)
axis('equal','tight')
xlabel({'Optimal Estimate of \sigma^2  ';'  '});
ylabel({'Network Estimate of \sigma^2  ';'  '});
set(gcf,'PaperSize',[10 8],'PaperPosition',[0 0 10 8],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_4basis_var_accuracy.pdf']);

error=abs(compare_means(:,2)-compare_means(:,3));
disp('Comparing Means (difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);

error=100.*abs(compare_vars(:,2)-compare_vars(:,3))./compare_vars(:,2);
disp('Comparing Variances (% difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);


%test accuracy of calculating b=d-c-a using noisy population codes
disp('test b=d-c-a');
compare_means=zeros(trials,3);
compare_vars=zeros(trials,3);
for k=1:trials
  a=(2*range)*rand-range;
  b=(2*range)*rand-range;
  c=(2*range)*rand-range;
  d=a+b+c;
  astd=10+5*rand; 
  cstd=10+5*rand; 
  dstd=10+5*rand; 
  x=[code(a,Ainputs,astd,1,0,stdx),zeros(1,length(Binputs)),code(c,Cinputs,cstd,1,0,stdx),code(d,Dinputs,dstd,1,0,stdx)]'; %noisy input PPCs
  [amu,avar]=decode(x(1:length(Ainputs))',Ainputs);
  [cmu,cvar]=decode(x(length(Ainputs)+length(Binputs)+[1:length(Cinputs)])',Cinputs);
  [dmu,dvar]=decode(x(1+length(Ainputs)+length(Binputs)+length(Cinputs):end)',Dinputs);

  [y,e,r]=dim_activation(W,x);
  [estmu,estvar]=decode(r(length(Ainputs)+[1:length(Binputs)])',Binputs);
 
  compare_means(k,:)=[d-c-a,dmu-cmu-amu,estmu];
  compare_vars(k,:)=[dstd^2+cstd^2+astd^2,dvar+cvar+avar,estvar];
end
figure(size(X,2)+3),clf
plot(compare_means(toplot,2),compare_means(toplot,3),'o','MarkerFaceColor','b','MarkerSize',6);
hold on
plot([-30,30],[-30,30],'k--','LineWidth',2)
set(gca,'YTick',[-25:25:25],'XTick',[-25:25:25],'FontSize',15)
axis('equal','tight')
xlabel({'Optimal Estimate of Mean  ';'  '});
ylabel('Network Estimate of Mean  ')
set(gcf,'PaperSize',[10 8],'PaperPosition',[0 0.25 10 7.5],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_4basis_mean_accuracyB.pdf']);

figure(size(X,2)+4),clf
plot(compare_vars(toplot,2),compare_vars(toplot,3),'o','MarkerFaceColor','b','MarkerSize',6);
hold on
plot([100,700],[100,700],'k--','LineWidth',2)
set(gca,'YTick',[200:200:600],'YTickLabel',' ','XTick',[200:200:600],'FontSize',15)
text([100,100,100]-10,[200:200:600],int2str([200:200:600]'),'Rotation',90,'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize',15)
axis('equal','tight')
xlabel({'Optimal Estimate of \sigma^2  ';'  '});
ylabel({'Network Estimate of \sigma^2  ';'  '});
set(gcf,'PaperSize',[10 8],'PaperPosition',[0 0 10 8],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_4basis_var_accuracyB.pdf']);


error=abs(compare_means(:,2)-compare_means(:,3));
disp('Comparing Means (difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);

error=100.*abs(compare_vars(:,2)-compare_vars(:,3))./compare_vars(:,2);
disp('Comparing Variances (% difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);
