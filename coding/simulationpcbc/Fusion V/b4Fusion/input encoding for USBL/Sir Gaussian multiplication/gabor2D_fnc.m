function GB=gabor2D_fnc(Yorg,Xorg,Size,sigma,theta,freq,figureNo)   % Gx,Gy % Sx,Sy
% 2D Gabor Filter/Function
%   Where:
%   Xorg,Yorg--------> are coordinate values where gabor filter will have 
%   its peak value
%   sZ--------> is a row vector [X Y] containing the size of the 
%   Retinotopic Space because of Image
%   sigma-----> is a row vector [sigmaY sigmaX]
%   theta-------> orientation of the blob along X axis
%   freq-------->
%   Example: GB=gabor2D_fnc(300,300,[600 600],[4 4],0,0);
%            [gb,gx,gy]=gabor2D_fnc(25,25,[50 50]);
%            [GB,Sx,Sy]=gabor2D_fnc(300,300,[600 600],[4 4],0,0);
global v xrot yrot
 A=1; 
 if nargin<5
    theta=0;
    freq=0;
 end
if nargin<4
 sigma(1)=2;
 sigma(2)=2;
end
if nargin<3
    Size(1)=sigma(2);
    Size(2)=sigma(1);
end
[x,y]=meshgrid(1:Size(2),1:Size(1)); 
xrot=x*cos(theta)+y*sin(theta);
yrot=-x*sin(theta)+y*cos(theta);
GB=A*(exp(-0.5*((xrot-Xorg).^2/sigma(2)^2+(yrot-Yorg).^2/sigma(1)^2)).*cos(2*pi*freq*xrot));
v=GB;

surf(xrot,yrot,GB)

