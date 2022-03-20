function pcbc_prob_2integrate_segregate()
%Perform optimal feature integration given two Gaussian probability distributions. Gradually change the degree of cue conflict to test when integration chnages to segregation.
stdInputs=20; %30

stdWeights=15;
inputs=[-180:10:180];
centres=[-180:15:180];
%define weights, to produce a 2d basis function network, where nodes have gaussian RFs.
W=[];
for c=centres
  W=[W;code(c,inputs,stdWeights,0,1),code(c,inputs,stdWeights,0,1)];
end
W=W./2;
[n,m]=size(W);

%define test cases
stdx=20;
X=zeros(m,5);
k=0;
for m2=-10:20:70
  k=k+1;
  X(:,k)=[code(-20,inputs,stdInputs,0,0,stdx),code(m2,inputs,stdInputs,0,0,stdx)]'; 
end

%present test cases to network and record results
figure(size(X,2)+1),clf %figure for summary results
for k=1:size(X,2)
  x=X(:,k);
  [y,e,r]=dim_activation(W,x);
  
  figure(size(X,2)+1),axes('Position',[0.16*k-0.04,0.15,0.145,0.7]),
  rA=r(1:length(inputs));
  bar(rA.^2,1,'FaceColor',[0,0.7,0]),axis([0.5,length(rA)+0.5,0,0.9])
  if k>1, set(gca,'YTick',[]); end
  set(gca,'XTick',[10:9:length(rA)-1],'XTickLabel',inputs(10:9:length(rA)-1),'FontSize',9);
  text(0.02,0.94,'r_a^2','Units','normalized','color',[0,0.7,0],'FontSize',9,'FontWeight','bold','VerticalAlignment','top')
  hold on, plot(x(1:length(inputs))'.*x(1+length(inputs):end)','LineWidth',2);
  figure(k),clf
  plot_result2(x,r,y,2,inputs,centres);
end
figure(size(X,2)+1)
set(gcf,'PaperSize',[20 3],'PaperPosition',[0 0.25 20 3],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_2integrate_segregate_summary.pdf']);

