clear 
clc
t_g = linspace(0,2.*pi,50)';
t_i = linspace(0,2.*pi,150)';

x_g = 2*cos( t_g );
y_g = sin(1 * t_g);

x_I = 2*cos( t_i );
y_I = sin(1 * t_i);

x_i=[x_I(2:end)-x_I(1:end-1)];
y_i=[y_I(2:end)-y_I(1:end-1)];

#ADDING NOISE
#gps_sig = 0.1;
#inert_sig = 0.05
#x_g = x_g + gps_sig .* randn(length(x_g),1);
#y_g = y_g + gps_sig .* randn(length(y_g),1);
#x_i = x_i + inert_sig .* randn(length(x_i),1);
#y_i = y_i + inert_sig .* randn(length(y_i),1);
#y_gps(4)=5

t_i=t_i(2:end);
inerData=[t_i x_i y_i];
positionData=[t_g x_g y_g];


#setting same range and centers for both sensors
range=[-2:0.1:2]; # -14 to 14 
centers=[-2:0.1:2];

#initialize some parameters for PC/BC-DIM
sigInert=0.1; #sigma 
sigGlob=0.1;


[W,V] = getWV(range,centers,sigInert,sigGlob);
[n,m]=size(W)
yX=zeros(n,1);
yY=zeros(n,1);

#Collection of each sensor at its proper time and numbering
i_iner=1; #value number of Odom measurement
i_g=1; 
tempSavPosX=x_g(1);
tempSavPosY=y_g(1); # this is accomulated position before saving to pcbcTraj
lastGx=x_g(1);
lastGy=y_g(1); 
pcbcTraj=[];
decodPosX=x_g(1);
decodPosY=y_g(1);
fprintf('program is processing...')
tic
 AcumEncMotX=zeros(1,m/2);
 AcumEncMotY=zeros(1,m/2);

t = min([t_i(1) t_g(1)]);
for val=1:length(x_i)-1
  
  if t_g(i_g)<=t && i_g<length(inerData) #     
  EncPosX = G1D(range,x_g(i_g)-lastGx,sigGlob); 
  EncPosY = G1D(range,y_g(i_g)-lastGy,sigGlob); 
  i_g=i_g+1;
else
  EncPosX = zeros(1,m/2);
  EncPosY = zeros(1,m/2); 
  endif

if t_i(i_iner)<=t && i_g<length(inerData) #     

  AcumMotionX = decodPosX+x_i(i_iner) ;
  AcumMotionY = decodPosY+y_i(i_iner) ;
  AcumEncMotX = G1D(range, AcumMotionX, sigInert); 
  AcumEncMotY = G1D(range, AcumMotionY, sigInert); 
  i_iner = i_iner+1;
else
  AcumEncMotX=zeros(1,m/2);
 AcumEncMotY=zeros(1,m/2);
  endif  
   

  xX = [AcumEncMotX EncPosX]';
  xY = [AcumEncMotY EncPosY]';
  [rX,yX]=getRecons(xX,W,V,yX);
  [rY,yY]=getRecons(xY,W,V,yY);
  decodPosX = decode(rX(1:length(range),1)',range); # Position
  decodPosY = decode(rY(1:length(range),1)',range); # Position

if sum(EncPosX)>0.001  # when usbl comes reset odometry accomulation to zero

  tempSavPosX+=decodPosX;
  lastGx=tempSavPosX;   
  decodPosX = 0; 
endif
if sum(EncPosY)>0.001  # when usbl comes reset odometry accomulation to zero
  tempSavPosY+=decodPosY;
  lastGy=tempSavPosY;   
  decodPosY = 0; 
endif

pcbcTraj=[pcbcTraj;t tempSavPosX+decodPosX tempSavPosY+decodPosY];
t = t_i(i_iner);

end       
toc

figure(1)
#plot DeadReckoning
cont=DeadReckoning(t_i,x_i,y_i,x_g,y_g);
plot(x_I,y_I,"LineWidth", 3)
hold on
plot(cont(1,:),cont(2,:),"o")
title("DeadReckoning")
hold off

figure(2)
plot(x_I,y_I,"LineWidth", 3)
hold on 
plot(pcbcTraj(:,2),pcbcTraj(:,3),"LineWidth", 2)
plot(pcbcTraj(1,2),pcbcTraj(1,3),".o","LineWidth", 7)
plot(pcbcTraj(end,2),pcbcTraj(end,3),".x","LineWidth", 7)
plot(x_g,y_g,"o")
legend("actual path","PCBC Trajectory","starting point","ending point","position input")
set(gca,'FontSize',20)
hold off

