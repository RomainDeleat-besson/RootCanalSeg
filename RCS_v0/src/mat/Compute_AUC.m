% clear variables; close all;

% %%%  Header  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% Author: 
% Co Author: 
% Date: 12/7/2020
%
% Info:
% - The input are the reconstructed image labelise and the manuel
% segmentation
% - The output is the comparaison between the 2 inputs displayed in the
% command window
% - This function compute the AUC for the reconstructed image
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %

path = dir("../OutputData");
ElemFile = path(~ismember({path.name},{'.','..','.DS_Store'}));
files = extractfield(ElemFile,'name');

PatientNumber = [];
for i=1:length(ElemFile)-1 % -1 because of the folder 'Reconstruction'
    str="";
    str=str+files{i};
    str = strsplit(str,{'P','_'},'CollapseDelimiters',true);
    PatientNumber=[PatientNumber, str2double(str(2))];    
end

n = length(unique(PatientNumber));
stats = zeros([n 1]);
F1scores = zeros([n 1]);
auc_scores = zeros([n 1]);
sensi_score = zeros([n 1]);
speci_scores = zeros([n 1]);
accuracy_score = zeros([n 1]);

% sort(unique(PatientNumber))
for patient = sort(unique(PatientNumber))
    manu = "../InputData/teeth/SegmentedCleanManual/P"+num2str(patient)+"RC_seg.nii.gz";
    auto = "../OutputData" + "/P" + num2str(patient) + '_scan_DPS.nii.gz';
    disp("Processing  P"+num2str(patient)+"_scan_DPS.nii.gz  for AUC")
    manu_seg = niftiread(manu);
    manu_seg = manu_seg(:);
    auto_seg = im2double(niftiread(auto));
    auto_seg = auto_seg(:);
    auto_seg(auto_seg < 0) = 0;
    auto_seg(auto_seg > 1) = 1;    
    [auc,F1,sensitivity,specificity,accuracy] = AUC(imbinarize(manu_seg),auto_seg);
%     stats(patient) = accuracy;
    F1scores(patient) = F1;
    auc_scores(patient) = auc;
    sensi_score(patient) = sensitivity;
    speci_scores(patient) = specificity;
    accuracy_score(patient) = accuracy;
end


auc_scores(auc_scores==0)=[];
sensi_score(sensi_score==0)=[];
speci_scores(speci_scores==0)=[];
accuracy_score(accuracy_score==0)=[];
F1scores(F1scores==0)=[];


% auc_scores(10)=[];
% sensi_score(10)=[];
% speci_scores(10)=[];
% accuracy_score(10)=[];
% F1scores(10)=[];


disp([mean(auc_scores),std(auc_scores)])
disp([mean(sensi_score),std(sensi_score)])
disp([mean(speci_scores),std(speci_scores)])
disp([mean(accuracy_score),std(accuracy_score)])
disp([mean(F1scores),std(F1scores)])

