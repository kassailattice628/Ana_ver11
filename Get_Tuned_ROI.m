function Get_Tuned_ROI
%%%%%%%%%%
%
% Extract tuning selective roi
% This function is called in Get_Trial_Averages.m
%
% roi_pos_R, roi_nega_R and dFF_s_each are ectracted in
% Get_Trial_Averages.m
%
%%%%%%%%%%

global imgobj
global sobj

%%
all = 1:imgobj.maxROIs;
thres = 0.15;
th_ori = 0.15;
th_dir = 0.2;

%% responding/no-responding roi

R_max = max(nanmean(imgobj.dFF_s_each));

% non responding cells
roi_nores = find(R_max <= thres);

% responding cells
roi_res = setdiff(all, roi_nores);

%% selective roi
switch sobj.pattern
    case 'MoveBar'
        % Orientation
        
        roi_ori = intersect(roi_res, find(imgobj.L_ori >= th_ori));
        roi_dir = intersect(roi_res, find(imgobj.L_dir >= th_dir));
        
        imgobj.roi_ori_sel = roi_ori;
        imgobj.roi_dir_sel = roi_dir;
        imgobj.roi_non_sel = setdiff(roi_res, union(roi_ori, roi_dir));
        
end

%% update imgobj

imgobj.R_max = reshape(R_max, [1, imgobj.maxROIs]);
imgobj.roi_res = roi_res;
imgobj.roi_no_res = roi_nores;


end