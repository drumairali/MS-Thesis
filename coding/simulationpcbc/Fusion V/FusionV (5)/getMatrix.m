function [W]=getMatrix(centers,range,sigma)
 

 gdvectMat=[];

  for i = 1:length(centers)
 [gaussianResp2]=gaussian1D_bank(1,range,centers(i),sigma) ;
 gdvectMat =[gdvectMat; gaussianResp2];
end
W=gdvectMat;
endfunction
