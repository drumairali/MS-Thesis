function pcbc_prob_image_orientation_prior()
%Perform inference with a prior when one cue is an image processed by the PC/BC-DIM model of V1
iterations=50;
imageSigmaEquiv=11.2; %as measured by pcbc_prob_image_orientation_estvar
imSize=39;
angles=[0:5:179];
priorMean=90;
priorStd=15 %30;
priorDist=code(priorMean,angles,priorStd,0,0,0,1);

%define weights
[W,V]=define_weights_gabors_matrix(imSize,angles,priorDist);

%define test cases
surr=3;
imageOri=37;
I{1}=image_circular_grating(imSize-2*surr,surr,4,imageOri,0,1);
X{1}=zeros(length(angles),1);
mu3_fig1=stats_gaussian_combination([imageOri,priorMean],[imageSigmaEquiv.^2,priorStd.^2])

imageOri=121.5;
I{2}=image_circular_grating(imSize-2*surr,surr,4,imageOri,0,1);
X{2}=zeros(length(angles),1);
mu3_fig2=stats_gaussian_combination([imageOri,priorMean],[imageSigmaEquiv.^2,priorStd.^2])


%present test cases to network and record results
for k=1:length(I)
  Ion=I{k}(:); Ion(Ion<0)=0;
  Ioff=-I{k}(:); Ioff(Ioff<0)=0;
  x=[Ion;Ioff;X{k}]; 
  [y,e,r]=dim_activation(W,x,V,iterations);

  figure(k),clf
  plot_result_images(x,r,y,1,imSize,angles,W);
  print(gcf, '-dpdf', ['probability_images_orientation_prior',int2str(k),'.pdf']);
end


%test accuracy across many random trials
numTests=100
compare_means=zeros(numTests,2);
compare_vars=zeros(numTests,2);
for k=1:numTests
  fprintf(1,'.%i.',k); 
  
  %randomly select parameters of input
  mu1=priorMean+(120*rand-60);
  sigma1=imageSigmaEquiv;

  %calc bayesian estimate of posterior
  [mu3act,var3act]=stats_gaussian_combination([mu1,priorMean],[sigma1^2,priorStd^2]);    

  %calc network estimate of posterior
  Itmp=image_circular_grating(imSize-2*surr,surr,4,mu1,0,1);
 
  Ion=Itmp(:); Ion(Ion<0)=0;
  Ioff=-Itmp(:); Ioff(Ioff<0)=0;
  x=[Ion;Ioff;X{1}]; 
  
  [y,e,r]=dim_activation(W,x,V,iterations);
  [mu3est,var3est]=decode(r(1+2*imSize.^2:end)',angles,1,1);

  %store estimates for plotting later
  compare_means(k,:)=[mu3act,mu3est];
  compare_vars(k,:)=[var3act,var3est];
end
disp(' ')

figure(length(I)+1),clf
plot(compare_means(:,1),compare_means(:,2),'o','MarkerFaceColor','b','MarkerSize',6);
hold on
plot([10,170],[10,170],'k--','LineWidth',2)
set(gca,'YTick',[0:45:179],'XTick',[0:45:179],'FontSize',15)
axis('equal','tight')
xlabel('Optimal Estimate of Mean  ');
ylabel('Network Estimate of Mean  ')
set(gcf,'PaperSize',[10 8],'PaperPosition',[0 0.25 10 7.5],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_images_orientation_prior_mean_accuracy.pdf']);

figure(length(I)+2),clf
plot(compare_vars(:,1),compare_vars(:,2),'o','MarkerFaceColor','b','MarkerSize',6);
hold on
plot([25,150],[25,150],'k--','LineWidth',2)
set(gca,'YTick',[50:50:150],'YTickLabel',' ','XTick',[50:50:150],'FontSize',15)
text([25,25,25]-1,[50:50:150],int2str([50:50:150]'),'Rotation',90,'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize',15)
axis('equal','tight')
xlabel({'Optimal Estimate of \sigma^2  ';'  '});
ylabel({'Network Estimate of \sigma^2  ';'  '});
set(gcf,'PaperSize',[10 8],'PaperPosition',[0 0.25 10 7.5],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_images_orientation_prior_var_accuracy.pdf']);


error=abs(compare_means(:,1)-compare_means(:,2));
disp('Comparing Means (difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);

error=100.*abs(compare_vars(:,1)-compare_vars(:,2))./compare_vars(:,1);
disp('Comparing Variances (% difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);
