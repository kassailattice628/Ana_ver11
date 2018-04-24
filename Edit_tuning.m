%function Edit_tuning
%%%%%%%%%%
%
% Edit imgobj.dFF_s_eahc
%
%%%%%%%%%%

%::::: How to use :::::%
%{
DS is more than 0.2
find(imgobj.L_dir > 0.5)
find(imgobj.L_dir > 0.4 & imgobj.L_dir <= 0.5)
find(imgobj.L_dir > 0.3 & imgobj.L_dir <= 0.4)
find(imgobj.L_dir > 0.2 & imgobj.L_dir <= 0.3)

%OS is more than 0.15
setdiff(intersect(find(imgobj.L_ori > 0.15), imgobj.roi_res), find(imgobj.L_dir > 0.2))

% Find DS or OS rois
% Check tuning (from GUI) 
% If finding abnormal peak values, run following scripts to delete and
% re-calculate tuning indices.

%}

%%
% copy data
data = imgobj.dFF_s_each;
%roi 
i =  105;

%201, 117, 41, 67, 105, 20, 138, 221, 213, 212, 232, 30, 
% 73, 52, 125, 131, 

%5ÅiîΩì]ÅHÅj, 109, 173

% check dFF_s_each (peak values of individual trials)
Delete_event(data, 1, 1, i);
 
disp(data(:,:,i))

%% Edit data
% if the strange data points were found, manually delete the data point

r = [4, 4];% stim
c = [1, 4];% trial 

[s_ave, s_each] = Mod_Trial_Averages(i, r, c);

%check
data(:,:,i) = s_each;
Delete_event(data, 1, 1, i);
 
disp(data(:,:,i))

%% if OK, apply to imgobj, run follows

imgobj.dFF_s_ave(:,:, i) = s_ave;
imgobj.dFF_s_each(:,:, i) = s_each;

% Get stimulus specific tuning properties

Get_Stim_Tuning;

% Get tuning parameters

Get_Tuned_ROI;