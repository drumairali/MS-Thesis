function gabor=gabor2D(sigma,orient,aspect,wavel,phase,pxsize,x0,y0)
%function gabor=gabor2D(sigma,orient,aspect,wavel,phase,pxsize,x0,y0)
%
% This function produces a numerical approximation to 2D Gabor function.
% Parameters:
% sigma  = standard deviation of Gaussian envelope, this in-turn controls the
%          size of the result (pixels)
% orient = orientation of the Gabor clockwise from the vertical (degrees)
% aspect = aspect ratio of Gaussian envelope (0 = no "width" to envelope, 
%          1 = circular symmetric envelope)
% wavel  = the wavelength of the sin wave (pixels)
% phase  = the phase of the sin wave (degrees)
% pxsize = the size of the filter.
%          Optional, if not specified size is 5*sigma.
% x0,y0  = location of the centre of the gabor.
%          Optional, if not specified gabor is centred in the middle of image.

%convert degrees to radians 
orient=-orient*pi/180;
phase=phase*pi/180;
freq=2*pi./wavel;

if nargin<6, pxsize=odd(5*sigma); end
if nargin<7, x0=0; y0=0; end

[x y]=meshgrid(-fix(pxsize/2):fix(pxsize/2),fix(-pxsize/2):fix(pxsize/2));
 
% Rotation 
x_theta=(x-x0)*cos(orient)+(y-y0)*sin(orient);
y_theta=-(x-x0)*sin(orient)+(y-y0)*cos(orient);

gabor=exp(-0.5.*( ((x_theta.^2)/(sigma^2)) ...
			 + ((y_theta.^2)/((aspect*sigma)^2)) )) ...
   .* (cos(freq*y_theta+phase) - cos(phase).*exp(-0.25.*((sigma*freq).^2)));

%if abs(sum(sum(gabor)))./sum(sum(abs(gabor)))>0.01
%  disp('WARNING unbalanced Gabor');
%  abs(sum(sum(gabor)))./sum(sum(abs(gabor)))
%end