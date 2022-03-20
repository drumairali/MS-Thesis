#MainFile2
source('PreCompile.m')
x3Cusbl=[];
globalTrajvar3x=[0 0 0];
globalTraj3x=[];
localTraj3x=[];
x3usbl(:,1:4)=usblData(:,1:4);
x3Cusbl(:,1)=usblData(2:158,1);
for x3=2:4
x3Cusbl(:,x3)=findchange(x3usbl(:,x3));
endfor
iImu=2;
iDvl=2;
iUsbl=1;
t=imuData(2,1);
tImu=imuData(2,1);
tDvl=dvlData(2,1);
tUsbl=x3Cusbl(1,1);
dt=imuData(2,1)-imuData(1,1);

#algorithm starts from here
for val=1:6300
  val
if tImu<=t && iImu<6301
  for x3=2:4
    x3IMU(x3-1,:) = G1D(range,localTrajvar3x(1,x3-1)+imuData(iImu,x3),sigmaIMU,AIMU); 
  endfor
  tImu=imuData(iImu+1,1);
  iImu=iImu+1;
endif
  
if 806<=t && iDvl<6301 && 1902>=t
  for x3=2:4
    x3DVL(x3-1,:) = G1D(range,localTrajvar3x(1,x3-1)+dvlData(iDvl,x3),sigmaDVL,ADVL); 
  endfor 
  tDvl=dvlData(iDvl+1,1);
  iDvl=iDvl+1;
else 
  x3DVL =zeros(3,801);
  
  endif

if tUsbl<=t && iUsbl<158
  for x3=2:4
  x3USBL(x3-1,:) = G1D(range,x3Cusbl(iUsbl,x3),sigmaUSBL,AUSBL); 
  endfor
  tUsbl=x3Cusbl(iUsbl+1,1);
  iUsbl=iUsbl+1;
else
  x3USBL=zeros(3,801);
endif

x = [x3IMU x3DVL x3USBL];
x=x';


#PCBC-DIM
for i=1:5
r=V*y;
e=x./(epsilon2+r);
y=(epsilon1+y).*(W*e);
endfor
#Decoding
for x3=1:3
localTrajvar3x(1,x3) = decode(y(:,x3)',centers);
end
localTraj3x=[localTraj3x;t localTrajvar3x];

globalTraj3x=[globalTraj3x;t globalTrajvar3x+localTrajvar3x];

for x3=1:3
if sum(x3USBL(x3,:))>0.1
  globalTrajvar3x(1,x3)+=localTrajvar3x(1,x3);
  localTrajvar(1,x3)=0;
endif
end

t=t+dt;
end
figure
plot3(gtData(1:val,2),gtData(1:val,3),gtData(1:val,4))
hold on 
plot3(globalTraj3x(1:val,2),globalTraj3x(1:val,3),globalTraj3x(1:val,4))
hold off