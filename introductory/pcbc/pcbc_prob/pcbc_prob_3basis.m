function pcbc_prob_3basis()
%calculate fn(a,b), where a and b are real numbers (in a limited range) and fn is +
Ainputs=[-90:5:90];
Binputs=[-90:5:90];
Cinputs=[min(Ainputs)+min(Binputs):10:max(Ainputs)+max(Binputs)];
Acentres=[-90:5:90];
Bcentres=[-90:5:90];

%define weights, to produce a 2d basis function network, where nodes have gaussian RFs.
W=[];
for a=Acentres
  for b=Bcentres
    c=a+b;
    W=[W;code(a,Ainputs,5,0,1),code(b,Binputs,5,0,1),code(c,Cinputs,5,0,1)];
  end
end
W=W./3;
[n,m]=size(W);
n

%define test cases
stdx=10;
X=zeros(m,4);
null=zeros(1,length(Cinputs));
%function approximation:
X(:,1)=[code(-30,Ainputs,stdx),code(20,Binputs,stdx),null]'; %-30+20=?
X(:,2)=[code(-30,Ainputs,stdx),zeros(1,length(Binputs)),code(-10,Cinputs,stdx)]'; %-30+?=-10?
%feature integration:
X(:,3)=[code(-30,Ainputs,stdx),code(20,Binputs,stdx),code(10,Cinputs,stdx)]'; %-30+20=10!
X(:,4)=[code(-30,Ainputs,stdx),code(20,Binputs,stdx),code(10,Cinputs,stdx*2,0,0,stdx)]'; %-30+20=10!
expon=[1,1,2,2];

%present test cases to network and record results
for k=1:size(X,2)
  x=X(:,k);
  [y,e,r]=dim_activation(W,x);
  figure(k),clf
  plot_result3(x,r,y,expon(k),Ainputs,Binputs,Cinputs);
  print(gcf, '-dpdf', ['probability_3basis',int2str(k),'.pdf']);
end


%test for gain modulation
x=[code(-30,Ainputs,10,0,0,stdx),code(-30,Binputs,10,0,0,stdx),null]';
[y,e,r]=dim_activation(W,x);
[val,ind]=max(y);%choose node to record from
atestvals=[-60:1:30];
btestvals=[-30:7.5:0];
k=0;
for b=btestvals
  k=k+1;
  p=0;
  for a=atestvals
    p=p+1;
    x=[code(a,Ainputs,10,0,0,stdx),code(b,Binputs,10,0,0,stdx),null]';
    [y,e,r,ytrace]=dim_activation(W,x);
    resp(k,p)=mean(ytrace(ind,:));
  end
end
figure(size(X,2)+1),clf
plot(resp','LineWidth',3)
legend([num2str(btestvals', 'B=% 2.1f'),[' .';'  ';'  ';'  ';'  ']],'Location','NorthOutside');
axis([1,length(atestvals),0,0.1])
tolabel=[1:30:141];
set(gca,'XTick',tolabel,'XTickLabel',[-60:30:60],'FontSize',15);
xlabel('A');ylabel('response')
set(gcf,'PaperSize',[8 12],'PaperPosition',[0 0.25 8 11.5],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_3basis_gainmod.pdf']);



%test performance over many trials
trials=1e5
range=40;
%test accuracy of calculating c=a+b using noisy population codes
disp('test c=a+b');
compare_means=zeros(trials,3);
compare_vars=zeros(trials,3);
for k=1:trials
  a=(2*range)*rand-range;
  b=(2*range)*rand-range;
  astd=10+10*rand; 
  bstd=10+10*rand; 
  x=[code(a,Ainputs,astd,1,0,stdx),code(b,Binputs,bstd,1,0,stdx),null]'; %noisy input PPCs
  [amu,avar]=decode(x(1:length(Ainputs))',Ainputs);
  [bmu,bvar]=decode(x(length(Ainputs)+[1:length(Binputs)])',Binputs);
  
  [y,e,r]=dim_activation(W,x);
  [estmu,estvar]=decode(r(1+length(Ainputs)+length(Binputs):end)',Cinputs);
  
  compare_means(k,:)=[a+b,amu+bmu,estmu];
  compare_vars(k,:)=[astd^2+bstd^2,avar+bvar,estvar];
end
toplot=1:100;
figure(size(X,2)+2),clf
plot(compare_means(toplot,2),compare_means(toplot,3),'o','MarkerFaceColor','b','MarkerSize',6);
hold on
plot([-90,90],[-90,90],'k--','LineWidth',2)
set(gca,'YTick',[-80:80:80],'XTick',[-80:80:80],'FontSize',15)
axis('equal','tight')
xlabel({'Optimal Estimate of Mean  ';'  '});
ylabel('Network Estimate of Mean  ')
set(gcf,'PaperSize',[10 8],'PaperPosition',[0 0.25 10 7.5],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_3basis_mean_accuracy.pdf']);

figure(size(X,2)+3),clf
plot(compare_vars(toplot,2),compare_vars(toplot,3),'o','MarkerFaceColor','b','MarkerSize',6);
hold on
plot([100,900],[100,900],'k--','LineWidth',2)
set(gca,'YTick',[200:300:800],'YTickLabel',' ','XTick',[200:300:800],'FontSize',15)
text([100,100,100]-10,[200:300:800],int2str([200:300:800]'),'Rotation',90,'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize',15)
axis('equal','tight')
xlabel({'Optimal Estimate of \sigma^2  ';'  '});
ylabel({'Network Estimate of \sigma^2  ';'  '});
set(gcf,'PaperSize',[10 8],'PaperPosition',[0 0 10 8],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_3basis_var_accuracy.pdf']);

error=abs(compare_means(:,2)-compare_means(:,3));
disp('Comparing Means (difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);

error=100.*abs(compare_vars(:,2)-compare_vars(:,3))./compare_vars(:,2);
disp('Comparing Variances (% difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);



%test accuracy of calculating b=c-a using noisy population codes
disp('test b=c-a');
compare_means=zeros(trials,3);
compare_vars=zeros(trials,3);
for k=1:trials
  a=(2*range)*rand-range;
  b=(2*range)*rand-range;
  c=a+b;
  astd=10+10*rand; 
  cstd=10+10*rand; 
  x=[code(a,Ainputs,astd,1,0,stdx),zeros(1,length(Binputs)),code(c,Cinputs,cstd,1,0,stdx)]'; %noisy input PPCs
  [amu,avar]=decode(x(1:length(Ainputs))',Ainputs);
  [cmu,cvar]=decode(x(1+length(Ainputs)+length(Binputs):end)',Cinputs);

  [y,e,r]=dim_activation(W,x);
  [estmu,estvar]=decode(r(length(Ainputs)+[1:length(Binputs)])',Binputs);
  
  compare_means(k,:)=[c-a,cmu-amu,estmu];
  compare_vars(k,:)=[cstd^2+astd^2,cvar+avar,estvar];
end

figure(size(X,2)+4),clf
plot(compare_means(toplot,2),compare_means(toplot,3),'o','MarkerFaceColor','b','MarkerSize',6);
hold on
plot([-50,50],[-50,50],'k--','LineWidth',2)
set(gca,'YTick',[-90:45:90],'XTick',[-90:45:90],'FontSize',15)
axis('equal','tight')
xlabel({'Optimal Estimate of Mean  ';'  '});
ylabel('Network Estimate of Mean  ')
set(gcf,'PaperSize',[10 8],'PaperPosition',[0 0.25 10 7.5],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_3basis_mean_accuracyB.pdf']);

figure(size(X,2)+5),clf
plot(compare_vars(toplot,2),compare_vars(toplot,3),'o','MarkerFaceColor','b','MarkerSize',6);
hold on
plot([100,900],[100,900],'k--','LineWidth',2)
set(gca,'YTick',[200:300:800],'YTickLabel',' ','XTick',[200:300:800],'FontSize',15)
text([100,100,100]-10,[200:300:800],int2str([200:300:800]'),'Rotation',90,'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize',15)
axis('equal','tight')
xlabel({'Optimal Estimate of \sigma^2  ';'  '});
ylabel({'Network Estimate of \sigma^2  ';'  '});
set(gcf,'PaperSize',[10 8],'PaperPosition',[0 0 10 8],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_3basis_var_accuracyB.pdf']);

error=abs(compare_means(:,2)-compare_means(:,3));
disp('Comparing Means (difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);

error=100.*abs(compare_vars(:,2)-compare_vars(:,3))./compare_vars(:,2);
disp('Comparing Variances (% difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);



%calculate accuracy of function approximation averaged over many trials (Deneve's method)
%trials=1e5
range=40;
stdx=10;
%test accuracy of calculating c=a+b using noisy population codes
disp('test c=a+b (fixed variance)');
compare_means=zeros(trials,3);
for k=1:trials
  if rem(k,1000)==0; fprintf(1,'.%i.',k); end
  a=(2*range)*rand-range;
  b=(2*range)*rand-range;
  x=[code(a,Ainputs,stdx,1),code(b,Binputs,stdx,1),null]';
  aML=decode(x(1:length(Ainputs))',Ainputs);
  bML=decode(x(length(Ainputs)+[1:length(Binputs)])',Binputs);

  [y,e,r]=dim_activation(W,x);
  rNet=decode(r(1+length(Ainputs)+length(Binputs):end)',Cinputs);
  
  compare_means(k,:)=[a+b,aML+bML,rNet];
end
disp(' ');
varML=est_var(compare_means(:,1)',compare_means(:,2)',Cinputs) %compare function estimated from input pattern to true value
varNet=est_var(compare_means(:,1)',compare_means(:,3)',Cinputs) %compare function estimated from reconstruction to true value
100.*(varNet-varML)./varML

%test accuracy of calculating b=c-a using noisy population codes
disp('test b=c-a (fixed variance)');
compare_means=zeros(trials,3);
for k=1:trials
  if rem(k,1000)==0; fprintf(1,'.%i.',k); end
  a=(2*range)*rand-range;
  b=(2*range)*rand-range;
  c=a+b;
  x=[code(a,Ainputs,stdx,1),zeros(1,length(Binputs)),code(c,Cinputs,stdx,1)]';
  aML=decode(x(1:length(Ainputs))',Ainputs);
  cML=decode(x(1+length(Ainputs)+length(Binputs):end)',Cinputs);

  [y,e,r]=dim_activation(W,x);
  rNet=decode(r(length(Ainputs)+[1:length(Binputs)])',Binputs);
  
  compare_means(k,:)=[c-a,cML-aML,rNet];
end
disp(' ');
varML=est_var(compare_means(:,1)',compare_means(:,2)',Binputs) %compare function estimated from input pattern to true value
varNet=est_var(compare_means(:,1)',compare_means(:,3)',Binputs) %compare function estimated from reconstruction to true value
100.*(varNet-varML)./varML




function var=est_var(true,est,s)
M=length(true);
if s(1)==0 %assume that input space wraps around every 180 degrees
  var=sum(min([abs(est-true);abs(est-(true+180));abs(est-(true-180))]).^2)/(M-1);
elseif 0 && s(1)==-180 %assume that input space wraps around every 360 degrees
  var=sum(min([abs(est-true);abs(est-(true+360));abs(est-(true-360))]).^2)/(M-1);
else
  var=sum((est-true).^2)/(M-1);
end 
