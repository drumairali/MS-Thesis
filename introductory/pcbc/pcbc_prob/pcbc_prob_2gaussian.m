function pcbc_prob_2gaussian()
%Test encoding and decoding of simple gaussian probability distributions, by repeating the experiments performed in Zemel and Dayan, NIPS, 1998
inputs=[-180:0.1:180];
centres=[-180:2:180-1];

%define weights to produce a 1d basis function network where nodes have gaussian RFs.
W=[];
for c=centres
  W=[W;code(c,inputs,10,0,1)];
end
[n,m]=size(W);

%define test cases
X=zeros(length(inputs),1);
noise=0;
sigma=5;
X(:,1)=0.5.*(code(-60,inputs,sigma,noise)+code(60,inputs,sigma,noise))'./sigma;
X(:,2)=0.5.*(code(-15,inputs,sigma,noise)+code(15,inputs,sigma,noise))'./sigma;
plot(X(:,1),inputs)
for k=1:size(X,2)
  x=X(:,k);
  [y,e,r]=dim_activation(W,x);
  figure(k),clf
  plot_result1(x,r,y,inputs,centres,0,0.1);
  print(gcf, '-dpdf', ['probability_2gaussian',int2str(k),'.pdf']);
end

