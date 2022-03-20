% not commplete yet
load "imuData.mat"
 W = [];
 x = [];
 y = [];

  x = imuData(1:end,2);
  y = imuData(1:end,3);
  z = imuData(1:end,4);
  
  


% selecting span
  x(1:end,2) = imuData(1:end,2) - 1;
  x(1:end,3) = imuData(1:end,2) + 1; 
  y(1:end,2) = imuData(1:end,3) - 1;
  y(1:end,3) = imuData(1:end,3) + 1;

  
fcn1 = @(x,y,xc,yc,A) (A.*exp(-(((x-xc).^2) + ((y-yc).^2))/0.2)); 
i=0;
for i =1:5
i

  x11 = x(i,2);
  x12 = x(i,3);
  y11 = y(i,2);
  y12 = y(i,3);
   
x2 = linspace(x11,x12,50);
y2 = linspace(y11,y12,50);

X2 = meshgrid(x2);
Y2 = (meshgrid(y2))';

A = z(i,1);
z(i)
mesh(X2,Y2,fcn1(X2,Y2,x(i,1),y(i,1),A))

hold on
mesh(X2,Y2,fcn1(X2,Y2,x(i,1),y(i,1),A))

scatter3(imuData(i,2),imuData(i,3),imuData(i,4))

min(min(fcn1(X2,Y2,x(i,1),y(i,1),A)))

endfor


hold off