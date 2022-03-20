function [y,e,r,ytrace]=linear_pc_activation(W,x,y,iterations)
vartheta=0;
zeta=0.1;

for t=1:iterations
  r=W'*y;
	e=x-r;
	y=((1-vartheta)*y)+zeta.*(W*e);
	y(y<0)=0;
  
  if nargout>3, ytrace(:,t)=y; end
end
