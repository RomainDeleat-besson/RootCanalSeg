from model import *
from data import *
from tensorflow.keras.callbacks import TensorBoard
from tensorflow.keras.models import load_model

import datetime
import numpy as np



train_image_path = "../InputDeepLearning/teeth/cross_validation/CV_train2/image"
train_label_path = "../InputDeepLearning/teeth/cross_validation/CV_train2/label"
test_image_path  = "../InputDeepLearning/teeth/cross_validation/CV_test2/image"
test_label_path  = "../InputDeepLearning/teeth/cross_validation/CV_test2/label"
save_path        = "../OutputDeepLearning"
npy_path         = "../npy_files/"
model_path       = "../TrainedModels/test/test_{epoch}.hdf5"
log_path         = "../TrainedModels/logsModel/"



batch_size=2
nb_epoch=2
validationSteps = 2

# for files in os.walk(test_image_path):print()
# validationSteps = round(len(files[2])/batch_size)


train_image_arr = np.load(npy_path+"train_image2.npy")
train_label_arr = np.load(npy_path+"train_label2.npy")
test_image_arr  = np.load(npy_path+"test_image2.npy")
test_label_arr  = np.load(npy_path+"test_label2.npy")


train_image_arr = np.reshape(train_image_arr,train_image_arr.shape + (1,))
train_label_arr = np.reshape(train_label_arr,train_label_arr.shape + (1,))
test_image_arr = np.reshape(test_image_arr,test_image_arr.shape + (1,))
test_label_arr = np.reshape(test_label_arr,test_label_arr.shape + (1,))



model = unet()
                   
model_checkpoint = ModelCheckpoint(model_path, monitor='loss',verbose=1, period=1)
log_dir = log_path+datetime.datetime.now().strftime("%Y_%d_%m-%H:%M:%S")
tensorboard_callback = TensorBoard(log_dir=log_dir,histogram_freq=1)

callbacks_list = [model_checkpoint, tensorboard_callback]
model.fit(train_image_arr, train_label_arr, batch_size, nb_epoch, validation_data=(test_image_arr,test_label_arr),validation_steps=validationSteps,verbose=2, shuffle=True, callbacks=[model_checkpoint, tensorboard_callback])
# callbacks_list = [model_checkpoint]
# model.fit(train_image_arr, train_label_arr, batch_size, nb_epoch, verbose=1, shuffle=True, callbacks=callbacks_list)






