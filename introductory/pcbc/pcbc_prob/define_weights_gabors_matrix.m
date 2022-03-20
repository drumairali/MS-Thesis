function [W,V]=define_weights_gabors_matrix(imSize,angles,prior)

%define weights
disp('defining synaptic weights');
sigma=4;
wavel=1.5*sigma;
aspect=1./sqrt(2);
filter_angles=[0:22.5:179];%[0:11.25:179];
Wa=zeros(50000,2*imSize^2,'single');
Wb=zeros(50000,length(angles),'single');
Va=zeros(50000,2*imSize^2,'single');
Vb=zeros(50000,length(angles),'single');
k=0;
for i=1:2:imSize
  for j=1:2:imSize
    for phase=0:90:270
      for angletmp=filter_angles
        k=k+1;
        angle=angletmp+(22.5*rand-11.5); %jitter angle
        if rem(k,1000)==0; fprintf(1,'.%i.',k); end
        gabor=gabor2D(sigma,angle,aspect,wavel,phase,imSize,i-floor(imSize/2)+0.5*randn,j-floor(imSize/2)+0.5*randn); %define gabor - jitter orientation and position
        gabor=single(gabor(:)'./sum(sum(abs(gabor))));
        gaborON=gabor; gaborON(gaborON<0)=0; 
        gaborOFF=-gabor; gaborOFF(gaborOFF<0)=0; 
        Wa(k,:)=[gaborON,gaborOFF];
        Va(k,:)=Wa(k,:)./max(Wa(k,:));
        Wb(k,:)=0.3.*code(angle,angles,10,0,1).*prior;
        Vb(k,:)=0.1.*(Wb(k,:)./max(Wb(k,:)));
      end
    end
  end
end
disp(' ')
W=[Wa,Wb];
W=W(1:k,:);
V=[Va,Vb];
V=V(1:k,:);
