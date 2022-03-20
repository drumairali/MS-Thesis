
function y = inputGauss(x,y,inx,iny,ZMAT,n,c,range,ii);

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
 



figure(ii+1)

  surf(inx,iny, ZMAT((pxnum-(range-1)):(pxnum),(pynum-(range-1)):(pynum)))
  
  title(['Row and column are ',num2str(xnum),' and ',num2str(ynum),' respectively'])


endfunction
