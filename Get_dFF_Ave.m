function [stim_list, datap, datap_os, prep] = Get_dFF_Ave(mag_os)
%%%%%%%%%%%
% Get averaged traces for each stimulus.
% frame rate are over sampled *** times higher.
% Show Matrix plot for all ROI.
%%%%%%%%%%%
global sobj
global imgobj
global recobj
global ParamsSave
%%%%%%%%%%%

frame_stimON = zeros(size(ParamsSave,2) - recobj.prestim, 1);
frame_stimON_os = frame_stimON;
stim = frame_stimON;

%mag_os = 200;
sampt_os = imgobj.FVsampt/mag_os;

disp(recobj.prestim + 1)
disp(size(ParamsSave,2))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = (recobj.prestim + 1):size(ParamsSave,2)
    %nearest frame for stim onset
    if isfield(ParamsSave{1,i}.stim1, 'corON')
        frame_stimON(i-recobj.prestim) = floor((ParamsSave{1,i}.stim1.corON)/imgobj.FVsampt);
        frame_stimON_os(i-recobj.prestim) = floor((ParamsSave{1,i}.stim1.corON)/sampt_os);

    %stim specific index
    switch sobj.pattern
        case {'Uni', 'Looming'}
            if strcmp(sobj.mode, 'Concentric')
                if i == recobj.prestim + 1
                    stim = zeros(size(ParamsSave,2) - recobj.prestim, 2);
                end
                stim(i-recobj.prestim,1) = ParamsSave{1,i}.stim1.dist_deg;
                stim(i-recobj.prestim,2) = ParamsSave{1,i}.stim1.angle_deg;
            else
                stim(i-recobj.prestim) = ParamsSave{1,i}.stim1.center_position;
            end
        case {'1P_Conc'}
            if i == recobj.prestim + 1
                stim = zeros(size(ParamsSave,2) - recobj.prestim, 2);
            end
            stim(i-recobj.prestim,1) = ParamsSave{1,i}.stim1.dist_deg;
            stim(i-recobj.prestim,2) = ParamsSave{1,i}.stim1.angle_deg;
        case {'Size_rand'}
            stim(i-recobj.prestim) = ParamsSave{1,i}.stim1.size_deg;
        case {'FineMap'}
            stim(i-recobj.prestim) = ParamsSave{1,i}.stim1.center_position_FineMap;
        case {'MoveBar'}
            stim(i-recobj.prestim) = ParamsSave{1,i}.stim1.MovebarDir_angle_deg;
        case {'Images'}
            stim(i-recobj.prestim) = ParamsSave{1,i}.stim1.Image_index;
        case {'Rect', 'Sin', 'Gabor'}
            stim(i-recobj.prestim) = ParamsSave{1,i}.stim1.gratingAngle_deg;
        case {'B/W'}
            if i == recobj.prestim + 1
                stim = zeros(size(ParamsSave,2) - recobj.prestim, 3);
            end
            stim(i-recobj.prestim,1) = ParamsSave{1,i}.stim1.color;
            stim(i-recobj.prestim,2) = ParamsSave{1,i}.stim1.dist_deg;
            stim(i-recobj.prestim,3) = ParamsSave{1,i}.stim1.angle_deg;
    end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nframe = size(imgobj.dFF,1);
%Set time poitn for stimulus average

%pre-stimulus time befor 1sec from stim ON
pret = 1;
prep = ceil(pret/imgobj.FVsampt);

%post-stimulus time after **** sec from stim ON
postt = recobj.rect/1000 + recobj.interval - 2;
postp = ceil(postt/imgobj.FVsampt);

%data point for plot
datap = (prep + postp)+ 1;

%data point for oversampled data
datap_os = (prep + postp) * mag_os + 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stim_list = unique(stim, 'rows');
nstim = size(stim_list, 1);

%% Get_sitm_average for all ROI

%prep mat for dFF_Ave
imgobj.dFF_s_ave = zeros(datap, nstim, imgobj.maxROIs);

%prep mat for over-sampled dFF_Ave
imgobj.dFF_s_ave_os = zeros(datap_os, nstim, imgobj.maxROIs);

for i2 = 1:imgobj.maxROIs
    %%%%%%%%%%
    % i2 :: each ROI
    %%%%%%%%%%
    if isnan(imgobj.dFF(1,i2))
        continue;
    end
    dFF_os = interp1(0:nframe-1, imgobj.dFF(:,i2),...
        0:1/mag_os: nframe-1/mag_os, 'spline'); %'spline', 'nearest'
    
    for i = 1:nstim
        %%%%%%%%%%
        % i :: each stimlus
        %%%%%%%%%%
        i_list = ismember(stim, stim_list(i,:), 'rows');
        i_ext_stim = find(i_list);
        %%
        dFF_ext = zeros(datap, length(i_ext_stim));
        dFF_ext_os = zeros(datap_os, length(i_ext_stim) );
        for i3 = 1:length(i_ext_stim)
            %%%%%%%%%%
            % i3 :: each trials
            %%%%%%%%%%
            ext_fs = frame_stimON(i_ext_stim(i3)) - prep:frame_stimON(i_ext_stim(i3)) + postp;
            ext_fs_os = frame_stimON_os(i_ext_stim(i3)) - prep*mag_os:frame_stimON_os(i_ext_stim(i3)) + postp*mag_os;
            
            %%%%%
            if max(ext_fs) <= size(imgobj.dFF, 1)
                dFF_ext(:,i3) = imgobj.dFF(ext_fs, i2);
                
            elseif max(ext_fs) > size(imgobj.dFF,1)
                dFF_ext = dFF_ext(:, 1:i3-1);
            end
            %%%%%
            if max(ext_fs_os) <= size(dFF_os, 2)
                dFF_ext_os(:,i3) = dFF_os(ext_fs_os);
                
            elseif max(ext_fs_os) > size(dFF_os, 2)
                dFF_ext_os = dFF_ext_os(:, 1:i3-1);
                break;
            end
            %%%%%
            
        end
        
        %Get mean traces for each stimlus
        imgobj.dFF_s_ave(:,i, i2) = mean(dFF_ext, 2);
        imgobj.dFF_s_ave_os(:, i, i2) = mean(dFF_ext_os, 2);
        
    end
end