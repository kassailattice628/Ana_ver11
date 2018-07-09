function [s_ave, s_each ] = Mod_Trial_Averages(k, r, c)
%%%%%%%%%%
%
% k =: selected roi
% r =: trial number
% c =: stim number
%
%%%%%%%%%%

global sobj
global imgobj
global recobj
global ParamsSave

%%%%%%%%%%
if nargin ~= 3
    errordlg('3 inputs are needed!!')
    
elseif length(r) ~= length(c)
    errordlg('The sizes of "r" and "c" is different!!')
end


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
            case {'Uni', 'Looming'}
                if strcmp(sobj.mode, 'Concentric')
                    %for concentric positions
                    if i == recobj.prestim + 1
                        stim = zeros(size(ParamsSave, 2) - recobj.prestim, 2);
                    end
                    stim(i - recobj.prestim, 1) = ParamsSave{1, i}.stim1.dist_deg;
                    stim(i - recobj.prestim, 2) = ParamsSave{1, i}.stim1.angle_deg;
                else
                    %for n x n position
                    stim(i - recobj.prestim) = ParamsSave{1, i}.stim1.center_position;
                end
                
            case '1P_Conc'
                if i == recobj.preztim + 1
                    stim = zeros(size(ParamsSave, 2) - recobj.prestim, 2);
                end
                stim(i - recobj.prestim, 1) = ParamsSave{1, i}.stim1.dist_deg;
                stim(i - recobj.prestim, 2) = ParamsSave{1, i}.stim1.angle_deg;
                
            case 'Size_rand'
                stim(i - recobj.prestim) = ParamsSave{1, i}.stim1.size_deg;
                
            case 'FineMap'
                stim(i - recobj.prestim) = ParamsSave{1, i}.stim1.center_position_FineMap;
                
            case 'MoveBar'
                stim(i - recobj.prestim) = ParamsSave{1, i}.stim1.MovebarDir_angle_deg;
                
            case 'Images'
                stim(i - recobj.prestim) = ParamsSave{1, i}.stim1.Image_index;
                
            case {'Rect', 'Sin', 'Gabor'}
                stim(i - recobj.prestim) = ParamsSave{1, i}.stim1.gratingAngle_deg;
                
            case 'BW'
                if i == recobj.prestim + 1
                    stim = zeros(size(ParamsSave, 2) - revobj.prestim, 3 );
                end
                stim(i - recobj.prestim, 1) = ParamsSave{1, i}.stim1.color;
                stim(i - recobj.prestim, 2) = ParamsSave{1, i}.stim1.dist_deg;
                stim(i - recobj.prestim, 3) = ParamsSave{1, i}.stim1.angle_deg;
        end %switch
    else
        frame_stimON(i - recobj.prestim) = nan;
        stim(i - recobj.prestim) = nan;
    end
end

%%
[prep, ~, ~, p_off, datap] = Def_len_datap;

%%

stim_list = unique(stim, 'rows');
stim_list(isnan(stim_list)) = [];
nstim = size(stim_list, 1); %the number of stimuli

%% Get stim average for the selected ROI (defined by "k")

% a matrix for averaged dFF
s_ave = zeros(datap, nstim);

% a matrix for max value for each trials of each stimulus
a = size(imgobj.dFF_s_each, 1);
s_each = NaN([a, nstim]);

% check positive peaks and negative peaks
R_each_pos = s_each;
R_each_neg = s_each;

%%
for i2 = 1:nstim %%%% i2 for each stimulus
    i_list = ismember(stim, stim_list(i2, :), 'rows');
    i_ext_stim = find(i_list);
    disp(i_ext_stim)
    % remove trials which containes abonormal? reponse...
    if ismember(i2, r)
        i = find(r==i2);
        i_ext_stim(c(i)) = [];
        for j = 1:length(i)
            disp(i_ext_stim)
            fprintf('Delete: stim= %d, trial= %d.\n', i2, c(i(j)));
        end
    end
    
    % a matrix for calc average, and detecting a peak respnose in the trial.
    dFF_ext = zeros(datap, length(i_ext_stim));
    %%%%%%%%%%
    skip_i = [];
    for i3 = 1:length(i_ext_stim) %%%% i3 for each trial
        
        ext_fs = (frame_stimON(i_ext_stim(i3)) - prep) : (frame_stimON(i_ext_stim(i3)) + p_off);
        if min(ext_fs) <= 0
            skip_i = [skip_i, i3];
            
        %%%% raw data
        elseif max(ext_fs) <= size(imgobj.dFF, 1)
            dFF_ext(:, i3) = imgobj.dFF(ext_fs, k);
            R_each_pos(i3, i2) = max(dFF_ext(:,i3)) - mean(dFF_ext(1:2, i3));
            R_each_neg(i3, i2) = min(dFF_ext(:,i3)) - mean(dFF_ext(1:2, i3));
        else
            dFF_ext = dFF_ext(:, 1:i3-1);
            break;
        end
    end
    dFF_ext(:, skip_i) = [];
    
    %%%% mean traces for each stimulus, each ROI
    a = nanmean(dFF_ext, 2);
    s_ave(:, i2) = a - a(1); %offset
end

%%

R_max = max(max(s_ave(:,:)));
R_min = min(min(s_ave(:,:)));

% ‚±‚Ì  ROI ‚ª excitation ‚© inhibition ‚©”»’è‚·‚é
if abs(R_max) >= abs(R_min)
    disp('pos')
    imgobj.roi_nega_R(imgobj.roi_nega_R == k) = [];
    imgobj.roi_pos_R = [imgobj.roi_pos_R, k];
    s_each(:,:) = R_each_pos(:,:);
else
    disp('nega')
    imgobj.roi_pos_R(imgobj.roi_pos_R == k) = [];
    imgobj.roi_nega_R = [imgobj.roi_nega_R, k];
    s_each(:,:) = -R_each_neg(:,:);
end
figure, imagesc(s_ave');

%%
disp(['ROI #', num2str(k), ' is manually modified'])
%% end of this function
end
