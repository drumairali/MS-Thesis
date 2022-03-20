function [y,e,r,ytrace,rtrace]=dim_activation(W,x,V,iterations,y)
epsilon1=1e-6;
epsilon2=1e-4;
if nargin<4 || isempty(iterations), iterations=25; end

[n,m]=size(W);
[nInputChannels,batchLen]=size(x)
if nargin<5 || isempty(y)
  y=zeros(n,batchLen,'single'); %initialise prediction neuron outputs
end
%set feedback weights equal to feedforward weights normalized by maximum value 
if nargin<3 || isempty(V)
  V=bsxfun(@rdivide,abs(W),max(1e-6,max(abs(W),[],2))); % largest row from column
  % is dividing with each 
end
V=V'; %avoid having to take transpose at each iteration

for t=1:iterations  
  %x=single(imnoise(uint8(125.*x),'poisson'))./125; 
  %y=single(imnoise(uint8(125.*y),'poisson'))./125; 
  
  %update responses
  r=V*y;
  %e=x./max(epsilon2,r);
  e=x./(epsilon2+r)
  %y=max(epsilon1,y).*(W*e);
  y=(epsilon1+y).*(W*e);

  if nargout>3, ytrace(:,t)=y end
  if nargout>4, rtrace(:,t)=r end
end	

