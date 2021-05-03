clear variables; close all;

% %%%  Header  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% Author: DUMONT Maxime
% Co Author: DELEAT-BESSON Romain
% Date: 12/7/2020
%
% Info:
% - The input of this program is a folder with 3D images with the '.nii'
% extension
% - The output is 2D images with the '.png' extension
% - This program will create 2D images from a 3D scan. Each slice of the 3D 
% scan will be a 2D image with the '.png' extension.
% 
% ATTENTION, SERT AUSSI POUR LE TRAINING. A VOIR SI ON GARDE LA VAR:
% RationTraining
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %

warning('off', 'MATLAB:MKDIR:DirectoryExists');
sizes = [];
ImagesNumber = 1;
RatioTraining = 0.8 % Number between 0 and 1 (pourcentage)

path = dir("../InputData/teeth/scan");
NbrElemFile = length(path(~ismember({path.name},{'.','..','.DS_Store'})))
NbrImTraining = uint32(RatioTraining*NbrElemFile)
NbrImTest = NbrElemFile-NbrImTraining


for j = 1:2
    if j == 1 % Processing test images
        CV_folder = sprintf('%s%s', '../InputDeepLearning/teeth/cross_validation/', 'CV_test');
        mkdir(CV_folder)
        
        % Create a list with the first and the last index
        if mod(NbrImTest,2)==0
            % The number of test image is pair
            TrainTest = (1:NbrImTest/2);
            TrainTest = [TrainTest, (NbrElemFile+1-(NbrImTest/2):NbrElemFile)];
        else
            % The number of test image is odd
            TrainTest = (1:uint8(NbrImTest/2));
            TrainTest = [TrainTest, (NbrElemFile+2-uint8(NbrImTest/2):NbrElemFile)];
        end
        
        disp("Processing Test Images")
        
    elseif j == 2 % Processing train images
        CV_folder = sprintf('%s%s', '../InputDeepLearning/teeth/cross_validation/', 'CV_train');
        mkdir(CV_folder)
        
        % Create a list with the index between the first and the last index
        % of the test image
        if mod(NbrImTest,2)==0
            % The number of test image is pair
            TrainTest = (NbrImTest/2+1:NbrElemFile-(NbrImTest/2));  
        else
            % The number of test image is odd
            TrainTest = (uint8(NbrImTest/2)+1:NbrElemFile-uint8(NbrImTest/2)+1);
        end
        
        disp("Processing Train Images")
    end
    
    folder_name_scan = sprintf('%s/%s', CV_folder, 'image');
    folder_name = sprintf('%s/%s', CV_folder, 'label');
    mkdir(folder_name_scan)
    mkdir(folder_name)

    
    for k = TrainTest
        File = "../InputData/teeth/SegmentedCleanManual/P"  +num2str(k)  +"RC_seg.nii.gz";
        Segmentation = im2double(imbinarize(niftiread(File)));
        info = niftiinfo(File);
        info.DataType = 'double';

        File = "../InputData/teeth/scan/P" + num2str(k) + "_scan.nii.gz";
        Scan = niftiread(File);
        
        disp("P" + num2str(k) + "_scan.nii.gz")

        [m,n,p] = size(Segmentation);
        Scan = imresize3(Scan, [512 512 p]);
        Scan(Scan < 1) = 0;
        Scan = imadjustn(Scan);
        Scan = im2double(Scan);
        Segmentation = imresize3(Segmentation, [512 512 p]);

        [m,n,p] = size(Scan);
        sizes = [sizes; [m,n,p]];

        ImagesNumber = 1; % Remove me if you want images 1-6600
        for i = 30:min(p,200)
            current_slice = Segmentation(:, :, i);
            current_slice = abs(current_slice - 1);
            

            file_path = sprintf('%s%s', folder_name, '/');
            file_name = sprintf('%s%d_%d%s','P',k, ImagesNumber, '.png');
            file = sprintf('%s%s', file_path,file_name);

            imwrite(current_slice, file);

            current_slice = Scan(:, :, i);
            file_path = sprintf('%s%s', folder_name_scan, '/');

            file_name = sprintf('%s%d_%d%s','P',k, ImagesNumber, '.png');
            file = sprintf('%s%s', file_path,file_name);
            imwrite(current_slice, file);

            ImagesNumber = ImagesNumber + 1;
        end
    end
end
