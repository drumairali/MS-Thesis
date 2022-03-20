W = [];
j = -140;
% input made with difference of 10 
% stored in W
for i = -150:10:140
x = linspace(i, j, 50);
W = [W x];
if (j<150)
j = j+10;
endif

end
Xcon = []; % X container
Ycon = [];
%this will create 50 values from -5 to 5
j = 1;
for i=50:50:1500

[X,Y] = meshgrid(W(1,j:i));
if (j<1451)
j = j+50;
endif

Xcon = [Xcon X];
Ycon = [Ycon Y];
endfor
size(Xcon)
%it will generate same a square matrix of row or column
% X contains same values like x
% Y is transpose of x
fcn1 = @(x,y,xc,yc,sigma) exp(-(0.5/sigma.^2).*(((x-xc).^2) + ((y-yc).^2))); 


 %fcn is function which is used to generate offselts
 %x and y are inputs
 % Parameters ‘a’ & ‘b’ Are Offsets
figure(1)

mesh(Xcon(1:end,1:50),Ycon(1:end,1:50),fcn1(Xcon(1:end,1:50),Ycon(1:end,1:50),-145,-145,0.2))
hold on
j = 1;
c=-145;
% to print guassians on diagonal
for i=50:50:1500
mesh(Xcon(1:end,j:i),Ycon(1:end,j:i),fcn1(Xcon(1:end,j:i),Ycon(1:end,j:i),c,c,0.2))
if (j<1451)
j = j+50;
endif
if (c<146)
  c=c+10;
  endif

endfor

j = 1;
c=-145;
%


for i=50:50:1500
mesh(Xcon(1:end,1:50),Ycon(1:end,j:i),fcn1(Xcon(1:end,1:50),Ycon(1:end,j:i),-145,c,0.2))
if (j<1451)
j = j+50;
endif
if (c<146)
  c=c+10;
  endif

endfor






hold off
