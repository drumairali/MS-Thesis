clc
clear all
%just to enter sensor value 
#### select any value  (total 4355) 
pkg load image
inValDGPS=55; 

%change inValDGPS to any value b/w 1-5355


load "dgpsData.mat"
x=dgpsData(:,2);
yin=dgpsData(:,3);
range=[-1:0.01:1];
sigma=0.2;
% xdiff has difference of x values
xdiff=findchange(x)
ydiff=findchange(yin)

xydiff=([xdiff(inValDGPS) ydiff(inValDGPS)]);
 
centers=[-1:0.05:1]


%Weight matrix  
 [W] = getMatrix(centers,range,sigma);


#pcbc
 
 
 
x=gaussian1D_bank(range,xdiff(1,inValDGPS),sigma)
yin=gaussian1D_bank(range,ydiff(1,inValDGPS),sigma)
 
 x=x';
 yin=yin';
 xy=[x yin]
 xy=single(imnoise(uint8(125.*xy),'poisson'))./125; % poison noise {pkg load image}

 [yx,e,r]=dim_activation(W,xy);
  clear figure(1)
 figure(1)
 
 subplot(2,2,1)
 plot(range,xy,"LineWidth", 2)
 title("input x and y")
  set(gca, "linewidth", 2, "fontsize", 20)

 subplot(2,2,[3,4])
 plot(centers,W,"LineWidth", 2)
 title("Weights")
  set(gca, "linewidth", 2, "fontsize", 20)

  
 subplot(2,2,2)
 plot(centers,yx,"LineWidth", 2)
 title("reconstructed input x and y")
  set(gca, "linewidth", 2, "fontsize", 20)

 for i =1:2
 input=xydiff(1,i) %difference val of dgps sensor
[decodedX]=gaussDecode(yx'(i,1:41),centers) %after pcbc decoded y value
 endfor
 
 