from __future__ import print_function, division
from builtins import range
from sklearn.utils import shuffle
# Note: you may need to update your version of future
# sudo pip install -U future

import numpy as np
import pandas as pd
import cv2


def init_weight_and_bias(M1, M2):
    W = np.random.randn(M1, M2) / np.sqrt(M1)
    b = np.zeros(M2)
    return W.astype(np.float32), b.astype(np.float32)


def init_filter(shape, poolsz):
    w = np.random.randn(*shape) / np.sqrt(np.prod(shape[1:]) + shape[0]*np.prod(shape[2:] / np.prod(poolsz)))
    return w.astype(np.float32)



def error_rate(targets, predictions):
    return np.mean(targets != predictions)


def y2indicator(y,k):
    N = len(y)
    K =k
    ind = np.zeros((N, K))
    for i in range(N):
        ind[i, y[i]] = 1
    return ind


def getData():
    #read data here
    #modify: 1.your path of csv
    #2.The label index(in my case, it is in 0)
    Y = []
    X = []
    first = True
    for line in open('E:\Backup\Facial_expression/train.csv'):
        if first:
            first = False
        else:
            row = line.split(',')
            Y.append(int(row[0]))
            X.append([int(p) for p in row[1:]])
    #Normalize image data by divided 255 to fit it to deep neutral network
    X,Y=np.array(X)/255,np.array(Y)


    return X, Y


def getImageData(check_figure=False):
    #this function is used to reshape data
    #it is designed for gray image, so modify it if you are having a rgb value
    X,Y=getData()
    N, D = X.shape
    d = int(np.sqrt(D))
    X=X.reshape(N,d,d,1)
    #if you want to check whether you are restoring the image correctly
    if check_figure==True:
        cv2.imshow('figure_test',np.asarray(X[0]*255,dtype=np.uint8))
        cv2.waitKey()
    return X, Y

