 plot3(Xdvl(1:end,2),Xdvl(1:end,3),Xdvl(1:end,4),'-')
hold on

plot3(dgpsData(1:end,2),dgpsData(1:end,3),dgpsData(1:end,4),'o')

plot3(gtData(1:end,2),gtData(1:end,3),gtData(1:end,4),'o')
hold off