function y= GS(range,c,sigma)
  A=1/(sqrt(2*pi*(sigma^2)))
  y=A*exp(-((0.5/sigma.^2).*(range-c).^2));
endfunction
