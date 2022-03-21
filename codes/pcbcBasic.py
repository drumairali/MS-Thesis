import numpy as np
import matplotlib.pyplot as plt

# Function for Encoding
def  G1D(rangeX,c,sigma,A):
    return A * np.exp(-(0.5/sigma**2)*(rangeX-c)**2)
#Function for Decoding
def decode(z,rangeX):
    return np.sum(z*rangeX)/np.sum(z)

c = 5
sigm = 0.2
A = 1

rangeX = np.linspace(1,10,100)
centers = np.array([1.5])
W=np.zeros([len(centers),len(rangeX)])
for iw in range(len(centers)):
    WG1D = G1D(rangeX,centers[iw],sigm,A).T
    W[iw,:]=WG1D

V = (W/np.max(W)).T
#n is number of rows and m is number of columns of W
[n,m]=W.shape
# initialze y with zeros of centers' size 

#for pcbc filter some small values
epsilon1=1e-6;
epsilon2=1e-4;

for cen in np.linspace(1,10,20):
    x_new = G1D(rangeX,cen,sigm,1.2)
    y=np.zeros([n,1]);
    for i in range(30):
        r=np.dot(V,y)
        e=np.expand_dims(x_new, axis=1)/(epsilon2+r) #dimention added in x[:,xyz]
        y=(epsilon1+y)*np.dot(W,e)
        
        
    plt.plot(rangeX,x_new)
    plt.plot(rangeX,W.T)
    plt.plot(rangeX,r)
    plt.title(f"out:power={sum(r)}, input position {c}")
    plt.legend(["input","w1","w2","w3","reconstructed output"])
    plt.show()
    