function [decodedX]=gaussDecode(X,gaussCentersX)
%% Example: [decodedX]=gaussDecode(X,gaussCentersX',gaussCentersY');
start=(length(X)-(length(gaussCentersX)))+1;
xResp=X(start:start+length(gaussCentersX)-1);
decodedX=sum(xResp.*gaussCentersX)./sum(xResp);

