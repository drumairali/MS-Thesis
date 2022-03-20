clear 
clc
t = linspace(0,2.*pi,100)';
dt = t(2) - t(1);

x = 2*cos(t);
y = sin(2*t);

gps_sig = 0.1;

# noisy measurements
x_gps = x + gps_sig .* randn(length(x),1);
y_gps = y + gps_sig .* randn(length(y),1);

figure(1)
plot(x,y)
hold on 
plot(x(1),y(1),".o","LineWidth", 7)
legend("actual path","starting point")
title("here is the actual trajectory with starting point")
hold off

figure(2)
plot(x,y)
hold on 
plot(x(1),y(1),".o","LineWidth", 7)
plot(x_gps,y_gps,"o")
legend("actual path","starting point","GPS points")
title("Actual trajectory with starting points and gps")
hold off


