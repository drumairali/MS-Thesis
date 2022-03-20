function [W,V] = getWV_modifd(range,centers,angRng,angCntrs,sigmaOdom,sigmaUSBL,sigmaAng)
W=[];

for iw=1:length(centers)
  WG1D = [G1D(range,centers(iw),sigmaOdom)... 
      G1D(range,centers(iw),sigmaUSBL)... 
      G1D(angRng,angCntrs(iw),sigmaAng)];
  W=[W;WG1D];
end
W=bsxfun(@rdivide,W,max(1e-6,sum(W,1)));
V =bsxfun(@rdivide,abs(W),max(1e-6,max(abs(W),[],2)));
V = V';
end
