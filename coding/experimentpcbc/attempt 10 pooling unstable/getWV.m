function [W,V] = getWV(rangeUsbl,centersUsbl,sigmaUSBL,rangeOdom,centersOdom,sigmaOdom)
W=[];
for iw=1:length(centersUsbl)
  WG1D = [G1D(rangeUsbl,centersUsbl(iw),sigmaUSBL) G1D(rangeOdom,centersOdom(iw),sigmaOdom)];
  W=[W;WG1D];
end

V =bsxfun(@rdivide,abs(W),max(1e-6,max(abs(W),[],2)));
W = [W eye(length(centersUsbl))];
V = [V  eye(length(centersUsbl))];
V = V';

end
