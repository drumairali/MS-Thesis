for uu = 1:200

if (tImu<=t && iImu<6301)
  
x1=gaussian1D_bank(1,rangW2,0,1);
  x2=zeros(1,801);

  t=imuData(iImu+1,1)
  iImu =iImu +1
  rp=0;
endif
if (tUsbl<=t && iUsbl<158)
  iUsbl=iUsbl+1
  dxUsbl=usblData(iUsbl,2)-usblData(iUsbl-1,2)
   
  x1=gaussian1D_bank(1/40,rangW2,allCalVal(uu),1);
  x2=gaussian1D_bank(1,rangW2,dxUsbl,sigmaW2);
  tUsbl = usblData(iUsbl+1,1)
  rp=1;
endif


%x2=gaussian1D_bank(1,rangW2,-29,sigmaW2);

#x3=gaussian1D_bank(rangW3,usblData(1,2),sigmaW3)
#x4=gaussian1D_bank(rangW4,0,sigmaW4)
x=[x1 x2];
x=x';
y=zeros(801,1);


for it=1:10
  %x=single(imnoise(uint8(125.*x),'poisson'))./125; 
  %y=single(imnoise(uint8(125.*y),'poisson'))./125; 
  
  %update responses
  r=V*y;
  %e=x./max(epsilon2,r);
  e=x./(epsilon2+r);
  %y=max(epsilon1,y).*(W*e);
  y=(epsilon1+y).*(W*e);

end	
[decodedX]=gaussDecode(y',[-40:0.1:40])

if rp==1
  
allCalVal(uu+1)=decodedX + usblData(iUsbl-1,2);
decodedXol=allCalVal(uu+1);
else
decodedXol=decodedXol + decodedX
allCalVal=[allCalVal; decodedXol];
gtData(uu,2)
endif

endfor
figure
hold on
plot(gtData(1:599,2))
plot(allCalVal)