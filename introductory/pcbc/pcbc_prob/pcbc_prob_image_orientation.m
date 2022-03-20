function pcbc_prob_image_orientation(imagenoise)
%Perform inference when one cue is an image processed by the PC/BC-DIM model of V1
if nargin<1, imagenoise=0; end
iterations=50;
imageSigmaEquiv=11.2; %as measured by pcbc_prob_image_orientation_estvar
imSize=39;
angles=[0:5:179];

%define weights
[W,V]=define_weights_gabors_matrix(imSize,angles,1);

%define test cases
stdx=10;
surr=3;
imageOri=37;
I{1}=image_circular_grating(imSize-2*surr,surr,4,imageOri,0,1);
X{1}=zeros(length(angles),1);

I{2}=imnoise(0.5.*(I{1}+1),'speckle',0.1).*2-1;
X{2}=zeros(length(angles),1);

I{3}=image_circular_cross_orientation(imSize-2*surr,surr,4,4,imageOri,90,0,0,1,1);
X{3}=zeros(length(angles),1);

%feature integration
I{4}=I{1};
cueMean=imageOri+12;
cueStd1=20;
X{4}=code(cueMean,angles,cueStd1,0,0,stdx,1)';
mu3_fig4=stats_gaussian_combination([imageOri,cueMean],[imageSigmaEquiv.^2,cueStd1.^2])

I{5}=I{1};
cueStd2=10;
X{5}=code(cueMean,angles,cueStd2,0,0,stdx,1)';
mu3_fig5=stats_gaussian_combination([imageOri,cueMean],[imageSigmaEquiv.^2,cueStd2.^2])

I{6}=I{1};
cueMean2=imageOri+95;
X{6}=code(cueMean2,angles,cueStd2,0,0,stdx,1)';

I{7}=I{1};
X{7}=X{5}+X{6};


expon=[1,1,1,2,2,2,2];

%present test cases to network and record results
for k=1:length(I)
  Ion=I{k}(:); Ion(Ion<0)=0;
  Ioff=-I{k}(:); Ioff(Ioff<0)=0;
  x=[Ion;Ioff;X{k}]; 
  [y,e,r]=dim_activation(W,x,V,iterations);

  figure(k),clf
  plot_result_images(x,r,y,expon(k),imSize,angles,W);

  print(gcf, '-dpdf', ['probability_images_orientation',int2str(k),'.pdf']);
end

%test accuracy across many random trials
if imagenoise
  imageSigmaEquiv=13.6
end
numTests=100
compare_means=zeros(numTests,2);
compare_vars=zeros(numTests,2);
for k=1:numTests
  fprintf(1,'.%i.',k); 

  %randomly select parameters of input
  mu1=90+(120*rand-60); 
  mu2=mu1+(20*rand-10);
  sigma1=imageSigmaEquiv;
  sigma2=10+10*rand;

  %calc bayesian estimate of combined value
  [mu3act,var3act]=stats_gaussian_combination([mu1,mu2],[sigma1.^2,sigma2.^2]);   

  %calc network estimate of combined value
  Itmp=image_circular_grating(imSize-2*surr,surr,4,mu1,0,1);
  if imagenoise  
    Itmp=imnoise(0.5.*(Itmp+1),'speckle',0.1).*2-1;
  end
  Ion=Itmp(:); Ion(Ion<0)=0;
  Ioff=-Itmp(:); Ioff(Ioff<0)=0;
  Xtmp=code(mu2,angles,sigma2,imagenoise,0,stdx,1)'; %noisy population code
  x=[Ion;Ioff;Xtmp]; 

  [y,e,r]=dim_activation(W,x,V,iterations);
  [mu3est,var3est]=decode(r(1+2*imSize.^2:end)',angles,2,1);
  %ensure estimates aren't 180 apart!
  if mu3est>mu3act+150, mu3est=mu3est-180; end
  if mu3est<mu3act-150, mu3est=mu3est+180; end
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
print(gcf, '-dpdf', ['probability_images_orientation_mean_accuracy.pdf']);

figure(length(I)+2),clf
plot(compare_vars(:,1),compare_vars(:,2),'o','MarkerFaceColor','b','MarkerSize',6);
hold on
plot([30,170],[30,170],'k--','LineWidth',2)
set(gca,'YTick',[50:50:150],'YTickLabel',' ','XTick',[50:50:150],'FontSize',15)
text([30,30,30]-4,[50:50:150],int2str([50:50:150]'),'Rotation',90,'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize',15)
axis('equal','tight')
xlabel({'Optimal Estimate of \sigma^2  '});
ylabel({'Network Estimate of \sigma^2  ';'  '});
set(gcf,'PaperSize',[10 8],'PaperPosition',[0 0.25 10 7.5],'PaperOrientation','Portrait');
print(gcf, '-dpdf', ['probability_images_orientation_var_accuracy.pdf']);


error=abs(compare_means(:,1)-compare_means(:,2));
disp('Comparing Means (difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);

error=100.*abs(compare_vars(:,1)-compare_vars(:,2))./compare_vars(:,1);
disp('Comparing Variances (% difference between network and optimal estimate)')
disp(['  Max=',num2str(max(error)),' Median=',num2str(median(error)),' Mean=',num2str(mean(error))]);
