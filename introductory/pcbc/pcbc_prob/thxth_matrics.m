# 3x3 matrics

function [xnum,ynum] = thxth_matrics(x,y)

[inx,iny] = meshgrid([1:1:20]);

c1=5;
c2=10;
c3=15;

sigma = 1;

z1=exp(-(0.5/sigma.^2).*(((inx-c1).^2) + ((iny-c1).^2)));
z2=exp(-(0.5/sigma.^2).*(((inx-c1).^2) + ((iny-c2).^2)));
z3=exp(-(0.5/sigma.^2).*(((inx-c1).^2) + ((iny-c3).^2)));
z4=exp(-(0.5/sigma.^2).*(((inx-c2).^2) + ((iny-c1).^2)));

z5=exp(-(0.5/sigma.^2).*(((inx-c2).^2) + ((iny-c2).^2)));
z6=exp(-(0.5/sigma.^2).*(((inx-c2).^2) + ((iny-c3).^2)));
z7=exp(-(0.5/sigma.^2).*(((inx-c3).^2) + ((iny-c1).^2)));
z8=exp(-(0.5/sigma.^2).*(((inx-c3).^2) + ((iny-c2).^2)));
z9=exp(-(0.5/sigma.^2).*(((inx-c3).^2) + ((iny-c3).^2)));

figure(1)
  surf(inx,iny, z1)
hold on
  surf(inx,iny, z2)
  surf(inx,iny, z3)

  surf(inx,iny, z4)
  surf(inx,iny, z5)
  surf(inx,iny, z6)

  surf(inx,iny, z7)
  surf(inx,iny, z8)
  surf(inx,iny, z9)
 Z = [z1 z2 z3; z4 z5  z6; z7 z8 z9];
 
 
 ### Now input xy plane has to made

 
 
 

 input = [x y]

dx1 =abs( input(1,1) - c1);
dy1 = abs(input(1,2) - c1);

dx2 =abs( input(1,1) - c2);
dy2 = abs(input(1,2) - c2);

dx3 =abs( input(1,1) - c3);
dy3 = abs(input(1,2) - c3);


dx = [dx1 dx2 dx3];;
dy = [dy1 dy2 dy3];

[Dx,xnum]=min(dx);
[Dy,ynum]=min(dy);

xnum
ynum

% this will tell the nearest gaussian is x,y and distance is Dx,Dy

pxnum=20*xnum
pynum=20*ynum
 
figure(2)
 
  surf(inx,iny, Z((pxnum-19):(pxnum),(pynum-19):(pynum)))
