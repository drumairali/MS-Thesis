range=[1:50:6301];
centers=[1:100:6301];
W=[];
[ext,wn]=size(centers);
for iw=1:wn
  WG1D = G1D(range,centers(iw),50,1);
  W=[W;WG1D];
endfor
[n,m]=size(W)
y=zeros(n,1)
V=bsxfun(@rdivide,abs(W),max(1e-6,max(abs(W),[],2)));
V=V';
epsilon1=1e-6;
epsilon2=1e-4;


for xi = 1:6301
  xi
x=(G1D(range,globalTraj(xi,2),50,1))';
#PCBC-DIM
for i=1:30
r=V*y;
e=x./(epsilon2+r);
y=(epsilon1+y).*(W*e);
endfor
#Decoding
comingVal(1,xi) = decode(r',[range]);
end
plot(comingVal)