load "usblData.mat"
 W = [];
 xcon = [];
 ycon = [];
 zcon = [];
  x = usblData(1:end,2);
  y = usblData(1:end,3);
  z = usblData(1:end,4);
  
  


% selecting span
  x(1:end,2) = usblData(1:end,2) - 1;
  x(1:end,3) = usblData(1:end,2) + 1; 
  y(1:end,2) = usblData(1:end,3) - 1;
  y(1:end,3) = usblData(1:end,3) + 1;

  
fcn1 = @(x,y,xc,yc,sigma) exp(-(((x-xc).^2) + ((y-yc).^2))/0.2)*(1 / (sigma)); 
i=0;

%to print each guassian
for i =1:158
i

  x11 = x(i,2);
  x12 = x(i,3);
  y11 = y(i,2);
  y12 = y(i,3);
   
x2 = linspace(x11,x12,50);
y2 = linspace(y11,y12,50);

X2 = meshgrid(x2);
Y2 = (meshgrid(y2))';

sigma = 0.9;
while(z(i,1)<min(min(-fcn1(X2,Y2,x(i,1),y(i,1),sigma))))
sigma = sigma - 0.0001;
end
Z2=-fcn1(X2,Y2,x(i,1),y(i,1),sigma);

sigma = 0.9;
xcon = [xcon;X2];
ycon = [ycon;Y2];
zcon = [zcon;Z2];

endfor
% 50x50 x and y .... 1x50 zcon
W = [xcon ycon zcon];
hold off