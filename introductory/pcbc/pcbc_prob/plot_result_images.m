function plot_result_images(x,r,y,expon,imSize,angles,W)
xIm=x(1:imSize^2)-x(imSize^2+[1:imSize^2]);
rIm=r(1:imSize^2)-r(imSize^2+[1:imSize^2]);
xCl=x(1+2*imSize^2:end);
rCl=r(1+2*imSize^2:end);
top=1.05;

axes('Position',[0.12,0.05,0.37,0.24]),
imagesc(reshape(xIm,[imSize,imSize])',[-1,1]),axis('equal','tight','on')
set(gca,'YTick',[],'XTick',[],'FontSize',18);
text(0.04,1,'x_a','Units','normalized','color','k','FontSize',18,'FontWeight','bold','VerticalAlignment','top')

axes('Position',[0.51,0.05,0.37,0.24]),
bar(xCl,1,'k'),axis([0.5,length(xCl)+0.5,0,top])
tolabel=[1:9:length(angles)];
set(gca,'XTick',tolabel,'XTickLabel',angles(tolabel),'FontSize',18);
plot_decode(xCl,angles);
text(0.02,1,'x_b','Units','normalized','color','k','FontSize',18,'FontWeight','bold','VerticalAlignment','top')


top=0.4; %double(max(0.1,max(y)));
axes('Position',[0.12,0.38,0.76,0.24]),
plot(y,'r'),axis([0.5,length(y)+0.5,0,top])
last=floor(length(y)/1000)*1000;step=floor(floor(last/5)/1000)*1000;
set(gca,'XTick',[step:step:last],'XTickLabel',int2str([step:step:last]'),'YTick',[0:0.1:1],'FontSize',18);
hold on
text(0.01,1,'y','Units','normalized','color','r','FontSize',18,'FontWeight','bold','VerticalAlignment','top');
[m,ind]=sort(y,'descend');
numToLabel=min(10,length(find(m>0.5*m(1))));
for i=1:numToLabel, 
  axes('Position',[0.12+0.76.*(ind(i)-1)./length(y)-0.03755,0.373+0.253*min(1,m(i)/top),0.075,0.075])
  imagesc(reshape(W(ind(i),1:imSize^2)-W(ind(i),imSize^2+[1:imSize^2]),[imSize,imSize])'),axis('equal','tight','off')
end


axes('Position',[0.12,0.71,0.37,0.24]),
imagesc(reshape(rIm,[imSize,imSize])',[-1,1].*0.75),axis('equal','tight','on')
set(gca,'YTick',[],'XTick',[],'FontSize',18);
text(0.04,1,'r_a','Units','normalized','color',[0,0.7,0],'FontSize',18,'FontWeight','bold','VerticalAlignment','top')

top=max(max(r)*1.05,1.05);
axes('Position',[0.51,0.71,0.37,0.24]),
bar(rCl,1,'FaceColor',[0,0.7,0]),axis([0.5,length(rCl)+0.5,0,top])
set(gca,'XTick',tolabel,'XTickLabel',angles(tolabel),'FontSize',18);
plot_decode(rCl,angles,expon);
text(0.02,1,'r_b','Units','normalized','color',[0,0.7,0],'FontSize',18,'FontWeight','bold','VerticalAlignment','top')

cmap=colormap('gray');cmap=1-cmap;colormap(cmap);

set(gcf,'PaperSize',[18 16],'PaperPosition',[0 0.5 18 15],'PaperOrientation','Portrait');
