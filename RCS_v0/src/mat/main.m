clear variables; close all;

% %%%  Header  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% Author: DELEAT-BESSON Romain & DUMONT Maxime
% Co Author: 
% Date: 12/7/2020
%
% Info:
% - This program take as input the png files created by the model prediction
% and recreate a 3D images '.nii'. 
% - The output is the 3D scan.
% - The first part of this algorithm count the number of png file per patient
% the second one recreate the 3D image
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %


%%
inputdir = "../OutputDeepLearning/"
input_originalScan = '../InputData/teeth/scan/'
outputdir = '../OutputData/Reconstruction/'

disp("Reconstruction...")
% Reconstruction(inputdir, input_originalScan, outputdir)


%%
inputdir_rec = "../OutputData/Reconstruction"
outputdir = '../OutputData/'
RemoveMollars = 1

disp("PostProcessing...")
PostProcess(inputdir_rec, outputdir, RemoveMollars)

%%
% Compute_AUC