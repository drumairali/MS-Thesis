load("data/usblData.mat");
x=usblData(:,2);
range=[-20:0.1:20]
[xdiff] = findchange(x);
sorted=sort(xdiff);
average=mean(xdiff);
sigma=std(xdiff);
plot(sorted,'o')