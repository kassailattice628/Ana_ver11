function Get_Trial_Averages(~, ~)
%%%%%%%%%%%%%%%%%%%%
% Get traial averages for each stimulus
% Do I need over-sampling?
%
% imgobj.dFF_s_ave :: trial average
% imgobj.dFF_s_each :: peak values for each trial
% imgobj.dFF_s_mean :: mean values from dFF_s_each
%
% Separate plot part (180406)

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

%set time point for stimulus average
%pre stimulus time befor 1 sec from stim ON
pret = 1; %sec
prep = ceil(pret/imgobj.FVsampt); %point

%Not use >> post stimulus time after *** sec from stim ON
%postt = recobj.rect/1000 + recobj.interval - 2; %sec
%postp = ceil(postt/imgobj.FVsampt); %

% stim duration
if strcmp(sobj.pattern, 'MoveBar')
    duration = max(sobj.moveDuration);
else
    duration = sobj.duration;
end

% to capture off reponse;
postp2 = round( (duration + 2) / imgobj.FVsampt);

% compare postp and postp2
% Use postp2
p_on = prep + 1;
p_off = p_on + postp2;

%data points for plot
datap = p_on + p_off;

%%

stim_list = unique(stim, 'rows');
stim_list(isnan(stim_list)) = [];
nstim = size(stim_list, 1); %the number of stimuli

%% Get stim average for all ROIs

% prepare matrix for averaged dFF
imgobj.dFF_s_ave = zeros(datap, nstim, imgobj.maxROIs);

% prepare matrix for max value for each trials of each stimuluss
imgobj.dFF_s_each = NaN([15, nstim, imgobj.maxROIs]);
R_each_pos = imgobj.dFF_s_each;
R_each_neg = imgobj.dFF_s_each;

for i = 1:imgobj.maxROIs %%%%% i for each ROI
    if isnan(imgobj.dFF(1, i))
        %skip no-data ROIs
        continue;
    end
    
    for i2 = 1:nstim %%%% i2 for each stimulus
        i_list = ismember(stim, stim_list(i2, :), 'rows');
        i_ext_stim = find(i_list);
        
        dFF_ext = zeros(datap, length(i_ext_stim));
        %%%%%%%%%%
        for i3 = 1:length(i_ext_stim) %%%% i3 for each trial
            ext_fs = frame_stimON(i_ext_stim(i3)) -(prep) : frame_stimON(i_ext_stim(i3)) + p_off;
            %%%% raw data
            if max(ext_fs) <= size(imgobj.dFF, 1)
                dFF_ext(:, i3) = imgobj.dFF(ext_fs, i);
            else
                dFF_ext = dFF_ext(:, 1:i3-1);
            end
            
            R_each_pos(i3, i2, i) = max(dFF_ext(:,i3)) - mean(dFF_ext(1:2, i3));
            R_each_neg(i3, i2, i) = min(dFF_ext(:,i3)) - mean(dFF_ext(1:2, i3));
        end
        
        %%%% mean traces for each stimulus, each ROI
        a = mean(dFF_ext, 2);
        imgobj.dFF_s_ave(:, i2, i) = a - a(1); %offset
    end
    
    R_max = max(max(imgobj.dFF_s_ave(:,:,i)));
    R_min = min(min(imgobj.dFF_s_ave(:,:,i)));
   % ‚±‚Ì  ROI ‚ª excitation ‚© inhibition ‚©”»’è‚·‚é
   if abs(R_max) >= abs(R_min)
       imgobj.dFF_s_each(:,:,i) = R_each_pos(:,:,i);
   else
       imgobj.dFF_s_each(:,:,i) = -R_each_neg(:,:,i);
   end
   
    
end

%% Get stimulus specific tuning properties

switch sobj.pattern
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    case 'Size_rand'
        % Best Size (for ON and OFF)
        imgobj.R_size = zeros(nstim, imgobj.maxROIs, 3);
        for i = 1:imgobj.maxROIs
            base = mean(imgobj.dFF_s_ave(1:2, :, i));
            
            %ON reponse
            imgobj.R_size(:, i, 1) = max(imgobj.dFF_s_ave(p_on:p_off, :, i) - base)';
            %OFF response
            imgobj.R_size(:, i, 2) = max(imgobj.dFF_s_ave(p_off:end, :, i) - base)';
            %All 
            imgobj.R_size(:, i, 3) = max(imgobj.dFF_s_ave(:, :, i) - base)';
        end
        
    case {'Sin', 'Rect', 'Gabor', 'MoveBar'}
        % Distribution of direction selectivity
        imgobj.L_ori = zeros(1, imgobj.maxROIs);
        imgobj.L_dir = zeros(1, imgobj.maxROIs);
        dir = linspace(0, (2*pi - 2*pi/nstim), nstim);
        
        for i = 1:imgobj.maxROIs
            %{
            % Orientation, Direction selectivity by vector averaging
            base = mean(imgobj.dFF_s_ave(1:2, :, i));
            R_all_dir_max = max(imgobj.dFF_s_ave(prep:end, :, i)) - base;
            R_all_dir_min = min(imgobj.dFF_s_ave(prep:end, :, i)) - base;
            
            % negative Ca response
            % How do I treat rebound excitation???
            if max(abs(R_all_dir_max)) >= max(abs(R_all_dir_min))
                R_all_dir = R_all_dir_max;
            else
                R_all_dir = -R_all_dir_min;
            end
            R_all_dir(R_all_dir < 0) = 0;
            
            %}
            
            R_all_dir = nanmean(imgobj.dFF_s_each(:, :, i));
            R_all_dir(R_all_dir < 0) = 0;
            %%%%%%%%%%
            % vector average for orientation
            %%%%%%%%%%
            Z = sum(R_all_dir .* exp(2*1i*dir))/sum(R_all_dir);
            imgobj.L_ori(i) = abs(Z);
                
            a = angle(Z)/2 + pi/2;
            if a > pi/2 && 3*pi/2 > a
                a = a - pi;
            end
            imgobj.Ang_ori(i) = a;
                
            
            %%%%%%%%%%
            % vector average for direction
            %%%%%%%%%%
            Z = sum(R_all_dir .* exp(1i*dir))/sum(R_all_dir);
            imgobj.L_dir(i) = abs(Z);
            imgobj.Ang_dir(i) = wrapTo2Pi(angle(Z));
        end
        
        
end

%%
disp('Trial averages and individual peak values are extracted.')
%% end of this function
end