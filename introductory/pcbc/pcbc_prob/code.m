function z=code(mu,s,sigma,noise,norm,stdnorm,wrap)
if nargin<7 || isempty(wrap)
  wrap=0;
end

z=zeros(1,length(s),'single');

if isnan(mu)
  return; %NaNs = distribution all zeros
end

%Make distribution with given standard deviation and mean, and with an amplitude of one.
%Used to define input PPCs (when all have same precision) and V weights
if wrap %input space wraps around 
  a=s(end)-s(1)+s(2)-s(1);
  z=z+exp(-(0.5/sigma.^2).*min([abs(mu-s);abs(mu-(s+a));abs(mu-(s-a))]).^2);
else %no wrap-around
  z=z+exp(-(0.5/sigma.^2).*(mu-s).^2);
end

%add noise
if nargin>3 && noise
  %add poisson noise
  z=single(imnoise(uint8(125.*z),'poisson'))./125; 
end

%Modify distibution so that it has a sum of one, used to define W weights
if nargin>4 && norm
  spacing=mean(diff(s));
  z=spacing.*z./(sigma*sqrt(2*pi));
  
  if 0 %~wrap 
    %for weights cut-off at edges, adjust weights at edge so that sum remains one
    if z(1)>z(end)
      z(1)=z(1)+1-sum(z);
    else
      z(end)=z(end)+1-sum(z);
    end    
  end
end

%Modify distibution so that it would have an amplitude of one if sigma=stdnorm
%(amplitude is <1 if sigma>stdnorm, and amplitude is >1 if sigma<stdnorm). Used
%to define input PPCs which all have a constant sum (so that the effects of
%changing the precision can be observed without the confound of changing the overal strength
%of the input).
if nargin>5 && stdnorm
  z=stdnorm.*z/sigma;
end

