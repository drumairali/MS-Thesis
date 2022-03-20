clear all
clc
load 'usblData.mat'
load 'dgpsData.mat'
load 'imuData.mat'
temp =[]
[inx,iny] = meshgrid(-10:0.5:10);
sigma=0.5;
usblfirstRow = usblData(1,:)
iFinal=40;
times=imuData(1:iFinal,1)


x2=usblData(1,2:4)+imuData(1,2:4)
for i = 1:iFinal
  x2 = x2 + (imuData(i,2:4) );
    temp = [temp; x2];
endfor
#### to make weights

oz = [];
for c1 = -10:0.5:10
  for c2 = -10:0.5:10
  #one gaussian is 20x20
z=exp(-(0.5/sigma.^2).*(((inx-c1).^2) + ((iny-c2).^2)));
spacing=5; % 5 in this case
z=spacing.*z./(sigma*sqrt(2*pi));
stdnorm =10;
ZW=stdnorm.*z/sigma;
oz = [oz; z];
end
end

# as all values are stored in oz that is why it appeared as unbalanced
%surf(inx,iny,oz)
W = oz; %weights are assigned to W
[rw,cw]=size(W)
# now i add for lop for step by step printing
j=cw;
%figure(1)
%for i=1:cw:rw
 % surf(inx,iny,W(i:j,1:end ))
  %  hold on
%j=j+cw;
%end
%  title('Weights W of 2D')

%hold off











figure(2)
inz=zeros(cw,cw)
for i = 1:5
inz = inz+exp(-(0.5/sigma.^2).*(((inx-temp(i,1)).^2) + ((iny-temp(i,2)).^2)));

surf(inx,iny,inz)
title('input value')
end
hold off
figure(3)
oo=sum(inz)
plot(oo)
save inz.mat inz


###################### PC/BC-DIM process #############

% to make normalized transpoze of W
  V=bsxfun(@rdivide,abs(W),max(1e-6,max(abs(W),[],2)));

 V=V'; 

 #figure(4)
 #j=cw;

 #for i=1:cw:rw
 # surf(inx,iny,V(1:end ,i:j))
 #   hold on
#j=j+cw;
#end
#title('V, normalized Transpoed of W')

#hold off
 
% Setting parameters of PC/BC-DIM

[n,m] = size(W);
[inchanel,blength]= size(inz);
y=zeros(n,blength);
x=inz;

epsilon1=1e-6;
epsilon2=1e-4;

for iteration= 1:25
r=V*y;
e = x./(epsilon2+r);

y=(epsilon1+y).*(W*e);

end



figure(5)

surf(inx,iny,x)
title('input x')

figure(6)
j=cw;
for i=1:cw:rw
  surf(inx,iny,y(i:j,1:end ))
    hold on
j=j+cw;

end
title('prediction y')


figure(7)

surf(inx,iny,r)
title('reconstruction r')








