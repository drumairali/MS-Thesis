#prints
figure(1)
hold on
subplot(2,2,1)
plot(range,xIMU(2,:),"LineWidth", 2)
set(gca, "linewidth", 1, "fontsize", 20)

subplot(2,2,2)
plot(range,xDVL(2,:),"LineWidth", 2)
set(gca, "linewidth", 1, "fontsize", 20)

subplot(2,2,3)
plot(range,xUSBL(2,:),"LineWidth", 2)
set(gca, "linewidth", 1, "fontsize", 20)

subplot(2,2,4)
plot(range,xDGPS(2,:),"LineWidth", 2)
set(gca, "linewidth", 1, "fontsize", 20)

hold off

