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
if ~isnumeric(cmin)
    c_min = str2double(get(cmin, 'string'));
    c_max = str2double(get(cmax, 'string'));
else
    c_min = cmin;
    c_max = cmax;
end

datap = size(imgobj.dFF_s_ave, 1);

% transform 3D-mat into 2D-mat
mat = zeros(5 + datap, size(imgobj.dFF_s_ave,2), size(imgobj.dFF_s_ave,3));
mat(1:datap,:,:) =  imgobj.dFF_s_ave;
imgobj.mat2D = reshape(mat, [], imgobj.maxROIs);

if isfield(imgobj, 'dFF_s_ave_ori')
    datap = size(imgobj.dFF_s_ave_ori,1);
    mat = zeros(5 + datap, size(imgobj.dFF_s_ave_ori,2), size(imgobj.dFF_s_ave,3));
    mat(1:datap,:,:) = imgobj.dFF_s_ave_ori;
    imgobj.mat2Dori = reshape(mat, [], imgobj.maxROIs);
end

%% show averages
switch sobj.pattern
    case {'Uni', 'FineMap'}
        mat2D = imgobj.mat2D;
        xlab = 'data point';
        
    case 'Size_rand'
        %use 1:5 (0.5d. 1d, 3d, 5d, 10d)
        imgobj.mat2D = imgobj.mat2D(1:7*(5+datap), :);
        %sort was done in GetTuned_ROI.m, MoveBar Get_Tuned_ROI で sort
        %した方がいいかも
        mat2D = imgobj.mat2D(:, imgobj.mat2D_i_sort );
        xlab = 'data point';
        
    case {'MoveBar', 'Rect'}
        [mat2D, imgobj.mat2D_i_sort] = sort_mat(imgobj.mat2D);
        xlab = 'Move Direction';
        
    case {'StaticBar'}
        mat2D=[];
        %[mat2D, imgobj.mat2Dori_i_sort] = sort_matori(imgobj.mat2D);
        %xlab = 'Bar Orientation';
        
end

if ~isempty(mat2D)
    show_mat(mat2D, xlab)
    addplot_selectivity
end

%% show OS average
switch sobj.pattern
    
    case {'MoveBar', 'Rect', 'StaticBar'}
        %addplot_selectivity
        if ~isempty(imgobj.mat2Dori)
            [mat2Dori, imgobj.mat2Dori_i_sort] = sort_matori(imgobj.mat2Dori);
        else
            [mat2Dori, imgobj.mat2Dori_i_sort] = sort_matori(imgobj.mat2D);
        end
        show_mat(mat2Dori, 'Bar Orientation')
        addplot_selectivity_ori
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% subfunctions plot %%
    function show_mat(mat, xlab)
        figure
        imagesc(mat')
        caxis([c_min, c_max])
        ylabel('Neuron#')
        xlabel(xlab)
    end

%% add plot DS
    function addplot_selectivity
        nstim = length(imgobj.directions);
        xlabelpos = (5+datap) * (1:nstim) - round((5+datap)/2);
        xticks(xlabelpos);
        xt = Xt_lab(nstim, 0);
        xticklabels(xt)
        
        hold on
        
        if isfield(imgobj, 'roi_ds')
            roi_ds = imgobj.roi_ds;
        else
            roi_ds = imgobj.roi_dir_sel;
        end
        %%%%%%%%%%
        if ~isempty(roi_ds)
            for i = roi_ds  %imgobj.roi_dir_sel
                ypos = find(imgobj.mat2D_i_sort == i);
                xpos = xlabelpos(knnsearch(imgobj.directions', imgobj.Ang_dir(i)));
                plot(xpos, ypos, 'ro')
            end
        end
        %%%%%%%%%%
        hold off
        
    end

%% add plot OS
    function addplot_selectivity_ori
        if isfield(imgobj, 'directions')
            nstim = length(imgobj.directions)/2;
            orientations = imgobj.directions(1:nstim/2);
        elseif isfield(imgobj, 'orientations')
            nstim = length(imgobj.orientations);
            orientations = imgobj.orientations;
        end
        
        xlabelpos = (5+datap) * (1:nstim) - round((5+datap)/2);
            
        xticks(xlabelpos);
        xt = Xt_lab(nstim, 1);
        xticklabels(xt)
        
        hold on
        
        if isfield(imgobj, 'roi_os')
            roi_os =  imgobj.roi_os;
        else
            roi_os = imgobj.roi_ori_sel;
        end
        %%%%%%%%%%
        if ~isempty(roi_os)
            for i = roi_os  %imgobj.roi_dir_sel
                ypos = find(imgobj.mat2Dori_i_sort == i);
                Ang_ori = imgobj.Ang_ori(i);
                if Ang_ori < 0
                    Ang_ori = Ang_ori + pi;
                end
                xpos = xlabelpos(knnsearch(orientations', Ang_ori));
                plot(xpos, ypos, 'bo')
            end
        end
        hold off
        
    end
%% sort by pref direction
    function [mat2, i] = sort_mat(mat)
        if ~isfield(imgobj, 'P_boot')
            %positive or negative roi
            rois_max = max(nanmean(imgobj.dFF_s_each));
            rois_valid = find(rois_max > 0.15);
            
            rois_n = intersect(rois_valid, imgobj.roi_nega_R);
            rois_p = intersect(rois_valid, imgobj.roi_pos_R);
            rois_nores = setdiff(1:imgobj.maxROIs, rois_valid');
            %
            
            %find pref direction
            [~, i_sort] = sort(imgobj.Ang_dir(rois_p));
            i = [rois_p(i_sort); rois_n; rois_nores'];
            mat2 = mat(:, i);
            
        else
            %sort order
            %1:DS -> Pref.Direction
            %2:Non-selective (一応 Tuning Angle 順に？）
            %3:Negative
            %4:No respondink
            roi_ds = imgobj.roi_ds;
            [~, i_ds_sort] = sort(imgobj.Ang_dir(roi_ds));
            
            roi_os = setdiff(imgobj.roi_os, imgobj.roi_ds);
            %            [~, i_os_sort] = sort(imgobj.Ang_ori(roi_os));
            
            roi_non_sel = setdiff(imgobj.roi_res, roi_ds);
            roi_non_sel = setdiff(roi_non_sel, roi_os);
            roi_non_sel = setdiff(roi_non_sel, imgobj.roi_nega_R);
            
            roi_nonselDS = [roi_os, roi_non_sel];
            [~, i_nonsel_sort] = sort(imgobj.Ang_dir(roi_nonselDS));
            
            %            i = [roi_ds(i_ds_sort), roi_os(i_os_sort), roi_non_sel,...
            %                imgobj.roi_nega_R, imgobj.roi_no_res'];
            i = [roi_ds(i_ds_sort), roi_nonselDS(i_nonsel_sort),...
                imgobj.roi_nega_R, imgobj.roi_no_res'];
            
            mat2 = mat(:, i);
        end
        
    end

%% sort by pref orientation
    function [mat2, i] = sort_matori(mat)
        if isfield(imgobj, 'Ang_ori')
            Ang_ori = imgobj.Ang_ori;
            Ang_ori(Ang_ori < 0) = Ang_ori(Ang_ori < 0) + pi;
        else
            Ang_ori = wrapTo2Pi(deg2rad(sobj.concentric_angle_deg_list) * 2)/2;
        end
        
        if ~isfield(imgobj, 'P_boot')
            %positive or negative roi
            rois_max = max(nanmean(imgobj.dFF_s_each_ori));
            rois_valid = find(rois_max > 0.15);
            
            rois_n = intersect(rois_valid, imgobj.roi_nega_R);
            rois_p = intersect(rois_valid, imgobj.roi_pos_R);
            rois_nores = setdiff(1:imgobj.maxROIs, rois_valid);
            %
            
            %find pref direction
            [~, i_sort] = sort(Ang_ori(rois_p));
            i = [rois_p(i_sort); rois_n; rois_nores'];
            mat2 = mat(:, i);
            
        else
            %sort order
            %1:OS -> Pref.Orientation
            %2:Non-selective (一応 Tuning Angle 順に？）
            %3:Negative
            %4:No respondink
            roi_os = imgobj.roi_os;
            
            [~, i_os_sort] = sort(Ang_ori(roi_os));
            
            roi_ds = setdiff(imgobj.roi_ds, imgobj.roi_os);
            %            [~, i_os_sort] = sort(imgobj.Ang_ori(roi_os));
            
            roi_non_sel = setdiff(imgobj.roi_res, roi_os);
            roi_non_sel = setdiff(roi_non_sel, roi_ds);
            roi_non_sel = setdiff(roi_non_sel, imgobj.roi_nega_R);
            
            roi_nonselOS = [roi_ds, roi_non_sel];
            [~, i_nonsel_sort] = sort(imgobj.Ang_ori(roi_nonselOS));
            
            roi_nega_R = setdiff(imgobj.roi_nega_R, roi_os);
            roi_nega_R = setdiff(roi_nega_R, roi_non_sel);
            
            %            i = [roi_ds(i_ds_sort), roi_os(i_os_sort), roi_non_sel,...
            %                imgobj.roi_nega_R, imgobj.roi_no_res'];
            i = [roi_os(i_os_sort), roi_nonselOS(i_nonsel_sort),...
                roi_nega_R, imgobj.roi_no_res'];
            
            mat2 = mat(:, i);
        end
        
    end
end