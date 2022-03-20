function [xdiff] = findchange(x)
  xlength=size(x,1)
xdiff=[]
for i = 1:xlength-1
  xd = x(i+1)-x(i);
  xdiff = [xdiff xd];
  end

endfunction

