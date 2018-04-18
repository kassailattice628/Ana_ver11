%function Edit_tuning
%%%%%%%%%%
%
% Edit imgobj.dFF_s_eahc
%
%%%%%%%%%%
% chelc selectivity

%DS is more than 0.2
%find(imgobj.L_dir > 0.2 & imgobj.L_dir <= 0.3)

%OS is more than 0.15
%intersect(find(imgobj.L_ori > 0.15), imgobj.roi_res)

%%

% copy data
data = imgobj.dFF_s_each;
%roi 
i = 119% 150


%% check dFF_s_each (peak values of individual trials)
Delete_event(data, 1, 1, i);
 
disp(data(:,:,i))

%% Edit data
% if the strange data points were found, manually delete the data point

r = 2%[4, 2, 1];
c = 2%[4, 7, 9];
data(r, c, i) = NaN;
disp(data(:,:,i))
%% Apply to the original dFF_s_each
imgobj.dFF_s_each = data;
% re calc tuning properties
Get_Stim_Tuning(i);

Get_Tuned_ROI;



