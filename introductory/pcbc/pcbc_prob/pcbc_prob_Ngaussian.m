function pcbc_prob_Ngaussian()
%Test encoding and decoding of simple, multimodal, gaussian probability distributions
inputs=[-180:5:180];
centres=[-180:10:180];

%define weights, to produce a 1d basis function network, where nodes have gaussian RFs.
W=[];
for c=centres
  W=[W;code(c,inputs,10,0,1)];
end
[n,m]=size(W);

%define test cases
X=zeros(m,2);
X(:,1)=code(-10,inputs,20,1,0,15)'+code(103,inputs,25,1,0,15)'+code(-94,inputs,15,1,0,15)'; %tri-modal, noisy
%X(:,2)=code(-10,inputs,20,0,0,15)'+code(103,inputs,25,0,0,15)'+code(-94,inputs,15,0,0,15)'; %tri-modal, no noise

for k=1:size(X,2)
  x=X(:,k);
  [y,e,r]=dim_activation(W,x);
  figure(k),clf
  plot_result1(x,r,y,inputs,centres,0,1.2);
  print(gcf, '-dpdf', ['probability_Ngaussian',int2str(k),'.pdf']);
end
