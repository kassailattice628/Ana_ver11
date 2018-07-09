function Plot_All_Averages(~,~, cmin, cmax)
%%%%%%%%%%
% Show Matrix for averaged traces for all ROI
%%%%%%%%%

global imgobj
global sobj
%%%%%%%%%%

%%
if ~isfield(imgobj, 'dFF_s_ave')
    errordlg(' Get Trial Averages!!')
end

%%
c_min = str2double(get(cmin, 'string'));
c_max = str2double(get(cmax, 'string'));

datap = size(imgobj.dFF_s_ave, 1);

% transform 3D-mat into 2D-mat
mat = zeros(5 + datap, size(imgobj.dFF_s_ave,2), size(imgobj.dFF_s_ave,3));
mat(1:datap,:,:) =  imgobj.dFF_s_ave;
imgobj.mat2D = reshape(mat, [], imgobj.maxROIs);

%% show averages
switch sobj.pattern
    case 'Size_rand'
        %use 1:5 (0.5d. 1d, 3d, 5d, 10d)
        imgobj.mat2D = imgobj.mat2D(1:5*(5+datap), :);
        %sort was done in GetTuned_ROI.m, MoveBar Get_Tuned_ROI ‚Å sort
        %‚µ‚½•û‚ª‚¢‚¢‚©‚à
        mat2D = imgobj.mat2D(:, imgobj.mat2D_i_sort );
        
    case 'MoveBar'
        [mat2D, imgobj.mat2D_i_sort] = sort_mat(imgobj.mat2D);
        
end

show_mat(mat2D)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% subfunctions plot %%
    function show_mat(mat)
        figure
        imagesc(mat')
        caxis([c_min, c_max])
        ylabel('Neuron#')
        xlabel('data point')
    end

%% sort by pref direction
    function [mat2, i] = sort_mat(mat)
        %positive or negative roi
        rois_max = max(nanmean(imgobj.dFF_s_each));
        rois_valid = find(rois_max > 0.15);
        
        rois_n = intersect(rois_valid, imgobj.roi_nega_R);
        rois_p = intersect(rois_valid, imgobj.roi_pos_R);
        rois_nores = setdiff(rois_valid, 1:imgobj.maxROIs);
        %
        
        %find pref direction
        [~, i_sort] = sort(imgobj.Ang_dir(rois_p));
        i = [rois_p(i_sort); rois_n; rois_nores];
        mat2 = mat(:, i);
    end
end