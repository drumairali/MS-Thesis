# instant gaussian Surface making

% instGauss(1,40,[10:10:30],3)


%ival is fitst value of surfacec
%fval is last value of surfacec
%c is matrics of center
%sigma is standard deviation




function gaussSurf = instGaussSurf(ival,differ,fval,c,sigma,x,y)
global n range c ZMAT inx iny
  
[inx,iny] = meshgrid([ival:differ:fval]);


[extra,range]=size(inx);


[m,n]=size(c);


zmat = [];
for i = 1:n
  zrow = [];
  for j = 1:n
    zv=exp(-(0.5/sigma.^2).*(((inx-c(i)).^2) + ((iny-c(j)).^2)));
    zrow = [zrow zv];
 
  end

  zmat = [zmat; zrow];
  
end

ZMAT = zmat;


ix=1;
fx=range;

iy=1;
fy=range;
%figure(1) printing .... consume too much time

 #ZMAT=[];
 #for i = 1:n
 # for j = 1:n
 # surf(inx,iny, zmat(ix:fx,iy:fy)) which will plot gaussian surface
 # ZMAT(ix:fx,iy:fy) =zmat(ix:fx,iy:fy);

 # ix = ix+range
 # fx = fx+range;
 # hold on
 # end
 # ix=1;
 # fx=range;

 # iy = iy+range;
 # fy = fy+range;

 #end
# now surface is completed 
#time to work on input

endfunction
