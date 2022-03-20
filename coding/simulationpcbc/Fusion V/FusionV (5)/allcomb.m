#first run it then ok file
load("imuData.mat")
load("dvlData.mat")
load("usblData.mat")
load("dgpsData.mat")
load("gtData.mat")
load("altimeterData.mat")

x1 = imuData(1:10,2);
x2 = usblData(1:2,2);

y1 = imuData(1:10,2);
y2 = usblData(1:2,3);

z1 = imuData(1:10,2);
z2 = dvlData(1:10,2);
# distribute equal weights -3.5 to 3.5
cW1 = [-40:0.1:40];
cW2 = [-40:0.1:40];
#cW3 = [-40:1:40];
#cW4 = [-4:0.1:4];
rangW1 = [-40:0.1:40];
rangW2 = [-40:0.1:40];
#rangW3 = [-40:1:40];
#rangW4 = [-4:0.1:4];

sigmaW1 = 1;
sigmaW2 = 1;
#sigmaW3 = 1;
#sigmaW4 = 0.1;
epsilon1=1e-6;
epsilon2=1e-4;

[W1] = getMatrix(cW1,rangW1,sigmaW1);
[W2] = getMatrix(cW2,rangW2,sigmaW2);
#[W3] = getMatrix(cW3,rangW3,sigmaW3);
#[W4] = getMatrix(cW4,rangW4,sigmaW4);
W=[W1 W2];
V=bsxfun(@rdivide,abs(W),max(1e-6,max(abs(W),[],2)));
V=V';


x1=gaussian1D_bank((1),rangW1,0,sigmaW1)
x2=gaussian1D_bank(1,rangW2,-0.5,sigmaW2)
#x3=gaussian1D_bank(rangW3,usblData(1,2),sigmaW3)
#x4=gaussian1D_bank(rangW4,0,sigmaW4)
x=[x1 x2];
x=x';
y=zeros(801,1)


for it=1:20
  %x=single(imnoise(uint8(125.*x),'poisson'))./125; 
  %y=single(imnoise(uint8(125.*y),'poisson'))./125; 
  
  %update responses
  r=V*y;
  %e=x./max(epsilon2,r);
  e=x./(epsilon2+r);
  %y=max(epsilon1,y).*(W*e);
  y=(epsilon1+y).*(W*e);

end	
subplot(2,1,2)
title("input")
plot([-40:0.05:40.05],x)
subplot(2,1,1)
title("output")
plot([-40:0.1:40],y)
[decodedX]=gaussDecode(y',[-40:0.1:40])

figure(1)
 
 subplot(2,2,1)
 plot([-40:0.05:40.05],x,"LineWidth", 2)
 title("input x and y")
  set(gca, "linewidth", 2, "fontsize", 20)

 subplot(2,2,[3,4])
 plot(centers,W,"LineWidth", 2)
 title("Weights")
  set(gca, "linewidth", 2, "fontsize", 20)

  
 subplot(2,2,2)
 plot([-40:0.05:40.05],r,"LineWidth", 2)
 title("reconstructed input x and y")
  set(gca, "linewidth", 2, "fontsize", 20)



allCalVal=[]
allCalVal=[allCalVal; decodedX]

t=0;
iImu=1
iUsbl=1
tUsbl=usblData(2,1)
tImu=imuData(1,1);
decodedXol=0;

