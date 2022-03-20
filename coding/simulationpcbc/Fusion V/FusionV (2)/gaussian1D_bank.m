function [gaussianResp]=gaussian1D_bank(range,center,sigma) 
% Example: range=(1:1:20); 
% center=12;
% [gaussianResp]=gaussian1D_bank(range,center) 

gaussianResp=exp(-(0.5/sigma.^2).*(range-center).^2);
