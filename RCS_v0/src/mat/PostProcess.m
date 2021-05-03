% %%%  Header  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% Author: DELEAT-BESSON Romain
% Co Author: DUMONT Maxime
% Date: 12/7/2020
%
% Info:
% - The input is the 3D image reconstructed
% - The output is the 3D image labelised
% - This program processes the reconstructed image to remove the remaining 
% artifacts by using threshold and kmeans techniques
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %

function PostProcess(inputdir_rec, output_dir, RemoveMollars)
    pathRec = dir(inputdir_rec);
    ElemFile = pathRec(~ismember({pathRec.name},{'.','..','.DS_Store'}));
    filesRec = extractfield(ElemFile,'name');
    FolderRec = pathRec.folder;


    for k = 1:size(filesRec,2)
        %% Labelising
        auto_rec = strcat(FolderRec, '/', filesRec{k});
        gunzip(auto_rec)
        [filePath, fileName, ~] = fileparts(auto_rec);
        recFile = strcat(filePath, '/', fileName);
        auto_seg = nrrdread(recFile);
        
        
        auto_seg(auto_seg >= 0.1)=1;
        auto_seg(auto_seg < 0.1)=0;
        
        [label, ~] = bwlabeln(auto_seg);
        volume = regionprops3(label, 'Volume');

        for i = 1:length(volume.Volume) 
            if volume.Volume(i) < 500 % Remove small components
                label(label == i) = 0;
            end
        end



        %% COM of the y and z axis

        label(label > 0) = 1;
        [label,n] = bwlabeln(label); % Re-labelize the remaning components
        volume = regionprops3(label, 'Volume');
        COM = regionprops3(label, 'Centroid');

        [w,~]=size(COM);
        COMy = zeros([w 1]);
        COMz = zeros([w 1]);
        for i=1:n
            % Get the Center Of Mass (COM) on the y and z axis 
            COMy(i)=COM.Centroid(i);
            COMz(i)=COM.Centroid(i+2*n); 
        end


        %% Case whith 1 jaw

        ULjaw = true;
        [idx, m] = kmeans(COMz, 2);
        mMax = max(m);
        mMin = min(m);
        [GC,GR] = groupcounts(idx);

        if mMax/mMin < 1.2 || (GC(1)/GC(2)>1.5 || GC(1)/GC(2)<0.5)
            ULjaw=false;


            for i=1:length(COMz)
                if (mean(COMz)/COMz(i)>1.14 || mean(COMz)/COMz(i)<0.86) ...
                        && volume.Volume(i)<3000
                    COMy(i)=0;
                    COMz(i)=0;
                    volume(i,:)={0};
                    label(label == i) = 0;                 
                end
            end



            % Remove components that are too far from the y axis
            %   and with a volume < 3000

            label(label > 0) = 1;
            COMy(COMy==0)=[];
            COMz(COMz==0)=[];
            volume(volume.Volume==0,:)=[];
            [label,~] = bwlabeln(label); % Re-labelize the remaning components


            [idx_Jy, m_Jy]=kmeans(COMy,2);

            mMaxJ = max(m_Jy);

            for i=1:length(idx_Jy)
                indexLabel=find(COMy==COMy(i));
                if COMy(i)>mMaxJ && volume.Volume(indexLabel)<3000
                    COMy(indexLabel)=0;
                    COMz(indexLabel)=0;
                    volume(indexLabel,:)={0};
                    label(label==indexLabel)=0;
                end
            end


            % Remove the mollars
            
            if RemoveMollars == 1
                label(label > 0) = 1;
                COMy(COMy==0)=[];
                COMz(COMz==0)=[];
                volume(volume.Volume==0,:)=[];
                [label,~] = bwlabeln(label); % Re-labelize the remaning components

                if length(COMy)>12
                    [~,m]=kmeans(COMy,2);
                    mMax = max(m);
                    threshold = (mMax+max(COMy(COMy>mMax)))/2;
                    for i=1:length(COMy)
                        indexLabel=find(COMy==COMy(i));
                        if COMy(i)>threshold
                            COMy(indexLabel)=0;
                            COMz(indexLabel)=0;
                            volume(indexLabel,:)={0};
                            label(label==indexLabel)=0;
                        end
                    end
                end
            end
        end



        %% Case with 2 jaws


        if ULjaw 

            % Remove the components that are too far from the mean
            % 100 // 60 => 80
            % 100-80 = a
            % comz-80 = b
            % compare a and b with a ration


            for i=1:length(idx)
                if idx(i)==find(m==mMax)
                    if (mMax/COMz(i)>1.15 || mMax/COMz(i)<0.85) ...
                            && volume.Volume(i)<3000
                        COMy(i)=0;
                        COMz(i)=0;
                        volume(i,:)={0};
                        label(label == i) = 0;
                    end

                elseif idx(i)==find(m==mMin)
                    if (mMin/COMz(i)>1.15 || mMin/COMz(i)<0.85) ...
                            && volume.Volume(i)<3000
                        COMy(i)=0;
                        COMz(i)=0;
                        volume(i,:)={0};
                        label(label == i) = 0; 
                    end
                end   
            end



            % Remove components that are too far from the y axis
            %   and with a volume < 3000

            label(label > 0) = 1;
            COMy(COMy==0)=[];
            COMz(COMz==0)=[];
            volume(volume.Volume==0,:)=[];
            [label,~] = bwlabeln(label); % Re-labelize the remaning components


            [idx, m] = kmeans(COMz, 2);
            mMax = max(m);
            mMin = min(m);

            LJ_y=[];
            UJ_y=[];

            for i=1:length(idx)
                if idx(i)==find(m==mMin)
                    LJ_y=[LJ_y;COMy(i)];

                elseif idx(i)==find(m==mMax)
                    UJ_y=[UJ_y;COMy(i)]; 
                end
            end


            [idx_Ly, m_Ly]=kmeans(LJ_y,2);
            [idx_Uy, m_Uy]=kmeans(UJ_y,2);

            mMaxL = max(m_Ly);
            mMaxU = max(m_Uy);

            for i=1:length(idx_Ly)
                indexLabel=find(COMy==LJ_y(i));
                if LJ_y(i)>mMaxL && volume.Volume(indexLabel)<3000
                    LJ_y(i)=0;
                    COMy(indexLabel)=0;
                    COMz(indexLabel)=0;
                    volume(indexLabel,:)={0};
                    label(label==indexLabel)=0;
                end
            end

            for i=1:length(idx_Uy)
                indexLabel=find(COMy==UJ_y(i));
                if UJ_y(i)>mMaxU && volume.Volume(indexLabel)<3000
                    UJ_y(i)=0;
                    COMy(indexLabel)=0;
                    COMz(indexLabel)=0;
                    volume(indexLabel,:)={0};
                    label(label==indexLabel)=0;
                end
            end



            % Remove the mollars

            if RemoveMollars == 1
                label(label > 0) = 1;
                LJ_y(LJ_y==0)=[];
                UJ_y(UJ_y==0)=[];
                COMy(COMy==0)=[];
                COMz(COMz==0)=[];
                volume(volume.Volume==0,:)=[];
                [label,~] = bwlabeln(label); % Re-labelize the remaning components

                if length(LJ_y)>12
                    [~,m]=kmeans(LJ_y,2);
                    mMax = max(m);
                    threshold = (mMax+max(LJ_y(LJ_y>mMax)))/2;
                    % enlever la loop pas besoin ==> prendre les 2 maximums
                    for i=1:length(LJ_y)
                        indexLabel=find(COMy==LJ_y(i));
                        if LJ_y(i)>threshold
                            COMy(indexLabel)=0;
                            COMz(indexLabel)=0;
                            volume(indexLabel,:)={0};
                            label(label==indexLabel)=0;
                        end
                    end
                end
            end

            if length(UJ_y)>12
                [~,m]=kmeans(UJ_y,2);
                mMax = max(m);
                threshold2 = (mMax+max(UJ_y(UJ_y>mMax)))/2;
                for i=1:length(UJ_y)
                    indexLabel=find(COMy==UJ_y(i));
                    if UJ_y(i)>threshold2
                        COMy(indexLabel)=0;
                        COMz(indexLabel)=0;
                        volume(indexLabel,:)={0};
                        label(label==indexLabel)=0;
                    end
                end
            end
        end



        %% Write the scan


        label(label > 0) = 1;
        COMy(COMy==0)=[];
        COMz(COMz==0)=[];
        volume(volume.Volume==0,:)=[];
        [label,~] = bwlabeln(label); % Re-labelize the remaning components

        [idx, m] = kmeans(COMz, 2);
        mMax = max(m);
        mMin = min(m);

        
        RemoveJaw = true;
        if mMax/mMin > 1.2
            RemoveJaw = false;
            
            % Lower
            label_lower = label;
            for i=1:length(idx)
                if idx(i)==find(m==mMax)
                    label_lower(label_lower==i)=0;
                end
            end
            
            label_lower(label_lower > 0) = 1;
            [label_lower,n] = bwlabeln(label_lower); % Re-labelize the remaning components
            label_lower(label_lower > 0) = 1;
            NbrRootcanal = n;

            disp(['Number of root canal found Lower: ', num2str(NbrRootcanal)])
            outname_lower = strcat(output_dir, strrep(fileName, 'rec', 'DPS'));
            outname_lower = strrep(outname_lower, 'scan', 'scan_lower');
            disp(['Writing ' outname_lower])
            disp(' ')

            [Spacing, Origin] = GetSpacingOriginFromNrrd(recFile);
            label_lower = int16(label_lower);
            nrrdWriter(outname_lower, label_lower, Spacing, Origin, 'raw');
            gzip(outname_lower);
            delete(outname_lower);
            
            
            % Upper
            label_upper = label;
            for i=1:length(idx)
                if idx(i)==find(m==mMax)
                    label_upper(label_upper==i)=0;
                end
            end
            
            label_upper(label_upper > 0) = 1;
            [label_upper,n] = bwlabeln(label_upper); % Re-labelize the remaning components
            label_upper(label_upper > 0) = 1;
            NbrRootcanal = n;

            disp(['Number of root canal found Upper: ', num2str(NbrRootcanal)])
            outname_upper = strcat(output_dir, strrep(fileName, 'rec', 'DPS'));
            outname_upper = strrep(outname_upper, 'scan', 'scan_upper');
            disp(['Writing ' outname_upper])
            disp(' ')

            [Spacing, Origin] = GetSpacingOriginFromNrrd(recFile);
            label_upper = int16(label_upper);
            nrrdWriter(outname_upper, label_upper, Spacing, Origin, 'raw');
            gzip(outname_upper);
            delete(outname_upper);
            
            delete(recFile);

            
            
%             if k<=40  % <===============================
%                 for i=1:length(idx)
%                     if idx(i)==find(m==mMax)
%                         label(label==i)=0;
%                     end
%                 end
% 
%             elseif k>40 % <===============================
%                 for i=1:length(idx)
%                     if idx(i)==find(m==mMin)
%                         label(label==i)=0;
%                     end
%                 end
%             end
        end
        

        if RemoveJaw
            label(label > 0) = 1;
%             COMy(COMy==0)=[];
%             COMz(COMz==0)=[];
%             volume(volume.Volume==0,:)=[];
            [label,n] = bwlabeln(label); % Re-labelize the remaning components
            label(label > 0) = 1;
            NbrRootcanal = n;


            disp(['Number of root canal found: ', num2str(NbrRootcanal)])
            outname = strcat(output_dir, strrep(fileName, 'rec', 'DPS'));
            disp(['Writing ' outname])
            disp(' ')

            [Spacing, Origin] = GetSpacingOriginFromNrrd(recFile);
            label = int16(label);
            nrrdWriter(outname, label, Spacing, Origin, 'raw');
            gzip(outname);
            delete(outname);
            delete(recFile);
        end
    end
end
