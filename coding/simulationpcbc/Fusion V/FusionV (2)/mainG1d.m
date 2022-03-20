clc
clear all
%just to enter sensor value 
#### select any value  (total 4355) 
pkg load image
inValDGPS=197; 

%change inValDGPS to any value b/w 1-5355


load "dgpsData.mat"
x=dgpsData(:,2);
yin=dgpsData(:,3);
range=[-1:0.01:1];
sigma=0.05;
 
% xdiff has difference of x values
xdiff=findchange(x)
ydiff=findchange(yin)
centers=[-1:0.05:1]


%Weight matrix  
 [W] = getMatrix(centers,range,sigma);


#pcbc
 
 
 
x=gaussian1D_bank(range,xdiff(1,inValDGPS),sigma)
yin=gaussian1D_bank(range,ydiff(1,inValDGPS),sigma)

x=single(imnoise(uint8(125.*x),'poisson'))./125; % poison noise {pkg load image}
 x=x';
 yin=single(imnoise(uint8(125.*yin),'poisson'))./125; % poison noise {pkg load image}

 yin=yin';

 [yx,e,r]=dim_activation(W,x);
  [yy,e,r]=dim_activation(W,yin);
 clear figure(1)
 figure(1)
 
 subplot(2,2,1)
 plot(range,x)
 title("input x")
 
 subplot(2,2,3)
 plot(centers,yx)
 title("output for x")
 
 subplot(2,2,2)
 plot(range,yin)
 title("input y")
 subplot(2,2,4)
 plot(centers,yy)
 title("output for y")
 
 input=xdiff(inValDGPS) %difference val of dgps sensor
[decodedX]=gaussDecode(yx',centers) %after pcbc decoded y value

 input=ydiff(inValDGPS) %difference val of dgps sensor
[decodedY]=gaussDecode(yy',centers) %after pcbc decoded y value
 
 