function pcbc_prob_1gaussian_width_height()
%Test encoding and decoding of simple gaussian probability distributions, by repeating the experiments performed in Zemel, Dayan and Pouget, Neural Comput. 1998.
inputs=[-10:0.04:10-0.04]; %500 histogram bins (as for each model in Zemel etal 1998)
centres=[-10:0.4:10-0.4]; %50 neurons (as for each model in Zemel etal 1998)

%define weights, to produce a 1d basis function network, where nodes have gaussian RFs.

%wide tuning
W{1}=[];
for c=centres
  W{1}=[W{1};code(c,inputs,0.3,0,1)]; %sigma=0.3 (as for KDE model in Zemel etal 1998)
end
%narrow tuning
centres_fine=[-10:0.08:10-0.08];
W{2}=[];
for c=centres_fine
  W{2}=[W{2};code(c,inputs,0.08,0,1)]; 
end
%mixed tuning
%W{3}=[W{1};W{2}.*0.9];

%define test cases
X=zeros(length(inputs),2);
noise=0;
sigma=1;
X(:,1)=code(0,inputs,sigma,noise)'.*0.4/sigma;
X(:,3)=0.5.*(code(-2,inputs,sigma,noise)+code(2,inputs,sigma,noise))'.*0.4/sigma;
sigma=0.2;
X(:,2)=code(0,inputs,sigma,noise)'.*0.4/sigma;
X(:,4)=0.5.*(code(-2,inputs,sigma,noise)+code(2,inputs,sigma,noise))'.*0.4/sigma;
label=[0,0,0,0];

for k=1:length(W)
  test_weights(W{k},X,inputs,centres,label,(k-1)*10,k);
end
  


function test_weights(W,X,inputs,centres,label,figoff,weightType);
for k=1:size(X,2)
  x=X(:,k);
  [y,e,r]=dim_activation(W,x);
  figure(figoff+k),clf
  plot_result(x(101:401),r(101:401),y,inputs(101:401),centres,label(k));
  print(gcf, '-dpdf', ['probability_1gaussian_width_height',int2str(weightType),'-',int2str(k),'.pdf']);
end


%test effect of contrast
k=0;
constrasts=0.1:0.1:1;
sigma=1; %sigma=1 (as for KDE model in Zemel etal 1998)
for c=constrasts
  k=k+1;
  x=c.*code(0,inputs,sigma)'.*0.4/sigma;
  [y,e,r]=dim_activation(W,x);
  
  error(k)=sum((x-r).^2);
end
figure(figoff+size(X,2)+1),clf
plot(constrasts,error,'b-+','LineWidth',3,'MarkerSize',10)
ax=axis;
axis([0.1,1,0,ax(4)])
set(gca,'XTick',[0.1,0.5,1],'FontSize',15);
xlabel('Amplitude');
ylabel('Reconstruction Error')
set(gcf,'PaperSize',[8 8],'PaperPosition',[0 0.25 8 7.5],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_1gaussian_width_height',int2str(weightType),'_accuracy_contrast.pdf']);

%test effect of noise
trials=50;
sigmas=0.1:0.1:1;
k=0;
for sigma=sigmas
  k=k+1;
  sumError=0;
  for t=1:trials
    xtrue=code(0,inputs,sigma)'.*0.4/sigma; 
    x=code(0,inputs,sigma,1)'.*0.4/sigma; 
    [y,e,r]=dim_activation(W,x);
    
    sumError=sumError+sum((xtrue-r).^2);
  end
  error(k)=sumError./trials;
end
figure(figoff+size(X,2)+2),clf
plot(sigmas,error,'b-+','LineWidth',3,'MarkerSize',10)
ax=axis;
axis([0.1,1,0,ax(4)])
set(gca,'XTick',[0.1,0.5,1],'FontSize',15);
xlabel('Width (\sigma)');
ylabel('Reconstruction Error')
set(gcf,'PaperSize',[8 8],'PaperPosition',[0 0.25 8 7.5],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_1gaussian_width_height',int2str(weightType),'_accuracy_width.pdf']);


  
function plot_result(x,r,y,inputs,centres,label)
if nargin<6, label=1; end
tolabel=[51:50:length(x)-1];

top=max(1.05.*x);
axes('Position',[0.12,0.06,0.76,0.24]),
bar(x,1,'k'),axis([0.5,length(x)+0.5,0,top])
set(gca,'XTick',tolabel,'XTickLabel',inputs(tolabel),'FontSize',12);
if label, plot_decode(x,inputs); end
text(0.01,1,'x','Units','normalized','color','k','FontSize',14,'FontWeight','bold','VerticalAlignment','top')

top=max(1.05.*r);
axes('Position',[0.12,0.73,0.76,0.24]),
bar(r,1,'FaceColor',[0,0.7,0]),axis([0.5,length(x)+0.5,0,top])
set(gca,'XTick',tolabel,'XTickLabel',inputs(tolabel),'FontSize',12);
if label, plot_decode(r,inputs); end
text(0.01,1,'r','Units','normalized','color',[0,0.7,0],'FontSize',14,'FontWeight','bold','VerticalAlignment','top')

if length(y)<100,toplot=[10:10:length(y)-5]; else, toplot=[50:50:length(y)-25]; end
top=max(1.05.*y);
axes('Position',[0.12,0.4,0.76,0.24]),
bar(y,1,'r'),axis([0.5,length(y)+0.5,0,top])
set(gca,'XTick',toplot,'FontSize',12);
text(0.01,1,'y','Units','normalized','color','r','FontSize',14,'FontWeight','bold','VerticalAlignment','top')


set(gcf,'PaperSize',[10 8],'PaperPosition',[0 0.5 10 7.5],'PaperOrientation','Portrait');


  