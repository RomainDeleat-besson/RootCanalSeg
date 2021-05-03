from model import *
from data import *
from tensorflow.keras.models import load_model

import datetime
import numpy as np
  

test_image_path  = "../InputDeepLearning/teeth/cross_validation/CV_test/image"
save_path        = "../OutputDeepLearning"
npy_path         = "../npy_files/"
# model_path       = "../TrainedModels/test/test_2.hdf5"
model_path       = "../TrainedModels/UpperLowerJawModel_0_40.hdf5"



batch_size=2
test_image_arr  = np.load(npy_path+"test_image.npy")
test_image_arr = np.reshape(test_image_arr,test_image_arr.shape + (1,))


model = unet()

model = load_model(model_path)
results = model.predict(test_image_arr, batch_size=batch_size,verbose=1)
saveResult(test_image_path, save_path, results)







