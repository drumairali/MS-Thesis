clear all
clc

#Sir it is flexible code you can make 
#gaussians surface range according to your need
#in second function you can get surface gaussian of respective input

#sensor input
load "usblData.mat"
x = usblData(1:end,2);
y = usblData(1:end,3);
[slen,extra]=size(x);


#setting values of gaussian surface
starting_value_range =-200;
differ=5;
ending_value_range =200;
global sigma=10;


#setting centers and deviation of gaussians
centers = [starting_value_range:differ:ending_value_range];

%To call function for gaussian surface assigning values

instGaussSurf(starting_value_range, differ, ending_value_range, centers,sigma)

#important parameters were saved in upper function for later use
global n range c ZMAT inx iny vector


#inx,iny,ZMAT,n,c,range are obtained by instGaussSurf function
#call the function and print input
for ii=1:1
  inputGauss(x(ii),y(ii),inx,iny,ZMAT,n,c,range,ii)
  hold on


end

hold off
figure(9)
plotvector=sum(vector)
plot(plotvector)


