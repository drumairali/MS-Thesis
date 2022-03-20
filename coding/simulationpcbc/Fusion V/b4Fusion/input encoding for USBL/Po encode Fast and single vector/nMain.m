load "usblData.mat"

global x = usblData(1:end,2);
global y = usblData(1:end,3);
global slen;

[slen,extra]=size(x);

global starting_value_range =-200;
global differ=10;
global ending_value_range =200;
global sigma=10;
global centers = [starting_value_range:differ:ending_value_range];

i=1
global X_input=x(i);
global Y_input=y(i);

global inx;
global iny;

instGaussSurf(starting_value_range, differ, ending_value_range, centers,sigma,X_input,Y_input)




