## Introduction
This tool aims to provide a easy-plug-in Convolution neural network in high-level structure. The main contributions of it are 
1) Easy to use and very flexible. If you want to try different architectures like VGG16, Alexnet or diy your own structure, you just need to change one line of code in the main call. 

2) Easy to tune parameters. All parameters that can influence the performance will be able to tune in the main fuction by just one line of code.

3)It contians several models from easy to complicated. Includes: 2D CNN, 3D CNN, Bilinear CNN, M-fusion CNN, Two-stream CNN for motion recoginition.

4)Every model has two version--one for handle small dataset or low resolution image(eg:48*48) and one handle big data with high resolution image so that you can deal with the limitation of hardware of your pc.


## Tutorial
For details of the architecture of this toolbox, please go to my own blog. A sample of using it for mnist dataset is shown here.
open cnn_basic.py first, and go to the main function
``` python
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
 ```
Basically, it will read data in the class utility from function getImageData() and return images with shape of (N,W,H,C) and corresponding labels.

Then use model=CNN() to setup the network parameters including convolution layer size and numbers, pool size for each convolution layer, whether use batch normalizations, fully connected layer num and size, dropout rate for each fully connceted layer, optimizers, train and test split ratio and the path to save your trained model. 

Tune the detailed parameters such as learning rate, decay, batch sizes , momentum and so on in fit() function. 

All you need to notice is go to getImageData() function to change the path of your own csv data and modify it a little bit based on your unique situation.

That's it!

