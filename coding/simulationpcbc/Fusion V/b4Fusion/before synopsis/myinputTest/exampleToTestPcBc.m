function exampleToTestPcBc()

W=[0.29     0.15      0.34
   0.17     0.25      0.33
   0.92     0.81      0.79 ]


D=[1    0   1
   0    0   1
   1    1   0];


x=[0.48 0.77 0.4]'

[y,e]=dim_activation(W,x)



Ww=[W D']


xx=[x;0;0;0]

[yy,ee]=dim_activation(Ww,xx)

W=[2 1; 1 2]
in=[2 1]
[yyy,eee]=dim_activation(W,2)

W3=[1 1 1; 1 1 1; 1 1 1]
x3=[1 1 1]
[y3,e3]=dim_activation(W3,x3)


W3=[1 1 1; 1 1 1; 1 1 1]
x3=[1 1 1]
[y3,e3]=dim_activation(W3,x3)
