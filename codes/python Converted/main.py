# -*- coding: utf-8 -*-
"""
Created on Fri Mar 27 02:06:19 2020

@author: umairali
"""
import pandas as pd
import numpy as np
from mpl_toolkits import mplot3d
import matplotlib.pyplot as plt
import time

# Function for Encoding
def  G1D(rangeX,c,sigma,Az):
    return np.exp(-(0.5/sigma**2)*(rangeX-c)**2)
#Function for Decoding
def decode(z,rangeX):
    return np.sum(z*rangeX)/np.sum(z)


###Loading of
# Groud trith data
data = pd.read_csv('data/gtData.mat', sep=" ", header=0)
data.columns = ["","t","x","y","z"]
gtData = data[['t','x','y','z']].to_numpy()

#USBL data
data = pd.read_csv('data/usblData.mat', sep=" ", header=0)
data.columns = ["","t","x","y","z"]
usblData = data[['t','x','y','z']].to_numpy()

#DGPS data
data = pd.read_csv('data/dgpsData.mat', sep=" ", header=0)
data.columns = ["","t","x","y","z"]
dgpsData = data[['t','x','y','z']].to_numpy()

#DVL data
data = pd.read_csv('data/imuData.mat', sep=" ", header=0)
data.columns = ["","t","x","y","z"]
imuData = data[['t','x','y','z']].to_numpy()

#IMU data
data = pd.read_csv('data/dvlData.mat', sep=" ", header=0)
data.columns = ["","t","x","y","z"]
dvlData = data[['t','x','y','z']].to_numpy()


# adding non-Gaussian Noise to the USBL sensor x and y
usblData[10,2:4] = [-150, -100];
usblData[20,2:4] = [-150, -100];
usblData[40,2:4] = [-150, -100];
usblData[60,2:4] = [-150, -100];
usblData[80,2:4] = [-150, -100];
usblData[100,2:4] = [-150, -100];
usblData[120,2:4] = [-150, -100];
usblData[140,2:4] = [-150, -100]; 


rangeX=np.arange(-40, 41, 5, dtype=float)
rangeX = np.expand_dims(rangeX, axis=0).T

centers=np.arange(-40, 41, 10, dtype=float)
centers = np.expand_dims(centers, axis=0).T


iterations=10; #iterations of PCBC
#setting the applitude and gaussian span for each sensor
AIMU=1;
sigmaIMU=1;
ADVL=1;
sigmaDVL=5;
AUSBL=1;
sigmaUSBL=5;
ADGPS=1;
sigmaDGPS=5;

# weights for each sensor

#Weights for inertial measurment units
WIMU=np.zeros([len(centers),len(rangeX)])
for iw in range(len(centers)):
    WG1D = G1D(rangeX,centers[iw],sigmaIMU,AIMU).T
    WIMU[iw,:]=WG1D

#Weights for Doppler velocity log
WDVL=np.zeros([len(centers),len(rangeX)])
for iw in range(len(centers)):
    WG1D = G1D(rangeX,centers[iw],sigmaDVL,ADVL).T
    WDVL[iw,:]=WG1D

#Weights for ultrashot baseline
WUSBL=np.zeros([len(centers),len(rangeX)])
for iw in range(len(centers)):
    WG1D = G1D(rangeX,centers[iw],sigmaUSBL,AUSBL).T
    WUSBL[iw,:]=WG1D

#Weights for Differental Global positioning system
WDGPS=np.zeros([len(centers),len(rangeX)])
for iw in range(len(centers)):
    WG1D = G1D(rangeX,centers[iw],sigmaDGPS,ADGPS).T
    WDGPS[iw,:]=WG1D

#make one matrix of all sensor weights in column 
W=np.concatenate((WIMU,WDVL,WUSBL,WDGPS),axis =1)

# make a normalized transpose of W
V = (W/np.max(W)).T

#n is number of rows and m is number of columns of W
[n,m]=W.shape

# initialze y with zeros of centers' size 
y=np.zeros([n,1]);

#for pcbc filter some small values
epsilon1=1e-6;
epsilon2=1e-4;

# current row value of each sensor 
iImu=0
iDvl=0
iUsbl=0 
iDgps=0

#current time of each sensor value
t=imuData[0,0]
tImu=imuData[0,0]
tDvl=dvlData[0,0]
tUsbl=usblData[0,0]
tDGPS=dgpsData[0,0]

#initialize sensor values for position on origin (0,0,0)
gXIMU=gYIMU=gZIMU=0.0 #never initialze array like this
gXDVL=gYDVL=gZDVL=0.0
globalTrajvar=np.array([0.0, 0.0, 0.0])
comingVal=np.array([0.0, 0.0, 0.0])
globalTrajvar = np.expand_dims(globalTrajvar, axis=0)
comingVal = np.expand_dims(comingVal, axis=0)
lastDgps=np.array([0.0, 0.0, 0.0]) 
lastUsbl=np.array([0.0, 0.0, 0.0])
lastDgps = np.expand_dims(lastDgps, axis=0)
lastUsbl = np.expand_dims(lastUsbl, axis=0)
globalTraj={}

#to measure time of filter
start_time = time.time()

# sensory values initialize with 
axis =3
xIMU=xDVL=xUSBL=xDGPS=np.zeros([3,len(rangeX)])


#Read sensory data process from pcbc filter and store in trajectory
for val in range(len(imuData)):
    #if imuData available then store it
    if tImu<=t and iImu<len(imuData)-1: #indexing starts from 0 so ... -1 from data
        gXIMU = gXIMU + imuData[iImu,1]
        gYIMU = gYIMU + imuData[iImu,2]
        gZIMU = gZIMU + imuData[iImu,3]
        xIMU[0,] = G1D(rangeX,gXIMU,sigmaIMU,AIMU).T 
        xIMU[1,] = G1D(rangeX,gYIMU,sigmaIMU,AIMU).T
        xIMU[2,] = G1D(rangeX,gZIMU,sigmaIMU,AIMU).T
        tImu=imuData[iImu+1,0]
        iImu=iImu+1;
    #if DVL data available store it
    if tDvl<=t and iDvl<len(dvlData)-1:
        gXDVL = gXDVL + dvlData[iDvl,1]
        gYDVL = gYDVL + dvlData[iDvl,2]
        gZDVL = gZDVL + dvlData[iDvl,3]
        xDVL[0,] = G1D(rangeX,gXDVL,sigmaDVL,ADVL).T
        xDVL[1,] = G1D(rangeX,gYDVL,sigmaDVL,ADVL).T
        xDVL[2,] = G1D(rangeX,gZDVL,sigmaDVL,ADVL).T
        tDvl=dvlData[iDvl+1,0]
        iDvl=iDvl+1;
    # if USBL data available then store it
    if tUsbl<=t and iUsbl<len(usblData)-1: 
        xUSBL[0,] = G1D(rangeX,usblData[iUsbl,1]-lastUsbl[0,0],sigmaUSBL,AUSBL).T
        xUSBL[1,] = G1D(rangeX,usblData[iUsbl,2]-lastUsbl[0,1],sigmaUSBL,AUSBL).T
        xUSBL[2,] = G1D(rangeX,usblData[iUsbl,3]-lastUsbl[0,2],sigmaUSBL,AUSBL).T
        tUsbl=usblData[iUsbl+1,0]
        iUsbl=iUsbl+1;
    else:
        xUSBL=np.zeros([axis,len(rangeX)]);


    # if DGPS data available then store it
    if tDGPS<=t and iDgps<len(dgpsData)-1: 
        xDGPS[0,] = G1D(rangeX,dgpsData[iDgps,1]-lastDgps[0,0],sigmaDGPS,ADGPS).T
        xDGPS[1,] = G1D(rangeX,dgpsData[iDgps,2]-lastDgps[0,1],sigmaDGPS,ADGPS).T
        xDGPS[2,] = G1D(rangeX,dgpsData[iDgps,3]-lastDgps[0,2],sigmaDGPS,ADGPS).T
        tDgps=dgpsData[iDgps+1,0]
        iDgps=iDgps+1;
    else:
        xDGPS=np.zeros([axis,len(rangeX)]);

    # concatenate the currently available sensory data
    x=np.concatenate((xIMU,xDVL,xUSBL,xDGPS),axis =1)
    x=x.T

    for xyz in range(axis):
        for i in range(iterations):
            r=np.dot(V,y)
            e=np.expand_dims(x[:,xyz], axis=1)/(epsilon2+r) #dimention added in x[:,xyz]
            y=(epsilon1+y)*np.dot(W,e)
        #decoding of reconstructed input    
        comingVal[0,xyz]=decode(np.expand_dims(r[0:len(rangeX),0], axis=0).T,rangeX)
        
        if (np.sum(xUSBL[xyz,:])>0.1) or (np.sum(xDGPS[xyz,:])>0.1):
            globalTrajvar[0,xyz]=np.add(globalTrajvar[0,xyz],comingVal[0,xyz])
            lastUsbl[0,xyz]=globalTrajvar[0,xyz]    
            lastDgps[0,xyz]=globalTrajvar[0,xyz]
            gXIMU=gYIMU=gZIMU=0.0 
            gXDVL=gYDVL=gZDVL=0.0 
            comingVal[0,xyz] = 0.0 
####storing complete trajectory and updating time            
    globalTraj[iImu-1]=np.concatenate((np.array([[t]]),globalTrajvar+comingVal),axis=1)
    t=imuData[iImu,0]



stop_time = time.time()
print(stop_time-start_time)

#trajectory storing
list_traj = list(globalTraj.values())
array_traj=np.asarray(list_traj)
array_traj=np.squeeze(array_traj, axis=1)

#pcbc xyz exes separately
plt.plot(array_traj[:,1])
plt.show()
plt.plot(array_traj[:,2])
plt.show()
plt.plot(array_traj[:,3])
plt.show()

#this is pcbc filter results
fig = plt.figure()
ax = plt.axes(projection='3d')
ax.scatter3D(array_traj[:,1],array_traj[:,2],array_traj[:,3], cmap='Greens')

#this is ground truth
fig = plt.figure()
ax = plt.axes(projection='3d')
ax.scatter3D(gtData[:,1],gtData[:,2],gtData[:,3], cmap='Greens')
plt.show()



