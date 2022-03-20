% second minimum
bigVal = 100000000;
inputtt = [1 2 3 4 5 6 7 8 9 10 -10]
O = inputtt
[A1,B1]=min(O)
O(B1) = bigVal;

[A2,B2] = min(O)
O(B2) = bigVal;

[A3,B3] = min(O)
O(B3) = bigVal;

[A4,B4] = min(O)
O(B4) = bigVal;
