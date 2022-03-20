function plot_result4(x,r,y,integrate,Ainputs,Binputs,Cinputs,Dinputs,ysplit)
xA=x(1:length(Ainputs));
xB=x(length(Ainputs)+[1:length(Binputs)]);
xC=x(length(Ainputs)+length(Binputs)+[1:length(Cinputs)]);
xD=x(length(Ainputs)+length(Binputs)+length(Cinputs)+[1:length(Dinputs)]);
rA=r(1:length(Ainputs));
rB=r(length(Ainputs)+[1:length(Binputs)]);
rC=r(length(Ainputs)+length(Binputs)+[1:length(Cinputs)]);
rD=r(length(Ainputs)+length(Binputs)+length(Cinputs)+[1:length(Dinputs)]);
top=1.05;

axes('Position',[0.12,0.05,0.18,0.24]),
bar(xA,1,'k'),axis([0.5,length(xA)+0.5,0,top])
set(gca,'XTick',[4:9:length(xA)-3],'XTickLabel',Ainputs(4:9:length(xA)-3),'FontSize',18);
plot_decode(xA,Ainputs,integrate);
text(0.04,1,'x_a','Units','normalized','color','k','FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.3133,0.05,0.18,0.24]),
bar(xB,1,'k'),axis([0.5,length(xB)+0.5,0,top])
set(gca,'YTick',[],'XTick',[4:9:length(xB)-3],'XTickLabel',Binputs(4:9:length(xB)-3),'FontSize',18);
plot_decode(xB,Binputs,integrate);
text(0.04,1,'x_b','Units','normalized','color','k','FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.5066,0.05,0.18,0.24]),
bar(xC,1,'k'),axis([0.5,length(xC)+0.5,0,top])
set(gca,'YTick',[],'XTick',[4:9:length(xC)-3],'XTickLabel',Cinputs(4:9:length(xC)-3),'FontSize',18);
plot_decode(xC,Cinputs,integrate);
text(0.04,1,'x_c','Units','normalized','color','k','FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.70,0.05,0.18,0.24]),
bar(xD,1,'k'),axis([0.5,length(xD)+0.5,0,top])
set(gca,'YTick',[],'XTick',[7:12:length(xD)-6],'XTickLabel',Dinputs(7:12:length(xD)-6),'FontSize',18);
plot_decode(xD,Dinputs,integrate);
text(0.04,1,'x_d','Units','normalized','color','k','FontSize',18,'FontWeight','bold','VerticalAlignment','top')

top=0.1;
if nargin>8 && ysplit
  %top=max(max(y{1}),max(y{2}));
  axes('Position',[0.12,0.38,0.37,0.24]),
  bar(y{1},1,'r'),axis([0.5,length(y{1})+0.5,0,top])
  set(gca,'YTick',[0,0.1],'FontSize',18);
  text(0.02,1,'y^{S1}','Units','normalized','color','r','FontSize',18,'FontWeight','bold','VerticalAlignment','top')
  axes('Position',[0.51,0.38,0.37,0.24]),
  bar(y{2},1,'r'),axis([0.5,length(y{2})+0.5,0,top])
  set(gca,'YTick',[],'FontSize',18);
  text(0.02,1,'y^{S2}','Units','normalized','color','r','FontSize',18,'FontWeight','bold','VerticalAlignment','top')
else
  axes('Position',[0.12,0.38,0.76,0.24]),
  bar(y,1,'r'),axis([0.5,length(y)+0.5,0,top])
  set(gca,'YTick',[0,0.1],'XTick',[2000:4000:14000],'FontSize',18);
  text(0.01,1,'y','Units','normalized','color','r','FontSize',18,'FontWeight','bold','VerticalAlignment','top')
end

top=1.05*max(r); 
axes('Position',[0.12,0.71,0.18,0.24]),
bar(rA,1,'FaceColor',[0,0.7,0]),axis([0.5,length(rA)+0.5,0,top])
set(gca,'XTick',[4:9:length(xA)-3],'XTickLabel',Ainputs(4:9:length(xA)-3),'FontSize',18);
plot_decode(rA,Ainputs,integrate);
text(0.04,1,'r_a','Units','normalized','color',[0,0.7,0],'FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.3133,0.71,0.18,0.24]),
bar(rB,1,'FaceColor',[0,0.7,0]),axis([0.5,length(rB)+0.5,0,top])
set(gca,'YTick',[],'XTick',[4:9:length(xB)-3],'XTickLabel',Binputs(4:9:length(xB)-3),'FontSize',18);
plot_decode(rB,Binputs,integrate);
text(0.04,1,'r_b','Units','normalized','color',[0,0.7,0],'FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.5066,0.71,0.18,0.24]),
bar(rC,1,'FaceColor',[0,0.7,0]),axis([0.5,length(rC)+0.5,0,top])
set(gca,'YTick',[],'XTick',[4:9:length(xC)-3],'XTickLabel',Cinputs(4:9:length(xC)-3),'FontSize',18);
plot_decode(rC,Cinputs,integrate);
text(0.04,1,'r_c','Units','normalized','color',[0,0.7,0],'FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.70,0.71,0.18,0.24]),
bar(rD,1,'FaceColor',[0,0.7,0]),axis([0.5,length(rD)+0.5,0,top])
set(gca,'YTick',[],'XTick',[7:12:length(xD)-6],'XTickLabel',Dinputs(7:12:length(xD)-6),'FontSize',18);
plot_decode(rD,Dinputs,integrate);
text(0.04,1,'r_d','Units','normalized','color',[0,0.7,0],'FontSize',18,'FontWeight','bold','VerticalAlignment','top')

set(gcf,'PaperSize',[18 16],'PaperPosition',[0 0.5 18 15],'PaperOrientation','Portrait');


