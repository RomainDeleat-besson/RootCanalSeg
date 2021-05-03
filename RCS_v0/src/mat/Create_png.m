% %%%  Header  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% Author: DELEAT-BESSON Romain
% Co Author: 
% Date: 
%
% Info:
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %

function Create_png(input_dir, output_dir, label)
    PathInput = input_dir;
    dirPathScan = dir(PathInput);
    ElemFile = dirPathScan(~ismember({dirPathScan.name},{'.','..','.DS_Store'}));
    files = extractfield(ElemFile,'name');

    PathPrediction = output_dir;


    for k = 1:length(files)
        File = strcat(PathInput,char(files(k)));
        
        if label
            scanName = files{k};
            disp(scanName)
            Scan = imbinarize(niftiread(File));
            [~,~,p] = size(Scan);
            Scan = imresize3(Scan, [256 256 p]);
            
        else
            scanName = files{k};
            disp(scanName)
            Scan = niftiread(File);
            [~,~,p] = size(Scan);
            Scan = imresize3(Scan, [256 256 p]);
            Scan(Scan < 0) = 0;
            Scan = mat2gray(Scan);
            Scan = imadjustn(Scan);
        end



        ImagesNumber = 1; % Remove me if you want images 1-6600
        for i = 30:min(p,200)
            current_slice = Scan(:, :, i);

            scanName = strsplit(scanName,'.');
            scanName = string(scanName(1));
            file_name = sprintf('%s_%d%s', scanName, ImagesNumber, '.png');
            saveFile = sprintf('%s%s', PathPrediction, file_name);
            imwrite(current_slice, saveFile);

            ImagesNumber = ImagesNumber + 1;
        end
    end
end