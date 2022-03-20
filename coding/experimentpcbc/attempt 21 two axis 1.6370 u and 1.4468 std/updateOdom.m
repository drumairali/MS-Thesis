function uodomVal = updateOdom(xval,yval,dTheta)
   fmes = [xval yval]';    
   x1=dTheta ;
   angle = wrapTo2Pi(x1);
   bTr = [cos(angle) -sin(angle); sin(angle) cos(angle)];           
   frameAngle = pi/2;
   rTs = [cos(frameAngle) -sin(frameAngle); sin(frameAngle) cos(frameAngle)];
   wTb = [1 0; 0 -1];
   uodomVal = (wTb*bTr*rTs*fmes);
endfunction
