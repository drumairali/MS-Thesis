function [y,e,r,x,ytrace]=dim_activation_hierarchical(W,x,interconnects,y,iterations)
epsilon1=1e-6;
epsilon2=1e-4;%5e-3;
if nargin<5 || isempty(iterations), iterations=50; end
if nargin<4 || isempty(y), initY=1; else, initY=0; end

numStages=length(W);
for s=1:numStages
  [n{s},m{s}]=size(W{s});
  if initY
    y{s}=zeros(n{s},1,'single'); %initialise prediction neuron outputs
  end
  %set feedback weights equal to feedforward weights normalized by maximum value:
  V{s}=bsxfun(@rdivide,abs(W{s}),max(1e-6,max(abs(W{s}),[],2)));
  V{s}=V{s}'; %avoid having to take transpose at each iteration
end

for t=1:iterations  
  for s=1:numStages
    if t>1
      %provide input from other processing stages by copying part of the that stage's reconstruction to form part of the input to this stage
      for s2=1:numStages
        x{s}(interconnects{s,s2})=r{s2}(interconnects{s2,s});
      end
    end
    
    %update responses
    r{s}=V{s}*y{s};  
    e{s}=x{s}./max(epsilon2,r{s});
    y{s}=max(epsilon1,y{s}).*(W{s}*e{s});

     
    if nargout>3, ytrace{s}(:,t)=y{s}; end
  end
end	
