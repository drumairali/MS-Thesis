clear
clc
%perform optimal feature integration given three Gaussian probability distributions
inputs=[-180:10:180];
centres=[-180:15:180];

%define weights, to produce a 2d basis function network, where nodes have gaussian RFs.
W=[];
for c=centres
  W=[W;code(c,inputs,15,0,1),code(c,inputs,15,0,1)];
end
W=W./3;
[n,m]=size(W);
figure(7)
plot(W)
%define test cases
stdx=20;
X=zeros(m,4);
X(:,1)=[code(-20,inputs,20,0,0,stdx),code(-25,inputs,20,0,0,stdx)]'; 

%present test cases to network and record results

  x=X;
  [y,e,r]=dim_activation(W,x);
 decode(r(1:37),inputs)