function [mu,var]=decode(z,s,expon,wrap)


  mu=sum(z.*s)./sum(z);
  var=sum(z.*(mu-s).^2)./sum(z);
  
end
