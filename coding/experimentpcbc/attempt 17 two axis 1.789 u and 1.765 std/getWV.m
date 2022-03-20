function [W,V] = getWV(range,centers,sigmaOdom,sigmaUSBL)
W=[];
for iw=1:length(centers)
  WG1D = [G1D(range,centers(iw),sigmaOdom) G1D(range,centers(iw),sigmaUSBL)];
  W=[W;WG1D];
end

V =bsxfun(@rdivide,abs(W),max(1e-6,max(abs(W),[],2)));
V = V';
end
