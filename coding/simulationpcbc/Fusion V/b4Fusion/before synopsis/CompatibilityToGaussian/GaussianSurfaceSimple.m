load "usblData.mat"

x = linspace(0.5, 8.5, 50);
x1 = linspace(-145,-135,50);
W = [];
W = [x x1];
%this will create 50 values from -5 to 5
[X,Y] = meshgrid(W(1:end,1:50));
[X1,Y1] = meshgrid(W(1:end,51:100));
%it will generate same a square matrix of row or column
% X contains same values like x
% Y is transpose of x
fcn1 = @(x,y,xc,yc,sigma) exp(-(((x-xc).^2) + ((y-yc).^2))/5)*(1 / (sigma * sqrt(2*pi))); 


 %fcn is function which is used to generate offselts
 %x and y are inputs
 % Parameters ‘a’ & ‘b’ Are Offsets
figure(1)

mesh(X,Y,-fcn1(X,Y,-145,-145,0.2))
hold on
mesh(X1,Y1,-fcn1(X1,Y1,-140,-140,0.2))



hold off