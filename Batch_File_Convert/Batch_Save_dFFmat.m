function Batch_Save_dFFmat(varargin)
%Batch extract dFF from dFF.mat data using roiset.zip
addpath('/Users/lattice/Dropbox/None_But_Air/Ana_ver11/');

[dirname, ~, ext, fsuf, psuf] = Get_File_Name();

n_file = 2:9;

nn = 0;
for n = n_file
    nn = nn + 1;
    
    fn = num2str(n);
    
    %load mat
    mat_name = [dirname, fsuf, fn, psuf, ext];
    y = load(mat_name);
    dFF = y.dFF;
    nFRMs = size(dFF,3);
    disp(['dFF Loading::: ', mat_name]);
    %load roi
    roi_name = [dirname, fsuf, fn, '_RoiSet.zip'];
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
    save_name = [dirname, fsuf, fn, '_dFF.mat'];
    save(save_name, 'dFF_mat');
    disp(['saved::: ', save_name]);
end