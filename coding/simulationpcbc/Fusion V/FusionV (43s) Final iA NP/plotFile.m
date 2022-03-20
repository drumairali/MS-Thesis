

allDgps=dgpsData(:,1:4)';
allPCBCDIM=globalTraj';
###ploting

allUsbl=usblData(:,1:4)';
gtData = gtData';

 figure(2) #BPRF
  hold on;
  title("B-PR-F Neural Network");    
  
  plot3 (gtData(2,:), gtData(3,:), gtData(4,:), 'g',"LineWidth", 1);
  if size(allDgps,2) > 0
    plot3 (allDgps(2,:), allDgps(3,:), allDgps(4,:), 'ok',"LineWidth", 2);
  endif
  if size(allUsbl,2) > 0
    plot3 (allUsbl(2,:), allUsbl(3,:), allUsbl(4,:), '.k',"LineWidth", 2);
  endif
  
  n = size(allB_PR_F_Mus,2);
  p = c = allB_PR_F_Mus(:,1);
  i = 1;
  flag = 1;
  while i<n
    while c(end) == p(end) && i<n
      c = allB_PR_F_Mus(:,i);
      i = i + 1;
    endwhile
    if p(end) == 1
        plot3 (allB_PR_F_Mus(2,flag:i-1), allB_PR_F_Mus(3,flag:i-1), allB_PR_F_Mus(4,flag:i-1), 'b',"LineWidth", 1);
    else
        plot3 (allB_PR_F_Mus(2,flag:i-1), allB_PR_F_Mus(3,flag:i-1), allB_PR_F_Mus(4,flag:i-1), 'r',"LineWidth", 1);
    endif
    flag = i;
    p = c;
  endwhile
  if p(end) == 1
      plot3 (allB_PR_F_Mus(2,flag-1:flag), allB_PR_F_Mus(3,flag-1:flag), allB_PR_F_Mus(4,flag-1:flag), 'b',"LineWidth", 1);
  else
      plot3 (allB_PR_F_Mus(2,flag-1:flag), allB_PR_F_Mus(3,flag-1:flag), allB_PR_F_Mus(4,flag-1:flag), 'r',"LineWidth", 1);
  endif
  
  v = [-40,35];
set(gca, "linewidth", 2, "fontsize", 20)
  legend("GT", "DGPS", "USBL","Behavour1", "Behavour2");
  view(v);
hold off
 
figure(1) # PCBC-DIM

  hold on;
  title("PC/BC-DIM Neural Network");    
  
  plot3 (gtData(2,:), gtData(3,:), gtData(4,:), 'g',"LineWidth", 1);
  if size(allDgps,2) > 0
    plot3 (allDgps(2,:), allDgps(3,:), allDgps(4,:), 'ok',"LineWidth", 2);
  endif
  if size(allUsbl,2) > 0
    plot3 (allUsbl(2,:), allUsbl(3,:), allUsbl(4,:), '.k',"LineWidth", 1);
  endif
  
  plot3 (allPCBCDIM(2,:), allPCBCDIM(3,:), allPCBCDIM(4,:), 'b',"LineWidth", 2);
   
  
  v = [-40,35];
set(gca, "linewidth", 2, "fontsize", 20)
  legend("GT", "DGPS", "USBL","PC/BC-DIM");
  view(v);
hold off
hold off
  
  
   
  figure(3);
  hold on;
  title("Time evolution of RMS error");
  gtData = gtData(:,1:end);
  err1 =  allB_PR_F_Mus(2:4,1:6299) - gtData(2:4,1:6299);
  err1 = (sum((err1.*err1),1)/3).^0.5;
  plot(gtData(1,1:6299), err1(1,1:6299), "r");  

  
  meanError = mean(err1);
  stdError = std(err1);
  display(strcat("BPRF RMS error: ", num2str(meanError)));
  display(strcat("BPRF stdev error: : ", num2str(stdError)));
  
  err1 =  allPCBCDIM(2:4,1:6299) - gtData(2:4,1:6299);
  err1 = (sum((err1.*err1),1)/3).^0.5;
  plot(gtData(1,1:6299), err1(1,1:6299), "b");  
  xlabel("Time in sec");
  ylabel("Error in m");
  
  meanError = mean(err1);
  stdError = std(err1);
  display(strcat("PCBC RMS error: ", num2str(meanError)));
  display(strcat("PCBC stdev error: : ", num2str(stdError)));
  legend("B-PR-F", "PC/BC-DIM");
 set(gca, "linewidth", 2, "fontsize", 20)

hold off




figure(5)
plot(gtData(4,:))
hold on
plot(allPCBCDIM(4,:),"LineWidth", 1)
set(gca, "linewidth", 2, "fontsize", 20)
legend("GT", "PC/BC-DIM");

hold off

figure(6)
plot(gtData(4,:))
hold on
plot(allB_PR_F_Mus(4,:),"LineWidth", 1)
set(gca, "linewidth", 2, "fontsize", 20)
 legend("GT", "B-PR-F");

hold off

