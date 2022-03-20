clear 
clc
t = linspace(0,2.*pi,500)';
dt = t(2) - t(1);

x = 2*cos( t );
y = sin(1 * t);

gps_sig = 0.2;

# noisy measurements
x_gps = x + gps_sig .* randn(length(x),1);
y_gps = y + gps_sig .* randn(length(y),1);

# abrupt noise at different points in y axis 
y_gps(40)=5
y_gps(100)=7
y_gps(200)=9
y_gps(400)=10
y_gps(50)=5
y_gps(150)=7
y_gps(250)=9
y_gps(350)=10


#setting same range and centers for both sensors
range=[-2:0.1:2]; # -14 to 14 
centers=[-2:0.1:2];

#initialize some parameters for PC/BC-DIM
sigInert=1; 
sigGlob=1;


[W,V] = getWV(range,centers,sigInert,sigGlob);
[n,m]=size(W)
yX=zeros(n,1);
yY=zeros(n,1);

#Collection of each sensor at its proper time and numbering
iOdom=1; #value number of Odom measurement
iUsbl=1; 
tempSavPosX=x(1);
tempSavPosY=y(1); # this is accomulated position before saving to globalTraj
lastUsblX=x_gps(1);
lastUsblY=y_gps(1); 
globalTraj=[];
decodPosX=x(1);
decodPosY=y(1);
 fprintf('program is processing...')
tic
OdomX=zeros(1,m/2)
OdomY=zeros(1,m/2)
for val=1:length(x)-1
  UsblX = G1D(range,x_gps(iUsbl+1)-lastUsblX,sigGlob); 
  UsblY = G1D(range,y_gps(iUsbl+1)-lastUsblY,sigGlob); 
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

  gXOdom = decodPosX ;
  gYOdom = decodPosY ;
  OdomX = G1D(range, gXOdom, sigInert); 
  OdomY = G1D(range, gYOdom, sigInert); 

globalTraj=[globalTraj;tempSavPosX+decodPosX tempSavPosY+decodPosY];
end       
toc



figure(1)

plot(x,y,"LineWidth", 3)
hold on 
plot(globalTraj(:,1),globalTraj(:,2),"LineWidth", 2)
plot(x(1),y(1),".o","LineWidth", 7)
plot(x(end),y(end),".x","LineWidth", 7)
plot(x_gps,y_gps,"-")
legend("actual path","PCBC Trajectory","starting point","ending point","GPS Trajectory")
set(gca,'FontSize',20)
hold off
#axis([-2.5 2.5 -1.5 2.5])
