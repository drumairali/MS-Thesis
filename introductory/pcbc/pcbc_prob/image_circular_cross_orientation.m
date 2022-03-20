function I=image_circular_cross_orientation(csize,vsize,wavelc,wavelm,angle,diff,phasec,phasem,contc,contm)
%function I=image_circular_cross_orientation(csize,vsize,wavelc,wavelm,angle,diff,phasec,phasem,contc,contm)
%
% csize  = the diameter of the centre patch (pixels)
% vsize  = the width of the blank area around the centre
% wavelc  = the wavelength of the principal grating (pixels)
% wavelm  = the wavelength of the mask grating (pixels)
% angle = angle of the principal grating
% diff = angle between the gratings
% phasec = the phase of the principal grating
% phasem = the phase of the mask grating
% contc = contrast of the principal grating
% contm = contrast of the mask grating

freqc=2*pi./wavelc;
freqm=2*pi./wavelm;
angle=-angle*pi/180;
diff=-diff*pi/180;
phasec=phasec*pi/180;
phasem=phasem*pi/180;

%define image size
sz=fix(csize+2*vsize);
if mod(sz,2)==0, sz=sz+1;end %image has odd dimension

%define mesh on which to draw sinusoids
[x y]=meshgrid(-fix(sz/2):fix(sz/2),fix(-sz/2):fix(sz/2));
yr=-x*sin(angle)+y*cos(angle);
yc=-x*sin(angle+diff)+y*cos(angle+diff);

%make sinusoids with values ranging from 0 to 1 (i.e. contrast is positive)
grating=contc.*cos(freqc*yr+phasec);
cross=contm.*cos(freqm*yc+phasem);
plaid=(grating+cross);

%define radius from centre point
radius=sqrt(x.^2+y.^2);

%put togeter image from components
I=zeros(sz);
I(find(radius<csize/2))=plaid(find(radius<csize/2));
