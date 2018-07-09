%function Edit_tuning
%%%%%%%%%%
%
% Edit imgobj.dFF_s_eahc
%
%%%%%%%%%%
 
%::::: How to use :::::%
%{
%DS is more than 0.2
find(imgobj.L_dir > 0.5)
find(imgobj.L_dir > 0.4 & imgobj.L_dir <= 0.5)
find(imgobj.L_dir > 0.3 & imgobj.L_dir <= 0.4)
find(imgobj.L_dir > 0.2 & imgobj.L_dir <= 0.3)

%OS is more than 0.15
setdiff(intersect(find(imgobj.L_ori > 0.15), imgobj.roi_res), find(imgobj.L_dir > 0.2))

%Negative response
disp(imgobj.roi_nega_R)

% Find DS or OS rois
% Check tuning (from GUI) 
% If finding abnormal peak values, run following scripts to delete and
% re-calculate tuning indices.

% if you want to change roi from responded into non-responded, run
% Delete_roi.m
%}

%%
% copy data
data = imgobj.dFF_s_each;
%roi 
i = 45;
%30 24 6 

% check dFF_s_each (peak values of individual trials)
Delete_event(data, 1, 1, i);
 
disp(data(:,:,i))

%% Edit data
% if the strange data points were found, manually delete the data point

r = [4] ;% stim
c = [2 ] ;% trial 

[s_ave, s_each] = Mod_Trial_Averages(i, r, c);

%check
data(:,:,i) = s_each;

Delete_event(data, 1, 1, i);
disp(data(:,:,i))
% if OK, apply to imgobj, run follows

%%
imgobj.dFF_s_ave(:,:, i) = s_ave;
imgobj.dFF_s_each(:,:, i) = s_each;

% Get stimulus specific tuning properties

Get_Stim_Tuning;

% Get tuning parameters

Get_Tuned_ROI;

Plot_Stim_Tuning_selected;