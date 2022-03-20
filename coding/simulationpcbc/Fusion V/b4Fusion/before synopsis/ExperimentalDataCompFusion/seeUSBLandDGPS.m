load "dgpsData.mat"
load "usblData.mat"
dg = dgpsData;
us = usblData;
scatter(dg(1:end,2),dg(1:end,3))
hold on
scatter(us(1:end,2),us(1:end,3))
hold off