function plot_result1(x,r,y,inputs,centres,label,top)
if nargin<6, label=1; end
if nargin<7 || isempty(top), top=1.05; end
tolabel=[1:18:length(x)-1];

axes('Position',[0.12,0.05,0.76,0.24]),
bar(x,1,'k'),axis([0.5,length(x)+0.5,0,top])
set(gca,'XTick',tolabel,'XTickLabel',inputs(tolabel),'FontSize',18);
if label, plot_decode(x,inputs); end
text(0.01,1,'x','Units','normalized','color','k','FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.12,0.38,0.76,0.24]),
bar(y,1,'r'),axis([0.5,length(y)+0.5,0,top])
set(gca,'FontSize',18);
text(0.01,1,'y','Units','normalized','color','r','FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.12,0.71,0.76,0.24]),
bar(r,1,'FaceColor',[0,0.7,0]),axis([0.5,length(x)+0.5,0,top])
set(gca,'XTick',tolabel,'XTickLabel',inputs(tolabel),'FontSize',18);
if label, plot_decode(r,inputs); end
text(0.01,1,'r','Units','normalized','color',[0,0.7,0],'FontSize',18,'FontWeight','bold','VerticalAlignment','top')

set(gcf,'PaperSize',[18 16],'PaperPosition',[0 0.5 18 15],'PaperOrientation','Portrait');

