from model import *
from data import *
from tensorflow.keras.models import load_model
  

ImagePredict_path = "../InputDeepLearning/"
save_path         = "../OutputDeepLearning/"
model_path        = "../UpperLowerJawModel_1_30.hdf5"


model = unet()
model = load_model(model_path)

testGene = testGenerator(ImagePredict_path)
results = model.predict(testGene,verbose=1)
saveResult(ImagePredict_path, save_path, results)


