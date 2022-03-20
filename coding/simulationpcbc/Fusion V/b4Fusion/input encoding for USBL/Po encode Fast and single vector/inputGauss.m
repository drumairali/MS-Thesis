
function y = inputGauss(x,y,inx,iny,ZMAT,n,c,range,ii);
global n range c ZMAT inx iny vector
input = [x y];

Dx=[];
Dy=[];
for i=1:n
 dx =abs( input(1,1) - c(i));
Dx=[Dx dx];

    dy =abs( input(1,2) - c(i));
Dy=[Dy dy];

  end

[Diffx,xnum]=min(Dx);
[Diffy,ynum]=min(Dy);

xnum
ynum

#for selecting accurate range
pxnum=range*xnum;
pynum=range*ynum;
 




  surf(inx,iny, ZMAT((pxnum-(range-1)):(pxnum),(pynum-(range-1)):(pynum)))
  
vector = ZMAT((pxnum-(range-1)):(pxnum),(pynum-(range-1)):(pynum));


endfunction
