function [r,y]= getRecons(x,W,V)
epsilon1=1e-9;
epsilon2=1e-9;
y=zeros(size(W,1),1);
iter=25; 
for i=1:iter
r=V*y;
e=x./(epsilon2+r);
y=(epsilon1+y).*(W*e);
end
end
