#to make inputs and centers 
[inx,iny] = meshgrid([1:5:100]);
xc = yc = [1:10:100];
sigma = 10;
#weights 
% making of first weight 
oz = [];
for c1 = xc
  for c2 = yc
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

# now i add for lop for step by step printing
j=20;
for i=1:20:2000
  surf(inx,iny,W(i:j,1:end ))
    hold on
j=j+20;
end
  title('Weights W of 2D')

hold off


######## now input is to be made #########

xc = 50;
yc = 50;
sigma = 5;
figure(2)

z=exp(-(0.5/sigma.^2).*(((inx-xc).^2) + ((iny-yc).^2)));
input_gauss =z';



###################### PC/BC-DIM process #############

% to make normalized transpoze of W
  V=bsxfun(@rdivide,abs(W),max(1e-6,max(abs(W),[],2)));

 V=V'; 

 figure(3)
 j=20;
for i=1:20:2000
  surf(inx,iny,V(1:end ,i:j))
    hold on
j=j+20;
end
title('V, normalized Transpoed of W')

hold off
 
% Setting parameters of PC/BC-DIM

[n,m] = size(W);
[inchanel,blength]= size(input_gauss);
y=zeros(n,blength);
x=input_gauss;

epsilon1=1e-6;
epsilon2=1e-4;

for iteration= 1:25
r=V*y;
e = x./(epsilon2+r);

y=(epsilon1+y).*(W*e);

end



figure(4)

surf(inx,iny,x)
title('input x')

figure(5)
j=20;
for i=1:20:2000
  surf(inx,iny,y(i:j,1:end ))
    hold on
j=j+20;

end
title('prediction y')


figure(6)

surf(inx,iny,r)
title('reconstruction r')



