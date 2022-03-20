clear 
clc
t = linspace(0,2.*pi,200)';
dt = t(2) - t(1);

x = 2*cos( t );
y = sin(1 * t);

gps_sig = 0.1;

# noisy measurements
x_gps = x + gps_sig .* randn(length(x),1);
y_gps = y + gps_sig .* randn(length(y),1);




#setting same range and centers for both sensors
range=[-5:1:5]; # -14 to 14 
centers=[-5:1:5];

#initialize some parameters for PC/BC-DIM
sigmaOdom=1.5; 
sigmaUSBL=1;

priorMean=0;
priorStd=5;
priorDist=G1D([range],priorMean,priorStd);

[W,V] = getWV(range,centers,sigmaOdom,sigmaUSBL,priorDist);
[n,m]=size(W)
yX=zeros(n,1);
yY=zeros(n,1);

#Collection of each sensor at its proper time and numbering
iOdom=1; #value number of Odom measurement
iUsbl=1; 
tempSavPosX=0;
tempSavPosY=0; # this is accomulated position before saving to globalTraj
lastUsblX=0;
lastUsblY=0; 
globalTraj=[];
decodPosX=x(1);
decodPosY=y(1);
 fprintf('program is processing...')
tic
for val=1:length(x)
  

   
  gXOdom = decodPosX ;
  gYOdom = decodPosY ;
  OdomX = G1D(range, gXOdom, sigmaOdom); 
  OdomY = G1D(range, gYOdom, sigmaOdom); 
  iOdom=iOdom+1;


  UsblX = G1D(range,x_gps(iUsbl)-lastUsblX,sigmaUSBL); 
  UsblY = G1D(range,y_gps(iUsbl)-lastUsblY,sigmaUSBL); 
  iUsbl=iUsbl+1;

if sum(UsblX)>0.001  # when usbl comes reset odometry accomulation to zero
  xX = [OdomX UsblX]';
  xY = [OdomY UsblY]';
  [rX,yX]=getRecons(xX,W,V,yX);
  [rY,yY]=getRecons(xY,W,V,yY);
  decodPosX = decode(rX(1:length(range),1)',range); # Position
  decodPosY = decode(rY(1:length(range),1)',range); # Position

  tempSavPosX+=decodPosX;
  lastUsblX=tempSavPosX;   
  decodPosX = 0; 
endif
if sum(UsblY)>0.001  # when usbl comes reset odometry accomulation to zero
  tempSavPosY+=decodPosY;
  lastUsblY=tempSavPosY;   
  decodPosY = 0; 
endif

globalTraj=[globalTraj;tempSavPosX+decodPosX tempSavPosY+decodPosY];
end       
toc



figure(1)
plot(x,y)
hold on 
plot(x(1),y(1),".o","LineWidth", 7)
plot(x_gps,y_gps,"o")
legend("actual path","starting point","GPS points")
title("Actual trajectory with starting points and gps")
hold off

figure(2)
plot(x,y)
hold on 
plot(x(1),y(1),".o","LineWidth", 7)
plot(globalTraj(:,1),globalTraj(:,2),"o")
legend("actual path","starting point","PCBC points")
title("Actual trajectory with starting points and PCBC")
hold off
