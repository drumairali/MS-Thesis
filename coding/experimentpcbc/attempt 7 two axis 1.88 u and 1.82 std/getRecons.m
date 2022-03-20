function [r,y]= getRecons(x,W,V,y,xyLoop)
epsilon1=1e-6;
epsilon2=1e-4;

iter=15; 
for i=1:iter
r=V*y;
e=x(:,xyLoop)./(epsilon2+r);
y=(epsilon1+y).*(W*e);
end
end
