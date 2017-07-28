function dirname = Batch_Save_dFFmat(varargin)
%Batch extract dFF from dFF.mat data using roiset.zip
addpath('/Users/lattice/Dropbox/None_But_Air/Ana_ver11/');

switch nargin
    case 1
        dir_name = varargin(1);
    case 0
        dir_name = [];
end
[dirname, ~, ext, fsuf, psuf] = Get_File_Name(dir_name);
files = dir(fullfile(dirname, '*.mat'));

%n_file = 3:7;
for n = 1:size(files, 1)
    if files(n).bytes > 0
        i1 = regexp(files(n).name,'\d*');
        i2 = regexp(files(n).name,'_');
        fn = files(n).name(i1(1):i2(1)-1);
        %generate file names
        mat_name = [dirname, fsuf, fn, psuf, ext];
        save_name = [dirname, fsuf, fn, '_dFF.mat'];
        roi_name = [dirname, fsuf, fn, '_RoiSet.zip'];
        
        if exist(save_name, 'file') 
            disp([fsuf, fn, '_dFF.mat is already exist! SKIP....'])
        elseif ~exist(roi_name, 'file')
            disp([fsuf, fn, '_RoiSet.zip is missing! SKIP....'])
        else
            
            %load mat
            %mat_name = [dirname, fsuf, fn, psuf, ext];
            y = load(mat_name);
            dFF = y.dFF;
            nFRMs = size(dFF,3);
            disp(['dFF Loading::: ', mat_name]);
            %load roi
            %roi_name = [dirname, fsuf, fn, '_RoiSet.zip'];
            ROIs = ReadImageJROI(roi_name);
            nROIs = size(ROIs,2);
            
            c = cell(nROIs, 1);
            r = cell(nROIs, 2);
            disp(['ROI Loading::: ', roi_name]);
            
            %%% make Mask of each ROI %%%
            M = false(size(dFF, 1), size(dFF, 2), nROIs);
            for i =  1:nROIs
                c{i} = [ROIs{1, i}.mnCoordinates(:,1); ROIs{1,i}.mnCoordinates(1,1)];
                r{i} = [ROIs{1, i}.mnCoordinates(:,2); ROIs{1,i}.mnCoordinates(1,2)];
                %complete masks for each roi
                M(:,:,i) = poly2mask(c{i}, r{i}, size(dFF, 1), size(dFF, 2));
            end
            
            %%%%%%%%%%
            dFF = reshape(dFF, [], nFRMs);
            M = reshape(M, [], nROIs);
            %%%%%%%%%%
            
            dFF_mat = zeros(nFRMs, nROIs);
            for i = 1:nROIs
                dFF_mat(:,i) = mean(dFF(M(:,i)>0, :));
            end
            
            
            %% save as mat
            %save_name = [dirname, fsuf, fn, '_dFF.mat'];
            save(save_name, 'dFF_mat');
            disp(['saved::: ', save_name]);
        end
    end
end
end