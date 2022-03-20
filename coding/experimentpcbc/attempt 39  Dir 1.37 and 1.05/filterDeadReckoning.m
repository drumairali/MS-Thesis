
ns = 3; 
### Kalman filter: theta estimate
global ns1 = 1; % theta

sigmaCompass = [0.02]*(pi/180); % deg
sigmaThetaODOM = [0.7]*(pi/180); % deg

global R1 = eye(ns1)*sigmaCompass; %; observation noise covariance 
global Q1 = eye(ns1)*sigmaThetaODOM; %; process noise covariance 

global F1 = eye(ns1); % transition state model
global B1 = eye(ns1); % control input model
global H1 = eye(ns1); % observation model
global P1 = R1;

global x1 = 0;

global muOdom = zeros(1,ns); 

### data containers 

global allDeadReckoning = [];
global allUsbl = [];
global allDgps = [];
global allCompass  = [];

### Filter interface functions 

function filterInfo()
  display("filter Dead Reckoning loaded!");
  fflush(stdout);
endfunction
  
  
function filterInitialize(mu, theta)
    
  muOdom = [mu(2:3) 0]';
  x1 = theta;

endfunction


function filterReadCompass(measurement)

  global H1 P1 R1 x1 ns1 allCompass;   

    % correction step filter 1
    theta = measurement(2);
    z1 = theta;
    y1 = z1 - H1*x1;
    S1 = H1*P1*H1' + R1;
    K1 = P1*H1'*inv(S1);
    x1 = x1 + K1*y1;
    P1 = (eye(ns1)-K1*H1)*P1;
    allCompass = [allCompass ; measurement];

endfunction

function dX= filterReadOdometry(measurement)
       
    global x1 F1 B1 P1 Q1 muOdom allDeadReckoning;   
    
    tOdom = measurement(1);
    mes = measurement(2:3)';    
    dTheta  = measurement(4);
    
    angle = wrapTo2Pi(x1);
    bTr = [cos(angle) -sin(angle); sin(angle) cos(angle)];
    frameAngle = pi/2;
    rTs = [cos(frameAngle) -sin(frameAngle); sin(frameAngle) cos(frameAngle)];
    wTb = [1 0; 0 -1];
    dX = (wTb*bTr*rTs*mes)';
           
    %prediction step filter 1
    u1 = [dTheta];
    x1 = F1*x1 + B1*u1;
    P1 = F1*P1*F1' + Q1; % predicted covariance          
    
endfunction


