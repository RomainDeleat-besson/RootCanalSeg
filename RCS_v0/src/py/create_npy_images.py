from tensorflow.keras.preprocessing.image import load_img
from tensorflow.keras.preprocessing.image import img_to_array

import numpy as np
import glob
import os


def adjustData(img,mask=False):
    if(np.max(img) > 1):
        img = img / 255
        
    if(mask):
        if(np.max(img) > 1):
            img = img /255
        img[img > 0.5] = 1
        img[img <= 0.5] = 0
    return (img)



train_image_path = "../InputDeepLearning/teeth/cross_validation/CV_train2/image"
train_label_path = "../InputDeepLearning/teeth/cross_validation/CV_train2/label"
test_image_path  = "../InputDeepLearning/teeth/cross_validation/CV_test2/image"
test_label_path  = "../InputDeepLearning/teeth/cross_validation/CV_test2/label"
save_path        = "../npy_files/"



train_image_arr = glob.glob(os.path.join(train_image_path,"*"))
train_arr = np.zeros((int(len(train_image_arr)), 512, 512))

cpt=0
for index,item in enumerate(train_image_arr):
    cpt+=1
    img = load_img(item,color_mode='grayscale')
    img = img_to_array(img)

    img = adjustData(img,mask=False)
    img = np.reshape(img,(512,512))
    train_arr[index,:,:]=img

    if(cpt%500==0):
        print(cpt, " images saved")

np.save(save_path+"train_image2",train_arr)
del(train_arr)



train_mask_arr = glob.glob(os.path.join(train_label_path,"*"))
maskTrain_arr = np.zeros((int(len(train_mask_arr)), 512, 512))

cpt=0
for index,item in enumerate(train_mask_arr):
    mask = load_img(item,color_mode='grayscale')
    mask = img_to_array(mask)

    mask = adjustData(mask,mask=True)
    mask = np.reshape(mask,(512,512))
    maskTrain_arr[index,:,:]=mask

    if(cpt%500==0):
        print(cpt, " images saved")

np.save(save_path+"train_label2",maskTrain_arr)
del(maskTrain_arr)



test_image_arr = glob.glob(os.path.join(test_image_path,"*"))
test_arr = np.zeros((int(len(test_image_arr)), 512, 512))

for index,item in enumerate(test_image_arr):
    img = load_img(item,color_mode='grayscale')
    img = img_to_array(img)

    img = adjustData(img,mask=False)
    img = np.reshape(img,(512,512))
    test_arr[index,:,:]=img

np.save(save_path+"test_image2",test_arr)
del(test_arr)



test_mask_arr = glob.glob(os.path.join(test_label_path,"*"))
maskTest_arr = np.zeros((int(len(test_mask_arr)), 512, 512))

for index,item in enumerate(test_mask_arr):
    mask = load_img(item,color_mode='grayscale')
    mask = img_to_array(mask)

    mask = adjustData(mask,mask=True)
    mask = np.reshape(mask,(512,512))
    maskTest_arr[index,:,:]=mask

np.save(save_path+"test_label2",maskTest_arr)
del(maskTest_arr)
