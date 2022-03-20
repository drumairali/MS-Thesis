#prints
hold on
subplot(2,2,1)
plot(WIMU,"LineWidth", 2)
set(gca, "linewidth", 1, "fontsize", 20)

subplot(2,2,2)
plot(WDVL,"LineWidth", 2)
set(gca, "linewidth", 1, "fontsize", 20)

subplot(2,2,3)
plot(WUSBL,"LineWidth", 2)
set(gca, "linewidth", 1, "fontsize", 20)

subplot(2,2,4)
plot(WDGPS,"LineWidth", 2)
set(gca, "linewidth", 1, "fontsize", 20)

hold off