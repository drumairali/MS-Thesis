load 'usblData.mat'
%load 'dgpsData.mat' no overlaping data
%load 'gtData.mat' ground truth
load 'imuData.mat'
load 'dvlData.mat'

% imu and dvl has same instanses in simulations
% usbl has somewhere same instanses after 13 secs approx
AA = [0.1 2 3 4]
imu = imuData;
usbl = [usblData; AA] 
usblins = [];
% to find the same instances of usbl
j=1; %for usbl
zer=[];
val=[];
for i = 1:6301
  
  if (usbl(j,1) != imu(i,1))
   zerr = [i];
   zer = [zer;zerr];
   else
 vall = [i];
  val = [val;vall];
  j = j + 1;
  
 
end


endfor
i=1;
j=1;
 usblint = zeros(6301,4);
for i = 1:6301
  if (i==val(j))
    usblint(i,1:4) = usbl(j,1:4);
    j=j+1
   else 
  usblint(i,1:4) = [imu(i,1) 0 0 0];
  end
  
  endfor

