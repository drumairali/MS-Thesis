clear
clc
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
inp1=-80
inp2=2
X(:,1)=[code(-80,Ainputs,stdx),code(2,Binputs,stdx),null]'; %-30+20=?
#X(:,2)=[code(-30,Ainputs,stdx),zeros(1,length(Binputs)),code(-10,Cinputs,stdx)]'; %-30+?=-10?
%feature integration:
#X(:,3)=[code(-30,Ainputs,stdx),code(20,Binputs,stdx),code(10,Cinputs,stdx)]'; %-30+20=10!
#X(:,4)=[code(-30,Ainputs,stdx),code(20,Binputs,stdx),code(10,Cinputs,stdx*2,0,0,stdx)]'; %-30+20=10!
expon=[1,1,2,2];

%present test cases to network and record results
for k=1:1
  x=X(:,k);
  [y,e,r]=dim_activation(W,x);
 # figure(k),clf
 # plot_result3(x,r,y,expon(k),Ainputs,Binputs,Cinputs);
 # print(gcf, '-dpdf', ['probability_3basis',int2str(k),'.pdf']);
end
decode(r(75:end)',Cinputs)
decode(r(1:37)',Ainputs)
decode(r(38:74)',Binputs)