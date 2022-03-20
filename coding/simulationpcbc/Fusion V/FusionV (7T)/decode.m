function [mu,var]=decode(z,s,expon,wrap)
if nargin<3 || isempty(expon)
  expon=1;
else
  z=z.^expon;
end
if nargin<4 || isempty(wrap)
  wrap=0;
end

if wrap %input space wraps around
  a=s(end)-s(1)+s(2)-s(1);
  f=360/a;
  mu=180/pi*phase(sum(z.*exp(i*s.*f*pi/180))./sum(z))./f;
  mu=mod(mu,a);
  if nargout>1
    var=sum(z.*min([abs(mu-s);abs(mu-(s+a));abs(mu-(s-a))]).^2)./sum(z);
  end
else %no wrap-around
  mu=sum(z.*s)./sum(z);
  if nargout>1
    var=sum(z.*(mu-s).^2)./sum(z);
  end
end
