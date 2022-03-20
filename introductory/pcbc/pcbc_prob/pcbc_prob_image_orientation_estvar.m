function pcbc_prob_image_orientation_estvar()
%Apply PC/BC-DIM model of V1 to an image and plot prediction neuron responses and reconstructions

imSize=39;
angles=[0:5:179];

%define weights
[W,V]=define_weights_gabors_matrix(imSize,angles,1);

%define test cases
surr=3;

imageOri=37;
I{1}=image_circular_grating(imSize-2*surr,surr,4,imageOri,0,1);
X{1}=zeros(length(angles),1);

%present test cases to network and record results
for k=1:20
  I=image_circular_grating(imSize-2*surr,surr,4,180*rand,0,1);
  Ion=I(:); Ion(Ion<0)=0;
  Ioff=-I(:); Ioff(Ioff<0)=0;
  x=[Ion;Ioff;zeros(length(angles),1)]; 
  [y,e,r]=dim_activation(W,x,V,50);

  figure(k),clf
  plot_result_images(x,r,y,1,imSize,angles,W);
  [mu3est(k),var3est(k)]=decode(r(1+2*imSize.^2:end)',angles);
end
mu3est
var3est
imageSigmaEquiv=sqrt(mean(var3est))
