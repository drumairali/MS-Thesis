function cont= DeadReckoning(t_i,x_i,y_i,x_g,y_g)

cont=[];
sumDerX=x_g(1);
for i = 1:(length(t_i)-1)
  n=i;
  for j = 1:n
    sumDerX+= x_i(j);
  endfor
  contx(i) = sumDerX;
  sumDerX=x_g(1); 
endfor
cont=[];
sumDerY=y_g(1);
for i = 1:(length(t_i)-1)
  n=i;
  for j = 1:n
    sumDerY+= y_i(j);
  endfor
  conty(i) = sumDerY;
  sumDerY=y_g(1);; 
endfor

cont= [contx; conty];
end

