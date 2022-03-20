load "usblData.mat"

x11= 0.5851-1;
x12= 0.5851+1;

y11= -0.661-1;
y12= -0.661+1;

x1 = linspace(x11,x12,30);
y1 = linspace(y11,y12,30)

[X1] = meshgrid(x1);
[Y1] = (meshgrid(y1))';

x21= -8.4836-1;
x22= -8.4836+1;

y21= 4.967-1;
y22= 4.967+1;

x2 = linspace(x21,x22,30);
y2 = linspace(y21,y22,30)

[X2] = meshgrid(x2);
[Y2] = (meshgrid(y2))';






fcn1 = @(x,y,xc,yc,sigma) exp(-(((x-xc).^2) + ((y-yc).^2))/0.2)*(1 / (sigma)); 
%divide by 5 for proper distribution
%sigma wil1l control the height

 %fcn is function which is used to generate offselts
 %x and y are inputs
 % Parameters ‘a’ & ‘b’ Are Offsets
figure(1)

mesh(X1,Y1,-fcn1(X1,Y1,0.5851,-0.661,0.318))
hold on
mesh(X2,Y2,-fcn1(X2,Y2,-8.4836,4.967,0.347))
scatter3(usblData(1,2),usblData(1,3),usblData(1,4))
scatter3(usblData(2,2),usblData(2,3),usblData(2,4))
hold off
saveas(gcf,'myfigure.pdf')