W = [];
j = -190;
% input made with difference of 10 
% stored in W
for i = -200:10:200
x = linspace(i, j, 50);
W = [W x];
if (j<201)
j = j+10;
endif

end
Xcon = []; % X container
Ycon = [];
j = 1;
for i=50:50:2050

[X,Y] = meshgrid(W(1,j:i));
if (j<2051)
j = j+50;
endif

Xcon = [Xcon X];
Ycon = [Ycon Y];
endfor
size(Xcon);
%it will generate same a square matrix of row or column
% X contains same values like x
% Y is transpose of x
fcn1 = @(x,y,xc,yc,sigma) exp(-(((x-xc).^2) + ((y-yc).^2))/5)*(1 / (sigma * sqrt(2*pi))); 


 %fcn is function which is used to generate offselts
 %x and y are inputs
 % Parameters ‘a’ & ‘b’ Are Offsets
figure(1)

mesh(Xcon(1:end,1:50),Ycon(1:end,1:50),fcn1(Xcon(1:end,1:50),Ycon(1:end,1:50),-195,-195,0.2))
hold on
j = 1;
c=-195;
% to print guassians on diagonal
for i=50:50:2050
mesh(Xcon(1:end,j:i),Ycon(1:end,j:i),fcn1(Xcon(1:end,j:i),Ycon(1:end,j:i),c,c,0.2))
if (j<2051)
j = j+50;
endif
if (c<196)
  c=c+10;
  endif

endfor

j = 1;
c=-195;
%
jj=1;
cc=-195;

for ii= 50:50:2050

for i=50:50:2050
mesh(Xcon(1:end,jj:ii),Ycon(1:end,j:i),fcn1(Xcon(1:end,jj:ii),Ycon(1:end,j:i),cc,c,0.2))
if (j<2051)
j = j+50;
endif
if (c<196)
  c=c+10;
  endif

endfor
if (jj<2051)
jj = jj+50;

endif
if (cc<196)
  cc=cc+10;
endif  
j = 1;
c=-195;
endfor




hold off
saveas(gcf,'myfigure.pdf')
