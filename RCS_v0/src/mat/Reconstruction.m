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

function Reconstruction(input_dir, input_originalScan, output_dir)
    inputdir = input_dir;
    path = dir(inputdir);
    ElemFile = path(~ismember({path.name},{'.','..','.DS_Store'}));
    files = extractfield(ElemFile,'name'); % Get all the filenames
    line = 1; % Read the first filename 
    file = files{line};

    patient = file(1:5); %Take the 5 first letter in the filename
    current_f = '';
    current_f = file(1:strfind(file,'_')-1);%Detects the first'_'
    current_p = file(1:strfind(file,'_')-1);
    file_per_patient = [];
    patients = [];


    while line < length(files)
        number = 0;

        while strcmp(current_p, current_f)%While the patient numbers match 
            line = line + 1;
            file = files{line};
            limit = strfind(file,'_');
            current_f = file(1:limit(1)-1);
            number = number + 1;

            if line == length(files)%If it reachs the last line
                number = number + 1;
                break
            end
        end

        patients = [patients; patient];
        patient = file(1:5);
        current_p = current_f;
        file_per_patient = [file_per_patient; number];

        if line == length(files)
            break
        end
    end



    % %%%  3D image reconstruction  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %

    cumul = 2; % Number of png images per patient
    pathoriginalScan = dir(input_originalScan);
    PathOriginalScans = pathoriginalScan(~ismember({pathoriginalScan.name},{'.','..','.DS_Store'}));
    filesOriginalScans = extractfield(PathOriginalScans,'name'); % Get all the filenames
    FolderOriginalScans = PathOriginalScans.folder;
    
    for p = 1:size(filesOriginalScans,2)
        patient = sprintf('%s%s%s', FolderOriginalScans, '/',filesOriginalScans{p});
        
        if contains(filesOriginalScans{p}, '.nrrd')
            original_scan = nrrdread(patient);
            [Spacing, Origin] = GetSpacingOriginFromNrrd(patient);
        end
        
        if contains(filesOriginalScans{p}, '.nii')
            original_scan = niftiread(patient);
            info = niftiinfo(patient);
            Spacing = [info.raw.pixdim(2), info.raw.pixdim(3), info.raw.pixdim(4)];
            Origin = [-info.raw.qoffset_x, -info.raw.qoffset_y, info.raw.qoffset_z];
        end
        

        [m,n,z] = size(original_scan);
        final_image = zeros([m,n,z]);

        for i = 1:file_per_patient(p) - 1
            if i + cumul <= length(files)
                img = files{i + cumul};

                slice_nbr = strsplit(img,{'_','.'},'CollapseDelimiters',true);
                slice_nbr = str2num(slice_nbr{2});

                filename = sprintf('%s%s', inputdir, img);
                current_prediction = im2double(imread(filename));
                current_prediction = abs(current_prediction - 1);
                current_prediction = imresize(current_prediction, [m n]);  
                final_image(:, :, 29+slice_nbr) = current_prediction;
            end
        end

        
        cumul = cumul + file_per_patient(p);
        nameFile = char(split(filesOriginalScans{p}, "."));
        final_name = sprintf('%s%s', nameFile(1,:), '_rec');
        output = output_dir;
        output_fileName = sprintf('%s%s%s', output, final_name,'.nrrd');
        disp(['Writing ' output_fileName])
        output_file = int16(final_image);

    %     niftiwrite(final_image,final_file,info);
        nrrdWriter(output_fileName, output_file, Spacing, Origin, 'raw');
        gzip(output_fileName);
        delete(output_fileName)
    end
end

