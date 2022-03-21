function y= G1D(range,c,sigma,A)
  y=A*exp(-(0.5/sigma.^2).*(range-c).^2);
endfunction
