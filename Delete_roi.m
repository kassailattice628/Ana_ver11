function Delete_roi(roi)
%%%%%%%%%%
%
% if the specified roi does not respond to the stinuli, but spontaneously
% showed learge response, the roi will be not suitable for analyze.
% Cnage responded roi to non-responded roi.
%
%%%%%%%%%%
global imgobj

%%
if nargin == 0
    roi = imgobj.selectROI;
end
%%

for i = 1:length(roi)
    %% add into the roi_no_res list
    if ~ismember(roi(i), imgobj.roi_no_res)
        imgobj.roi_no_res = [imgobj.roi_no_res; roi(i)];
    end
    
    
    %% remove from roi_res, roi_dir_sel, roi_ori_sel, roi_non_sel,
    % roi_pos_R, roi_nega_R
    imgobj.roi_res(imgobj.roi_res == roi(i)) = [];
    
    if ismember(roi(i), imgobj.roi_dir_sel)
        imgobj.roi_dir_sel(imgobj.roi_dir_sel == roi(i)) = [];
    end
    
    if ismember(roi(i), imgobj.roi_ori_sel)
        imgobj.roi_ori_sel(imgobj.roi_ori_sel == roi(i)) = [];
    end
    
    if ismember(roi(i), imgobj.roi_non_sel)
        imgobj.roi_non_sel(imgobj.roi_non_sel == roi(i)) = [];
    end
    
    if ismember(roi(i), imgobj.roi_pos_R)
        imgobj.roi_pos_R( imgobj.roi_pos_R == roi(i)) = [];
    end
    
    if ismember(roi(i), imgobj.roi_nega_R)
        imgobj.roi_nega_R(imgobj.roi_nega_R == roi(i)) = [];
    end
end

%%
end