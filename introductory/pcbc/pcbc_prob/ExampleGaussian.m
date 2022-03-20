##############################################################
%Example
### making weights
input = [-50:5:50];
centers = [-50: 10: 50]
sigma = 10;
W = [];
for c = centers
  ZW=zeros(1,length(input));

 % a constant
% to make weights firt i made gaussians
ZW = exp(-(0.5/sigma.^2).*((c-input).^2));


%spacing controls length 
  spacing=mean(diff(input)); % 5 in this case

  ZW=spacing.*ZW./(sigma*sqrt(2*pi));

stdnorm =10;
  ZW=stdnorm.*ZW/sigma;

  W = [W;ZW]
end


### till here it was the portion of weights

###########################################################3

### inputs X should be of same nature so 

X = zeros(length(input),1);

%any input say mean = 10 
X = exp(-(0.5/sigma.^2).*((20-input).^2))
X=X'


%input X is ready now it is time to process weights and input through PC/BC-DIM
#######################################################




################### pc/bc-dim filter #####################


% V is normalized transpose of W which plays very important role
  V=bsxfun(@rdivide,abs(W),max(1e-6,max(abs(W),[],2)));
figure(1)
  V=V'; % transpose is taken to multiply with respective matrix 
% first making V
subplot(2,1,1)
plot(W)

title('Weights are made by gaussians')
subplot(2,1,2)
plot(V)
title('V is Transpose of W')
x=X;
[n,m] = size(W);

[inchanel,blength]= size(x)
 y=zeros(n,blength);


epsilon1=1e-6;
epsilon2=1e-4;

for i = 1:25
  
  %update responses
  r=V*y;
  %e=x./max(epsilon2,r);
  e = x./(epsilon2+r);
  %y=max(epsilon1,y).*(W*e);
  y=(epsilon1+y).*(W*e);

  
  end

figure(2)
subplot(3,1,1)
plot(x)
title('input x')

figure(2)
subplot(3,1,2)
plot(y)
title('prediction y')


figure(2)
subplot(3,1,3)
plot(r)
title('reconstruction r')


