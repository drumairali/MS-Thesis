
function y = inputGauss(x,y,inx,iny,ZMAT,n,c,range,ii);
global n range c ZMAT inx iny vector sigma
input = [x y];

Dx=[];
Dy=[];
for i=1:n
 dx =abs( input(1,1) - c(i));
Dx=[Dx dx];

    dy =abs( input(1,2) - c(i));
Dy=[Dy dy];

  end

  bigVal = 100000000;
inputX = [Dx]
OX = inputX
inputY = [Dy]
OY = inputY

[A1X,B1X]=min(OX);
OX(B1X) = bigVal;
[A1Y,B1Y]=min(OY);
OY(B1Y) = bigVal;



[A2X,B2X] = min(OX);
OX(B2X) = bigVal;
[A2Y,B2Y] = min(OY);
OY(B2Y) = bigVal;


[A3X,B3X] = min(OX);
OX(B3X) = bigVal;
[A3Y,B3Y] = min(OY);
OY(B3Y) = bigVal;



[A4X,B4X] = min(OX)
OX(B4X) = bigVal;
[A4Y,B4Y] = min(OY);
OY(B4Y) = bigVal;

  
B1X
B1Y
B2X
B2Y
B3X
B3Y
B4X 
B4Y
  
A1X
A1Y
A2X
A2Y
A3X
A3Y
A4X 
A4Y
  
xnum = [B1X B2X B3X B4X]  
  
ynum = [B1Y B2Y B3Y B4Y]  
  
  vectorX=[];
  figure(2)
for u=1:2
#for selecting accurate range


pxnum=range*xnum(u);
pynum=range*ynum(u);
 




  surf(inx,iny, ZMAT((pxnum-(range-1)):(pxnum),(pynum-(range-1)):(pynum)))
  
vectorX = ZMAT((pxnum-(range-1)):(pxnum),(pynum-(range-1)):(pynum));
vector = [vector vectorX];
hold on
clear pxnum
clear pynum
######

end
figure(20)
    inpGauss=exp(-(0.5/sigma.^2).*(((inx-x).^2) + ((iny-y).^2)));
    surf(inx,iny,inpGauss)

figure(21)
 inpGauss = inpGauss.*vectorX
 surf(inx,iny,inpGauss)

vector=inpGauss;
endfunction
