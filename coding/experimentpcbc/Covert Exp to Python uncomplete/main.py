# -*- coding: utf-8 -*-
"""
Created on Sun Apr 12 01:23:07 2020

@author: eeuma
"""

import numpy as np
from funcFile import G1D,decode,loadData,Weights

[usblData, dgpsData, odomData]=loadData()


## DECLARING RANGES AND CENTERS FOR ODOMETRY AND USBL SENSOR
#range and center for Odom
ranOdom=np.arange(-1, 1.1, 0.1, dtype=float)# start stop step
ranOdom = np.expand_dims(ranOdom, axis=0).T

centOdom=np.arange(-1, 1.2, 0.2, dtype=float) 
centOdom = np.expand_dims(centOdom, axis=0).T

#range and center for Usbl
ranUsbl=np.arange(-80, 81, 8, dtype=float)
ranUsbl = np.expand_dims(ranUsbl, axis=0).T

centUsbl=np.arange(-80, 81, 16, dtype=float)
centUsbl = np.expand_dims(centUsbl, axis=0).T

##SIGMA POINTS
sigOdom = 0.2
sigUsbl = 16.0

## WEIGHTS
W = Weights(centOdom,ranOdom,sigOdom,centUsbl,ranUsbl,sigUsbl)
V = (W/np.max(W))
W = np.concatenate((W,np.eye(len(centOdom))),axis=1) # eye is added with W
V = np.concatenate((V,np.eye(len(centOdom))),axis=1) # eye is added with V
V = V.T

#n is number of rows and m is number of columns of W
[n,m]=W.shape

# initialze y with zeros of centers' size 
y=np.zeros([n,1]);

#for pcbc filter some small values
epsilon1=1e-6;
epsilon2=1e-4;
















