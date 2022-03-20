function plot_result2(x,r,y,expon,inputs,centres)
xA=x(1:length(inputs));
xB=x(length(inputs)+[1:length(inputs)]);
rA=r(1:length(inputs));
rB=r(length(inputs)+[1:length(inputs)]);
top=1.05;

axes('Position',[0.12,0.05,0.37,0.24]),
bar(xA,1,'k'),axis([0.5,length(xA)+0.5,0,top])
set(gca,'XTick',[1:9:length(xA)-1],'XTickLabel',inputs(1:9:length(xA)-1),'FontSize',18);
plot_decode(xA,inputs);
text(0.02,1,'x_a','Units','normalized','color','k','FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.51,0.05,0.37,0.24]),
bar(xB,1,'k'),axis([0.5,length(xB)+0.5,0,top])
set(gca,'YTick',[],'XTick',[1:9:length(xB)-1],'XTickLabel',inputs(1:9:length(xB)-1),'FontSize',18);
plot_decode(xB,inputs);
text(0.02,1,'x_b','Units','normalized','color','k','FontSize',18,'FontWeight','bold','VerticalAlignment','top')


axes('Position',[0.12,0.38,0.76,0.24]),
bar(y,1,'r'),axis([0.5,length(y)+0.5,0,top])
set(gca,'XTick',[2:4:length(y)-1],'XTickLabel',[2:4:length(y)-1],'FontSize',18);
text(0.01,1,'y','Units','normalized','color','r','FontSize',18,'FontWeight','bold','VerticalAlignment','top')


axes('Position',[0.12,0.71,0.37,0.24]),
bar(rA.^2,1,'FaceColor',[0,0.7,0]),axis([0.5,length(rA)+0.5,0,top])
set(gca,'XTick',[1:9:length(xA)-1],'XTickLabel',inputs(1:9:length(xA)-1),'FontSize',18);
plot_decode(rA,inputs,expon);
text(0.02,0.94,'r_a^2','Units','normalized','color',[0,0.7,0],'FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.51,0.71,0.37,0.24]),
bar(rB.^2,1,'FaceColor',[0,0.7,0]),axis([0.5,length(rB)+0.5,0,top])
set(gca,'YTick',[],'XTick',[1:9:length(xB)-1],'XTickLabel',inputs(1:9:length(xB)-1),'FontSize',18);
plot_decode(rB,inputs,expon);
text(0.02,0.94,'r_b^2','Units','normalized','color',[0,0.7,0],'FontSize',18,'FontWeight','bold','VerticalAlignment','top')

set(gcf,'PaperSize',[18 16],'PaperPosition',[0 0.5 18 15],'PaperOrientation','Portrait');

