import tensorflow as tf
import numpy as np
import tflearn
from faceutil import  getData,init_weight_and_bias,error_rate
from sklearn.utils import  shuffle
import matplotlib.pyplot as plt

class HiddenLayer(object):
    def __init__(self,M1,M2,i,batch_norm=True):
        W=np.random.randn(M1,M2)/np.sqrt(M1)
        b=np.zeros(M2)
        self.W = tf.Variable(W.astype(np.float32), name=('W%d') % (i))
        self.b = tf.Variable(b.astype(np.float32), name=('b%d') % (i))
        self.param=[self.W,self.b]
        self.i=i
        self.batch_norm=batch_norm

    def forward(self,Z,phase_train):
        layer=tf.matmul(Z,self.W)+self.b
        if self.batch_norm==True:
            hidden_bn = tf.cond(phase_train,
                              lambda: tflearn.layers.batch_normalization(layer, trainable=True, restore=True,
                                                                         name='h_batch_normalization_%d' % (self.i)),
                              lambda: tflearn.layers.batch_normalization(layer, trainable=False, restore=True,
                                                                         name='h_batch_normalization_%d' % (self.i)
                                                                         ))
        else:
            hidden_bn=layer



        return tf.nn.relu(hidden_bn)

class ANN(object):
    def __init__(self, hidden_layer_sizes, p_keep):
        self.hidden_layer_sizes = hidden_layer_sizes
        self.dropout_rates = p_keep

    def fit(self,X,Y,lr=1e-7,reg=1e-3,mom=0.99,decay=0.999,epoches=400,batch_size=100):
        X,Y=shuffle(X,Y)
        K=len(set(Y))
        X=X.astype(np.float32)
        Y=Y.astype(np.int64)
        Xtrain,Ytrain=X[:-1000,],Y[:-1000,]
        Xvalid,Yvalid=X[-1000:,],Y[-1000:,]

#define the layers
        N,D=Xtrain.shape
        self.hiddenlayer=[]
        M1=D
        count=0
        for M2 in self.hidden_layer_sizes:
            h=HiddenLayer(M1,M2,count)
            count+=1
            self.hiddenlayer.append(h)
            M1=M2

        W=np.random.randn(M1,K)/np.sqrt(M1)
        b=np.zeros(K)

        self.W=tf.Variable(W.astype(np.float32),name='W0')
        self.b=tf.Variable(b.astype(np.float32),name='b0')
        self.para=[self.W,self.b]
        for h in self.hiddenlayer:
            self.para+=h.param

        input=tf.placeholder(tf.float32,shape=(None,D),name='input')
        label=tf.placeholder(tf.int64,shape=(None,),name='labels')
        logit=self.forward(input)
        rcost=reg*sum([tf.nn.l2_loss(p) for p in self.para])
        cost=tf.reduce_mean(tf.nn.sparse_softmax_cross_entropy_with_logits(logits=logit,labels=label))+rcost
        prediction=self.predict(input)
        train_op=tf.train.RMSPropOptimizer(learning_rate=lr,momentum=mom,decay=decay).minimize(cost)


        n_batch=N//batch_size
        init=tf.global_variables_initializer()
        costs=[]
        with tf.Session() as session:
            session.run(init)
            for i in range(epoches):
                print('this is round :',i)
                Xtrain,Ytrain=shuffle(Xtrain,Ytrain)
                for j in range(n_batch):
                    Xbatch=Xtrain[j*batch_size:(j+1)*batch_size,]
                    Ybatch = Ytrain[j * batch_size:(j + 1) * batch_size, ]
                    session.run(train_op,feed_dict={input:Xbatch,label:Ybatch})
                    if j%50==0:
                        c = session.run(cost, feed_dict={input: Xvalid, label: Yvalid})
                        predict_op=session.run(prediction,feed_dict={input:Xvalid})
                        costs.append(c)
                        e=error_rate(predict_op,Yvalid)
                        print("in batch :",j,"the cost is ",c,"the error is ",e)
        plt.plot(costs)
        plt.show()

    def forward(self,X,phase_train):
        Z=X
        Z=tf.nn.dropout(Z,self.dropout_rates[0])


        if phase_train is not None:
            phase = True
        else:
            phase = False

        for h,p in zip(self.hiddenlayer,self.dropout_rates[1:]):
           # self.reg+=tf.nn.l2_loss(h.param[0])+tf.nn.l2_loss(h.param[1])
           Z = h.forward(Z,phase)
           Z = tf.nn.dropout(Z, p)
        return tf.matmul(Z,self.W)+self.b


    def predict(self,input):
        pY=self.forward(input)
        return tf.argmax(pY,1)

def error_rate(p, t):
    return np.mean(p != t)

def main():
    # step 1: get the data and define all the usual variables
    X, Y = getData()

    ann = ANN([2000, 1000,500], [0.8, 0.5, 0.5,0.5])
    ann.fit(X, Y)


if __name__ == '__main__':
    main()