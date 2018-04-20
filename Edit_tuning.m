%function Edit_tuning
%%%%%%%%%%
%
% Edit imgobj.dFF_s_eahc
%
%%%%%%%%%%
% chelc selectivity

%DS is more than 0.2
%find(imgobj.L_dir > 0.5)
%find(imgobj.L_dir > 0.4 & imgobj.L_dir <= 0.5)
%find(imgobj.L_dir > 0.3 & imgobj.L_dir <= 0.4)
%find(imgobj.L_dir > 0.2 & imgobj.L_dir <= 0.3)

%OS is more than 0.15
%intersect(find(imgobj.L_ori > 0.15), imgobj.roi_res)

%%

% copy data
data = imgobj.dFF_s_each;
%roi 
i = 44;


%% check dFF_s_each (peak values of individual trials)
Delete_event(data, 1, 1, i);
 
disp(data(:,:,i))

%% Edit data
% if the strange data points were found, manually delete the data point

r = 4%[4, 2, 1];
c = 2%[4, 7, 9];
data(r, c, i) = NaN;
disp(data(:,:,i))
%% Apply to the original dFF_s_each
imgobj.dFF_s_each = data;
% re calc tuning properties
Get_Stim_Tuning(i);

Get_Tuned_ROI;




%% chnage roi_res to roi_non res
r = imgobj.roi_res;
r(r==i)= [];

if ismember(i, imgobj.roi_dir_sel)
    imgobj.roi_dir_sel(imgobj.roi_dir_sel==i) = [];
end

if ismember(i, imgobj.roi_ori_sel)
    imgobj.roi_ori_sel(imgobj.roi_ori_sel==i) = [];
end

imgobj.roi_no_res = [imgobj.roi_no_res; i];



