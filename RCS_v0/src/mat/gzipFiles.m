clear variables; close all;

% %%%  Header  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% Author: LE Celia
% Co Author: 
% Date: 12/8/2020
%
% Info:
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %

path = "../InputData/teeth/SegmentedCleanManual/"
scans = dir(fullfile(path,'*nii'));

for k = 1:length(scans)
    gzip(strcat(scans(k).folder,'/',scans(k).name));
    delete(strcat(scans(k).folder,'/',scans(k).name));
end