function Get_Trial_Averages_orientation
%%%%%%%%%%%%%%%%%%%%
% Get traial averages for each stimulus
% Do I need over-sampling?
%
% s_ave :: trial average
% s_each :: peak values for each trial
% imgobj.dFF_s_mean :: mean values from dFF_s_each
%
% Separate plot part (180406)
% To modulate each roi, add, specifying roi number.
%
% For Moving bar stimulus, averages are calculated based on the bar orientation
%
%%%%%%%%%%

global sobj
global imgobj
global recobj
global ParamsSave

%%%%%%%%%%

%% ini: stim-ON frame number
frame_stimON = nan(size(ParamsSave, 2) - recobj.prestim, 1);
stim = frame_stimON;

%% gather trials with same stimulus type
for i = (recobj.prestim + 1) : size(ParamsSave, 2)
    if isfield(ParamsSave{1,i}, 'stim1') && isfield(ParamsSave{1,i}.stim1, 'corON')
        %find nearest frame for stim ON
        frame_stimON(i - recobj.prestim) = floor((ParamsSave{1,i}.stim1.corON)/imgobj.FVsampt);
        
        %stim specific index
        switch sobj.pattern
            
            case {'MoveBar', 'MoveSpot'}
                ori_deg = wrapTo360((ParamsSave{1, i}.stim1.MovebarDir_angle_deg + 90) * 2)/2;
                if ori_deg == 180
                    ori_deg = 0;
                end
                stim(i - recobj.prestim) = ori_deg;
                
        end
    else
        frame_stimON(i - recobj.prestim) = nan;
        stim(i - recobj.prestim) = nan;
    end
end

%%
%[prep, postp, p_on, p_off, datap] = Def_len_datap;
[prep, ~, ~, p_off, datap] = Def_len_datap;

%%
stim_list = unique(stim, 'rows');

stim_list(isnan(stim_list)) = [];
nstim = size(stim_list, 1); %the number of stimuli

%% Get stim average for all ROIs

% prepare matrix for averaged dFF
s_ave = zeros(datap, nstim, imgobj.maxROIs);

% prepare matrix for max value for each trials of each stimuluss
s_each = NaN([35, nstim, imgobj.maxROIs]);
R_each_pos = s_each;
R_each_neg = s_each;
roi_p = [];
roi_n = [];

%%

%%
rois = 1:imgobj.maxROIs;

for i = rois %%%%% i for each ROI
    if isnan(imgobj.dFF(1, i))
        %skip no-data ROIs
        disp(['ROI# ', num2str(i), ' has no data.'])
        continue;
    end
    
    for i2 = 1:nstim %%%% i2 for each stimulus
        i_list = ismember(stim, stim_list(i2, :), 'rows');
        i_ext_stim = find(i_list);
        dFF_ext = zeros(datap, length(i_ext_stim));
        %%%%%%%%%%
        skip_i = [];
        for i3 = 1:length(i_ext_stim) %%%% i3 for each trial
            ext_fs = frame_stimON(i_ext_stim(i3)) -(prep) : frame_stimON(i_ext_stim(i3)) + p_off;
            
            %%%% raw data
            if min(ext_fs) <= 0
                skip_i = [skip_i, i3];
                
            elseif max(ext_fs) <= size(imgobj.dFF, 1)
                %disp(ext_fs)
                dFF_ext(:, i3) = imgobj.dFF(ext_fs, i);
                
                
                R_each_pos(i3, i2, i) = max(dFF_ext(:,i3)) - mean(dFF_ext(1:2, i3));
                R_each_neg(i3, i2, i) = min(dFF_ext(:,i3)) - mean(dFF_ext(1:2, i3));
            else
                dFF_ext = dFF_ext(:, 1:i3-1);
                break;
            end
        end
        dFF_ext(:, skip_i) = [];
        
        %%%% mean traces for each stimulus, each ROI
        a = mean(dFF_ext, 2);
        s_ave(:, i2, i) = a - a(1); %offset
    end
    
    R_max = max(max(s_ave(:,:,i)));
    R_min = min(min(s_ave(:,:,i)));
    % ‚±‚Ì  ROI ‚ª excitation ‚© inhibition ‚©”»’è‚·‚é
    if abs(R_max) >= abs(R_min)
        roi_p = [roi_p, i];
        s_each(:,:,i) = R_each_pos(:,:,i);
    else
        roi_n = [roi_n, i];
        s_each(:,:,i) = -R_each_neg(:,:,i);
    end
    
end

%% delete motion? artifact or non reproducible event?

%s_each = Delete_event(s_each);

%% Set imgobj params

switch sobj.pattern 
    case 'StaticBar'
        imgobj.dFF_s_ave_ori = imgobj.dFF_s_ave;
        imgobj.dFF_s_each_ori = imgobj.dFF_s_each;
    otherwise
        imgobj.dFF_s_ave_ori = s_ave;
        imgobj.dFF_s_each_ori = s_each;
end

disp('Trial averages for orientation.')
end