function plot_result3(x,r,y,expon,Ainputs,Binputs,Rinputs)
xA=x(1:length(Ainputs));
xB=x(length(Ainputs)+[1:length(Binputs)]);
xR=x(length(Ainputs)+length(Binputs)+[1:length(Rinputs)]);
rA=r(1:length(Ainputs));
rB=r(length(Ainputs)+[1:length(Binputs)]);
rR=r(length(Ainputs)+length(Binputs)+[1:length(Rinputs)]);
top=1.05;

tolabel=[7:12:length(Ainputs)];
axes('Position',[0.12,0.05,0.24,0.24]),
bar(xA,1,'k'),axis([0.5,length(xA)+0.5,0,top])
set(gca,'XTick',tolabel,'XTickLabel',Ainputs(tolabel),'FontSize',18);
plot_decode(xA,Ainputs);
text(0.03,1,'x_a','Units','normalized','color','k','FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.38,0.05,0.24,0.24]),
bar(xB,1,'k'),axis([0.5,length(xB)+0.5,0,top])
set(gca,'YTick',[],'XTick',tolabel,'XTickLabel',Binputs(tolabel),'FontSize',18);
plot_decode(xB,Binputs);
text(0.03,1,'x_b','Units','normalized','color','k','FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.64,0.05,0.24,0.24]),
bar(xR,1,'k'),axis([0.5,length(xR)+0.5,0,top])
set(gca,'YTick',[],'XTick',tolabel,'XTickLabel',Rinputs(tolabel),'FontSize',18);
plot_decode(xR,Rinputs);
text(0.03,1,'x_c','Units','normalized','color','k','FontSize',18,'FontWeight','bold','VerticalAlignment','top')


axes('Position',[0.12,0.38,0.76,0.24]),
bar(y,1,'r'),axis([0.5,length(y)+0.5,0,0.1])
set(gca,'YTick',[0,0.1],'FontSize',18);
text(0.01,1,'y','Units','normalized','color','r','FontSize',18,'FontWeight','bold','VerticalAlignment','top')


labelVar=0;
top=1.05;
axes('Position',[0.12,0.71,0.24,0.24]),
bar(rA,1,'FaceColor',[0,0.7,0]),axis([0.5,length(rA)+0.5,0,top])
set(gca,'XTick',tolabel,'XTickLabel',Ainputs(tolabel),'FontSize',18);
plot_decode(rA,Ainputs,expon,labelVar);
text(0.03,1,'r_a','Units','normalized','color',[0,0.7,0],'FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.38,0.71,0.24,0.24]),
bar(rB,1,'FaceColor',[0,0.7,0]),axis([0.5,length(rB)+0.5,0,top])
set(gca,'YTick',[],'XTick',tolabel,'XTickLabel',Binputs(tolabel),'FontSize',18);
plot_decode(rB,Binputs,expon,labelVar);
text(0.03,1,'r_b','Units','normalized','color',[0,0.7,0],'FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.64,0.71,0.24,0.24]),
bar(rR,1,'FaceColor',[0,0.7,0]),axis([0.5,length(rR)+0.5,0,top])
set(gca,'YTick',[],'XTick',tolabel,'XTickLabel',Rinputs(tolabel),'FontSize',18);
plot_decode(rR,Rinputs,expon,labelVar);
text(0.03,1,'r_c','Units','normalized','color',[0,0.7,0],'FontSize',18,'FontWeight','bold','VerticalAlignment','top')

set(gcf,'PaperSize',[18 16],'PaperPosition',[0 0.5 18 15],'PaperOrientation','Portrait');


