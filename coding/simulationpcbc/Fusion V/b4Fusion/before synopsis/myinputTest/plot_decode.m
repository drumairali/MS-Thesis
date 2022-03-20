function plot_decode(z,s,expon,labelSigma)
%add label to plot to indicate mean of distribution

if nargin<3 || isempty(expon), expon=[]; end
if isunimodal(z) %only do so if distibution is unimodal (mean is meaningless otherwise)

  [mu,var]=decode(z',s,expon);
  muposn=1+((mu-min(s)).*(length(s)-1)./(max(s)-min(s)));
  hold on
  plot(muposn.*[1,1],[0,100],'k-'),
  plot(muposn.*[1,1],[0,100],'w--'),
  ax=axis;
  if nargin>3 && labelSigma
    text('Position',[muposn,ax(4)*0.97],'String',[num2str(mu,'%+3.1f\n'),' (',num2str(sqrt(var),'%3.1f\n'),')'],'HorizontalAlignment','center','VerticalAlignment','Bottom','FontWeight','bold','FontSize',18);
  else
    text('Position',[muposn,ax(4)*0.97],'String',[num2str(mu,'%+3.1f\n')],'HorizontalAlignment','center','VerticalAlignment','Bottom','FontWeight','bold','FontSize',18);
  end
end


function val=isunimodal(z)
zleft=[0;z(1:end-1)];
zright=[z(2:end);0];
peaks=min(z-zleft,z-zright); %nonnegative only for values bigger than both neightbours
sup=peaks<0;
z(sup)=0;

posn=find(z>0.05.*max(z));

if length(posn)==0
  val=0;
else
  if length(posn)==1 || posn(end)-posn(1)<3
    val=1;
  else
    val=0;
  end
end