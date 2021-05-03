from __future__ import print_function
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.preprocessing.image import load_img
from tensorflow.keras.preprocessing.image import img_to_array
from tensorflow.keras.preprocessing.image import save_img

import os
import glob
import numpy as np 


Sky = [128,128,128]
Building = [128,0,0]
Pole = [192,192,128]
Road = [128,64,128]
Pavement = [60,40,222]
Tree = [128,128,0]
SignSymbol = [192,128,128]
Fence = [64,64,128]
Car = [64,0,128]
Pedestrian = [64,64,0]
Bicyclist = [0,128,192]
Unlabelled = [0,0,0]

COLOR_DICT = np.array([Sky, Building, Pole, Road, Pavement,
                          Tree, SignSymbol, Fence, Car, Pedestrian, Bicyclist, Unlabelled])



def testGenerator(test_path,target_size = (512,512),flag_multi_class = False,as_gray = True):
    directory = test_path
    for filename in os.listdir(directory):
        img = load_img(os.path.join(directory, filename),color_mode='grayscale')
        img = img_to_array(img)
        if(np.max(img) > 1):
            img = img / 255
        img = np.array([img])
        yield img


def labelVisualize(num_class,color_dict,img):
    img = img[:,:,0] if len(img.shape) == 3 else img
    img_out = np.zeros(img.shape + (3,))
    for i in range(num_class):
        img_out[img == i,:] = color_dict[i]
    return img_out / 255
        

def saveResult(scan_path,save_path,npyfile,flag_multi_class = False,num_class = 2):
    filenames = []
    for root, dirs, files in os.walk(scan_path):
        for file in files:
            filenames.append(file)
    for i,item in enumerate(npyfile):
        img = labelVisualize(num_class,COLOR_DICT,item) if flag_multi_class else item[:,:,0]
        filename, extention = os.path.splitext(filenames[i])
        save_img(os.path.join(save_path,filename+'.png'), item)
        
        
        
        
