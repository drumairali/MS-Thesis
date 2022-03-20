# -*- coding: utf-8 -*-
"""
Created on Sun Apr 12 04:27:41 2020

@author: eeuma
"""

import pandas as pd
import numpy as np

# Function for Encoding
def  G1D(Range,c,sigma):
    return np.exp(-(0.5/sigma**2)*(Range-c)**2)
# Function for Decoding
def decode(z,Range):
    return np.sum(z*Range)/np.sum(z)

def loadData():
    ##IMPORTING MAT FILES 
    #USBL data x and y axis
    data = pd.read_csv('data/usblData.mat', sep=" ", header=0)
    data.columns = ["","t","x","y"]
    usblData = data[['t','x','y']].to_numpy()
    #DGPS data x and y axis
    data = pd.read_csv('data/dgpsData.mat', sep=" ", header=0)
    data.columns = ["","t","x","y"]
    dgpsData = data[['t','x','y']].to_numpy()
    #Odom data x and y axis
    data = pd.read_csv('data/odometryData.mat', sep=" ", header=0)
    data.columns = ["","t","x","y","","",""]
    odomData = data[['t','x','y']].to_numpy()
    return usblData, dgpsData, odomData

def Weights(centOdom,ranOdom,sigOdom,centUsbl,ranUsbl,sigUsbl):
    #Weights for Odometry Sensor
    WOdom=np.zeros([len(centOdom),len(ranOdom)])
    for iw in range(len(centOdom)):
        WG1D = G1D(ranOdom,centOdom[iw],sigOdom).T
        WOdom[iw,:]=WG1D
        #Weights for Usbl Sensor
    WUsbl=np.zeros([len(centUsbl),len(ranUsbl)])
    for iw in range(len(centUsbl)):
        WG1D = G1D(ranUsbl,centUsbl[iw],sigUsbl).T
        WUsbl[iw,:]=WG1D

    ##  CONCATENATE WEIGHTSs of usbl and odom with eye matrix and V
    W = np.concatenate((WOdom,WUsbl),axis=1)
    return W






