%just to enter sensor value 
#### select any value  (total 4355) 
inValDGPS=231; 

%change inValDGPS to any value b/w 1-5355


load "dgpsData.mat"
x=dgpsData(:,2);
range=[-1:0.01:1];
  sigma=0.05;
% xdiff has difference of x values
xdiff=findchange(x)
centers=[-1:0.05:1]


%Weight matrix  
 [W] = getMatrix(centers,range,sigma);


#pcbc
 
 
 
x=gaussian1D_bank(range,xdiff(1,inValDGPS),sigma);
  [decodedX]=gaussDecode(x,centers');
 x=x';

 [y,e,r]=dim_activation(W,x);
 figure(1)
 
 subplot(2,1,1)
 plot(range,x)
 title("input")
 subplot(2,1,2)
 plot(centers,y)
 title("output")
 
 input=xdiff(inValDGPS) %difference val of dgps sensor
[decodedX]=gaussDecode(y',centers) %after pcbc decoded y value
 
 