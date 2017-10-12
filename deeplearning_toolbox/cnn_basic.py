#Written by Runsheng Xu, research purpose
#This tool is written based on tensorflow, and is very easy to add layer,batch normailzation, switch optimizer and so on
#Just change the parameters you want in the main function
import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt
from Utility import getData,getImageData,init_filter,init_weight_and_bias,error_rate,y2indicator
from ANN_Layer import HiddenLayer
from sklearn.utils import shuffle
import tflearn
#This function is mainly for low dimension images (like MNIST)
class ConvPoolLayer(object):
    def __init__(self, mi, mo,fw,fh,count_conv,poolsz=(2, 2),batch_norm=True):
        # mi = input feature map size
        # mo = output feature map size
        sz = (fw, fh, mi, mo)
        W0 = init_filter(sz, poolsz)
        self.W = tf.Variable(W0)
        b0 = np.zeros(mo, dtype=np.float32)
        self.b = tf.Variable(b0)
        self.poolsz = poolsz
        self.params = [self.W, self.b]
        self.count_conv = count_conv
        self.batch_norm=batch_norm

    def forward(self, X, phase_train):
        conv_out = tf.nn.conv2d(X, self.W, strides=[1, 1, 1, 1], padding='SAME')
        conv_out = tf.nn.bias_add(conv_out, self.b)
        if self.batch_norm==True:
            conv_bn = tf.cond(phase_train,
                              lambda: tflearn.layers.batch_normalization(conv_out, trainable=True, restore=True,
                                                                         name='batch_normalization_%d' % (
                                                                         self.count_conv)),
                              lambda: tflearn.layers.batch_normalization(conv_out, trainable=False, restore=True,
                                                                         name='batch_normalization_%d' % (
                                                                         self.count_conv)
                                                                         ))
            conv_out=tf.tanh(conv_bn)
        else:
            conv_out=tf.tanh(conv_out)

        p1, p2 = self.poolsz
        if p1!=0 and p2!=0:
            pool_out = tf.nn.max_pool(
                conv_out,
                ksize=[1, p1, p2, 1],
                strides=[1, p1, p2, 1],
                padding='SAME'
            )
        else:
            pool_out=conv_out
        return pool_out


class CNN(object):
    def __init__(self, convpool_layer_sizes, pool_size, batch_norm,hidden_layer_sizes,drop_out_rate,model_path,train_method='RMSprop',split=0.7):
        self.convpool_layer_sizes = convpool_layer_sizes
        self.pool_size=pool_size
        self.hidden_layer_sizes = hidden_layer_sizes
        self.drop_out_rate=drop_out_rate
        self.train_method=train_method
        self.batch_norm=batch_norm
        self.split=split
        self.model_path=model_path
    def fit(self, X, Y, lr=10e-4, mu=0.99, reg=10e-4, decay=0.99999, eps=10e-3, batch_sz=30, epochs=20, icv=0.1,beta1=0.9,beta2=0.999,show_fig=True):
        #learning rate
        lr = np.float32(lr)
        #momentum
        mu = np.float32(mu)
        #regularization,will be turn off if batch normalization is on
        reg = np.float32(reg)
        #decay
        decay = np.float32(decay)
        #eps
        eps = np.float32(eps)
        #class numbers
        K = len(set(Y))

        # split train and test data
        N_total=X.shape[0]
        # shuffle data
        X,Y=shuffle(X,Y)
        train_idx=int(N_total*self.split)
        X = X.astype(np.float32)
        #one-hot encoded for label
        Y = y2indicator(Y,K).astype(np.float32,K)
        Xvalid, Yvalid = X[train_idx:], Y[train_idx:]
        X, Y = X[:train_idx], Y[:train_idx]
        Yvalid_flat = np.argmax(Yvalid, axis=1) # for calculating error rate
        # initialize convpool layers
        N, width, height, c = X.shape
        mi = c
        outw = width
        outh = height
        self.convpool_layers = []
        #for recording the name of each convol filter
        count_cov = 0
        for tempA,tempB in zip(self.convpool_layer_sizes,self.pool_size):
            mo=tempA[0]
            fw=tempA[1]
            fh=tempA[2]
            p1=tempB[0]
            p2=tempB[1]
            layer = ConvPoolLayer(mi, mo, fw, fh, count_cov,poolsz=(p1,p2),batch_norm=self.batch_norm)
            self.convpool_layers.append(layer)
            outw = outw // 2
            outh = outh // 2
            mi = mo
            count_cov += 1

        # initialize mlp layers
        self.hidden_layers = []
        M1 = self.convpool_layer_sizes[-1][0]*outw*outh # size must be same as output of last convpool layer
        count = 0
        for M2 in self.hidden_layer_sizes:
            h = HiddenLayer(M1, M2, count)
            self.hidden_layers.append(h)
            M1 = M2
            count += 1

        # logistic regression layer
        W, b = init_weight_and_bias(M1, K)
        self.W = tf.Variable(W, 'W_logreg')
        self.b = tf.Variable(b, 'b_logreg')

        # collect params for later use
        self.params = [self.W, self.b]
        for h in self.convpool_layers:
            self.params += h.params
        for h in self.hidden_layers:
            self.params += h.param

        # set up tensorflow functions and variables
        tfX = tf.placeholder(tf.float32, shape=(batch_sz, width, height, c), name='X')
        tfY = tf.placeholder(tf.float32, shape=(batch_sz, K), name='Y')
        #for indicating training or testing procedure
        tf_phase = tf.placeholder(tf.bool, name='BOOL')
        act = self.forward(tfX,tf_phase)
        rcost = reg*sum([tf.nn.l2_loss(p) for p in self.params])
        cost = tf.reduce_mean(
            tf.nn.softmax_cross_entropy_with_logits(
                logits=act,
                labels=tfY
            )
        ) + rcost*[1 if self.batch_norm==False else 0]
        prediction = self.predict(tfX,tf_phase)
        if self.train_method=='RMSprop':
            train_op = tf.train.RMSPropOptimizer(lr, decay=decay, momentum=mu).minimize(cost)
        elif self.train_method=='GradientDescent':
            train_op = tf.train.GradientDescentOptimizer(lr).minimize(cost)
        elif self.train_method=='MomentumOptimizer':
            train_op = tf.train.MomentumOptimizer(lr,momentum=mu).minimize(cost)
        elif self.train_method=='AdamOptimizer':
            train_op = tf.train.AdamOptimizer(lr, beta1=beta1,beta2=beta2).minimize(cost)

        n_batches = N // batch_sz
        costs = []
        init = tf.global_variables_initializer()
        saver = tf.train.Saver(max_to_keep=4, keep_checkpoint_every_n_hours=1) #save model for future use

        with tf.Session() as session:
            session.run(init)
            for i in range(epochs):
                print('shuffle data')
                X, Y = shuffle(X, Y)
                print('shuffle data finished')
                for j in range(n_batches):
                    Xbatch = X[j*batch_sz:(j*batch_sz+batch_sz)]
                    Ybatch = Y[j*batch_sz:(j*batch_sz+batch_sz)]
                    phase_train = True
                    session.run(train_op, feed_dict={tfX: Xbatch, tfY: Ybatch,tf_phase:phase_train})

                    if j % 50 == 0:
                        #using batch to avoid running out of RAM
                        #save the model in model path
                        saver.save(session,self.model_path,global_step=i
                                   )

                        predictions=np.zeros(len(Yvalid),dtype=np.float32)
                        c=0
                        for k in range(len(Xvalid)//batch_sz):
                            Xvalid_batch=Xvalid[k*batch_sz:(k+1)*batch_sz,]
                            Yvalid_batch=Yvalid[k*batch_sz:(k+1)*batch_sz,]
                            phase_train=False
                            c_temp = session.run(cost, feed_dict={tfX: Xvalid_batch, tfY: Yvalid_batch,tf_phase:phase_train})
                            c+=c_temp
                            p = session.run(prediction, feed_dict={tfX: Xvalid_batch, tfY: Yvalid_batch,tf_phase:phase_train})
                            predictions[k*batch_sz:(k+1)*batch_sz,]=p
                        e = error_rate(Yvalid_flat, predictions)
                        costs.append(c)
                        print("iteration:", i, "j:", j, "nb:", n_batches, "cost:", c, "error rate:", e)

        if show_fig:
            plt.plot(costs)
            plt.show()

    def forward(self, X,phase_train):
        Z = X
        for c in self.convpool_layers:
            Z = c.forward(Z,phase_train)
        Z_shape = Z.get_shape().as_list()
        Z = tf.reshape(Z, [-1, np.prod(Z_shape[1:])])
        Z=tf.nn.dropout(Z,self.drop_out_rate[0])
        for h,p in zip(self.hidden_layers,self.drop_out_rate[1:]):
            Z = h.forward(Z,phase_train)
            Z=tf.nn.dropout(Z,p)
        return tf.matmul(Z, self.W) + self.b

    def predict(self, X,phase_train):
        pY = self.forward(X,phase_train)
        return tf.argmax(pY, 1)


def main():
    #Data request: Must be a csv, first row is header, first colum is label, second colum is flatten features in one row
    #You have to go to the utility.py --getImageData() function to change the path of the data  you are reading
    X, Y = getImageData()
    #make sure you have correct data shape
    print("X.shape:", X.shape)
    #convpool_layer_sizes:input your convol layer filters[feature map out,width,height]
    #pool_size:  input the pool layer size after each convolution layer, [0,0] means no pool for that convolution layer
    #batch_normal: True if you want to use batch normalization
    #hidden_layer_sizes: hiddenlayer nodes[layer1 nodes, layer2 nodes...]
    #drop_out_rate: input your drop out rate for hiddenlayer[input dropout rate,layer1 rate,layer2 rate],if you have 2 hiddenlayers, then you need input 3 rates
    #train_method: input your train method  including:GradientDescent,Adagraduate,MomentumOptimizer,Adam,RMSprop(default)
    #split: input how you want to split data(ratio)
    model = CNN(
        convpool_layer_sizes=[(20, 5, 5), (10, 5, 5)],
        pool_size=[(2,2),(2,2)],
        batch_norm=False,
        hidden_layer_sizes=[1000, 500],
        drop_out_rate=[0.8,0.5,0.5],
        train_method='RMSprop',
        split=0.9,
        model_path="D:\CNN-HMM\Model\p105/model.chkp"
    )
    #Input the train method setting you need, including:learning rate(lr),decay,momentum(mu),regularization(reg),batch_size
    #initial_accumulator_value(icv),beta1,beta2
    #also input the batch size and training iterations you need
    model.fit(X, Y,lr=0.001,decay=0.99999,mu=0.99,batch_sz=500,epochs=30)

if __name__ == '__main__':
    main()








