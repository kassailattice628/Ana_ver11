function Open_2P(hfig_handle, p, r, s)
global hfig
global imgobj
%%
h_name = 'two_photon';
hfig.two_photon = figure('Position', [10, 20, 1100, 500], 'Name', 'Two-photon Traces',...
    'NumberTitle', 'off', 'Menubar', 'none', 'Resize', 'off',...
    'DeleteFcn', {@Close_subwindow, hfig_handle, h_name},...
    'KeyPressFcn', @callback_keypress);

%% panel1
p_roi =  uipanel('Title', 'ROI traces', 'FontSize', 12, 'Position', [0.01 0.89, 0.95, 0.1]);
% Load DATA
uicontrol('Parent', p_roi, 'Style', 'pushbutton', 'String', 'Load dFF', 'Position', [10, 5, 100, 30],...
    'Callback', {@Load2P, s}, 'FontSize', 14);

uicontrol('Parent', p_roi, 'Style', 'edit', 'String', imgobj.FVsampt, 'Position', [120, 7, 100, 25],...
    'Callback', {@Change_sampt}, 'FontSize', 14);

uicontrol('Parent', p_roi, 'Style', 'text', 'String', 's/Flame', 'Position', [225, 2, 50, 20], 'FontSize', 12);
% ROI select
uicontrol('Parent', p_roi, 'Style', 'pushbutton', 'String', '+', 'Position', [285, 5, 50, 30],...
    'Callback', {@Plot_dFF_next, 1}, 'FontSize', 14);
uicontrol('Parent', p_roi, 'Style', 'pushbutton', 'String', '-', 'Position', [340, 5, 50, 30],...
    'Callback', {@Plot_dFF_next, -1}, 'FontSize', 14);
uicontrol('Parent', p_roi, 'Style', 'text', 'String', '#:', 'Position', [400, 2, 20, 25], 'FontSize', 14);
hfig.two_photon_set_roi_n = uicontrol('Parent', p_roi, 'Style', 'edit', 'String', 1, 'Position', [420, 7, 50, 25],...
    'Callback', {@Plot_dFF_next, 0}, 'FontSize', 14, 'BackGroundColor', 'w');

uicontrol('Parent', p_roi, 'Style', 'text', 'String', 'Select', 'Position', [490, 2, 50, 25], 'FontSize', 14);
hfig.two_photon_select_roi_n = uicontrol('Parent', p_roi, 'Style', 'edit', 'String', 1, 'Position', [545, 7, 200, 25],...
    'Callback', @Plot_dFF_selectROIs, 'FontSize', 14, 'BackGroundColor', 'w');

uicontrol('Parent', p_roi, 'Style', 'text', 'String', 'Deselect', 'Position', [750, 2, 70, 25], 'FontSize', 14);
hfig.two_photon_deselect_roi_n = uicontrol('Parent', p_roi, 'Style', 'edit', 'String', '', 'Position', [825, 7, 150, 25],...
    'Callback', @Plot_dFF_selectROIs, 'FontSize', 14, 'BackGroundColor', 'w');

%% Behavior check
uicontrol('Style', 'pushbutton', 'String', 'Saccade', 'Position', [10, 420, 100, 25],...
    'Callback', {@Get_Plot_sac_timing, p}, 'FontSize', 14');


uicontrol('Style', 'pushbutton', 'String', 'Locomotion', 'Position', [115, 420, 100, 25],...
    'Callback', {@Get_Plot_locomotion_timing, r, p}, 'FontSize', 14');

%% plot1:: Single ROI
hfig.two_photon_axes1 = axes('Units', 'Pixels', 'Position', [70, 290, 600, 120]);
Get_Plot_stim_timing(r, p);

hold on
hfig.two_photon_plot1 = plot(NaN, NaN);
set(hfig.two_photon_plot1, 'Parent', hfig.two_photon_axes1);
hold off

set(hfig.two_photon_axes1, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [],...
    'YLimMode', 'manual', 'YLim', [-0.5, 3.5]);
title('Single ROI', 'FontSize', 14)
ylabel(hfig.two_photon_axes1, 'dF/F0')
%% plot2:: Multiple ROIs (selected)
hfig.two_photon_axes2 = axes('Units', 'Pixels', 'Position', [70, 50, 600, 200]);
Get_Plot_stim_timing(r, p);

set(hfig.two_photon_axes2, 'XLimMode', 'manual', 'XLim', [-inf, inf],...
    'YLimMode', 'manual', 'YLim', [-0.5, 3.5]);
title('Select ROIs', 'FontSize', 14)
ylabel(hfig.two_photon_axes2, 'dF/F0')
xlabel(hfig.two_photon_axes2, 'Time (sec)');


%% %%%%%%
if ~isempty(imgobj.dFF) || ~isfield(imgobj, 'dFF')
    [FVflames, imgobj.maxROIs] = size(imgobj.dFF);
    imgobj.FVt = 0:imgobj.FVsampt:imgobj.FVsampt*(FVflames-1);
    Plot_dFF_next([], [], 0)
    Plot_dFF_selectROIs([], [])
    OpenPanel2(hfig, imgobj, s)
end


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% subfunctions
function Load2P(~,~, s)
global imgobj
global mainvar
global hfig

%%
if isfield(imgobj, 'dFF')
    imgobj = rmfield(imgobj, 'dFF');
end

if isfield(imgobj,'dFF_s_ave')
    fields = {'dFF_s_ave'};
    imgobj = rmfield(imgobj, fields);
end

if isfield(imgobj,'dFF_s_ave_os')
    fields = {'dFF_s_ave_os'};
    imgobj = rmfield(imgobj, fields);
end

if isfield(imgobj,'dFF_s_each')
    fields = {'dFF_s_each'};
    imgobj = rmfield(imgobj, fields);
end

if isfield(imgobj,'Mask_rois')
    fields = {'Mask_rois', 'centroid'};
    imgobj = rmfield(imgobj, fields);
end
imgobj.nROI = 0;
imgobj.selectROI = 1;
imgobj.maxROIs =  1;

%%

if isfield(imgobj, 'dFF') == 0
    %update mainvar
    if isfield(mainvar, 'dirname2') && isnumeric(mainvar.dirname2) == 0
        [mainvar.fname2, mainvar.dirname2] = uigetfile({'*.csv; *.mat','Data Files'; '*.*','All Files' },...
            'Select Data(.csv, .mat)', mainvar.dirname2);
    else
        [mainvar.fname2, mainvar.dirname2] = uigetfile({'*.csv; *.mat','Data Files'; '*.*','All Files' },...
            'Select Data(.csv, .mat)', mainvar.dirname);
    end
    
    if mainvar.dirname == 0 %cancel select file
        %skip open file
    else
        Open_file(mainvar.dirname2, mainvar.fname2);
    end
else
    % 2P.xls is alread loaded the base workspace.
    % select another file
    [mainvar.fname2, mainvar.dirname2] = uigetfile({'*.csv; *.mat','Data Files'; '*.*','All Files' },...
        'Select Data(.csv, .mat)', mainvar.dirname2);
    Open_file(mainvar.dirname2, mainvar.fname2);
end

if isempty(imgobj.dFF)
    errordlg('dFF is missing!')
    %skip open file
else
    Plot_dFF_next([], [], 0)
    Plot_dFF_selectROIs([], [])
end

OpenPanel2(hfig, imgobj, s)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Open_file(d,f)
        
        if strcmp(f, 'Fall.mat')
            %data extracted from suite2P
            [imgobj.dFF, imgobj.Mask_rois, imgobj.centroid] = Load_Fall_suite2p(d,f);
        else
            [~,~,f_ext] = fileparts(f);
            
            if strcmp(f_ext, '.xls')
                imgobj.dFF = dlmread([d, f], '\t', 1, 1);
            elseif strcmp(f_ext, '.csv')
                imgobj.dFF = csvread([d,f], 1, 1);
            elseif strcmp(f_ext, '.mat')
                load([d,f], 'dFF_mat');
                imgobj.dFF = dFF_mat;
            end
        end
        imgobj.dFF_raw =  imgobj.dFF;
        [FVflames, imgobj.maxROIs] = size(imgobj.dFF);
        imgobj.FVt = 0:imgobj.FVsampt:imgobj.FVsampt*(FVflames-1);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
end

%% frame rate
function Change_sampt(h, ~)
global imgobj

imgobj.FVsampt = str2double(get(h, 'String'));
end

%% plot stim timing
function Get_Plot_stim_timing(r, p)
area_Y =  [-1, 10, 10, -1];
hold on
% get stim timing
for i =  r.prestim+1 : r.cycleCount
    if i <= size(p,2) && isfield(p{1,i},'stim1')
        if isfield(p{1,i}.stim1, 'corON')
            ON = p{1,i}.stim1.corON;
            OFF = p{1,i}.stim1.corOFF;
        else
            % corrected by signal from photo diode.
            ON = p{1,i}.AIStartTime + p{1,i}.stim1.On_time + p{1,i}.stim1.centerY_pix/1024/75;
            OFF = p{1,i}.AIStartTime + p{1,i}.stim1.Off_time + p{1,i}.stim1.centerY_pix/1024/75;
        end
        area_X = [ON, ON, OFF, OFF];
        fill(area_X, area_Y, [0.9 0.9 0.9], 'EdgeColor', 'none');
    end
end
hold off

end

%% plot saccade timing
function Get_Plot_sac_timing(~, ~, p)
global hfig


sac_t = [];
for i = 1:size(p,2)
    if isfield(p{i}, 'sac_t')
        sac_t = [sac_t, p{i}.sac_t];
    end
end


axes(hfig.two_photon_axes1)
hold on
for i = 1:length(sac_t)
    line([sac_t(i), sac_t(i)], [-1,6], 'Color', 'r');
end
hold off

end

%% plot locomotion timing
function Get_Plot_locomotion_timing(~, ~, r, p)
global hfig
global DataSave
global ParamsSave

area_t = [];

if ~isfield(ParamsSave{1,1}, 'loc_t')
    disp('read locomotion area...')
    tic
    for n = 1:size(p, 2)
        recTime = p{1,n}.AIStartTime:1/r.sampf...
            :p{1,n}.AIEndTime+1/r.sampf;
        
        [~, rotVel] = DecodeRot(DataSave(:, size(DataSave, 2), n), n, p, r);
        
        sig = rotVel > 1.5; %threshold;;;
        dsig = diff([0; sig]);
        s_i = find(dsig > 0);
        e_i = find(dsig < 0) -1;
        %len = s_i - e_i + 1;
        
        if length(s_i) == length(e_i)
            loc_t = [recTime(s_i); recTime(e_i)];
        else
            loc_t = [recTime(s_i); [recTime(e_i), recTime(end)]];
        end
        ParamsSave{1,n}.loc_t = loc_t';
        
        area_t = [area_t; loc_t'];
    end
    toc
else
    for n = 1:size(p,2)
        area_t = [area_t; ParamsSave{1,n}.loc_t];
    end
end

% locomotion area plot
axes(hfig.two_photon_axes1)
hold on
disp('plot locomotion area...')
tic
for n = 1:size(area_t,1)
    area_Y =  [-1, 10, 10, -1];
    area_X = [area_t(n,1), area_t(n,1), area_t(n,2), area_t(n,2)];
    fill(area_X, area_Y, [0 0 0.7], 'EdgeColor', 'none');
    %alpha(0.5)
end
hold off
toc

end



%% panel2
function OpenPanel2(~, imgobj, sobj)
global hfig
addpath('FigOnOFF');
%%
p_funcs = uipanel('Parent', hfig.two_photon, 'Title', 'Ctr', 'FontSize', 12, 'Position', [0.63 0.05 0.36 0.83]);
h_Detrend = uicontrol('Parent', p_funcs, 'Style', 'togglebutton', 'String', 'Detrend', 'Position', [5, 360, 100, 30], 'FontSize', 14);

h_LowCut =  uicontrol('Parent', p_funcs, 'Style', 'togglebutton', 'String', 'Low-Cut', 'Position', [115, 360, 100, 30], 'FontSize', 14);
LowCutFrq = 0.005;
h_LowCutFrq = uicontrol('Parent', p_funcs, 'Style', 'edit', 'String', LowCutFrq, 'Position', [225, 362, 80, 25],'FontSize', 14);
uicontrol('Parent', p_funcs, 'Style', 'text', 'String', 'Hz', 'Position', [305, 355, 30, 25], 'FontSize', 14);

h_Offset = uicontrol('Parent', p_funcs, 'Style', 'togglebutton', 'String', 'Offset', 'Position', [5, 325, 100, 30], 'FontSize', 14);
uicontrol('Parent', p_funcs, 'Style', 'text', 'String', 'F0 = 1:', 'Position', [115, 322, 60, 25], 'FontSize', 14);
if isfield(imgobj, 'f0')
    OffsetFrame = imgobj.f0;
else
    OffsetFrame = 1;
end
h_OffsetFrame = uicontrol('Parent', p_funcs, 'Style', 'edit', 'String', OffsetFrame, 'Position', [175, 327, 50, 25], 'FontSize', 14);

h_Norm = uicontrol('Parent', p_funcs, 'Style', 'togglebutton', 'String', 'Normalize', 'Position', [5, 290, 100, 30], 'FontSize', 14);

uicontrol('Parent', p_funcs, 'Style', 'text', 'String', 'C_min:', 'Position', [115, 287, 60, 25], 'FontSize', 14);
h_Cmin = uicontrol('Parent', p_funcs, 'Style', 'edit', 'String', -1, 'Position', [175, 292, 50, 25], 'FontSize', 14);
uicontrol('Parent', p_funcs, 'Style', 'text', 'String', 'C_max:', 'Position', [230, 287, 60, 25], 'FontSize', 14);
h_Cmax = uicontrol('Parent', p_funcs, 'Style', 'edit', 'String', 1, 'Position', [290, 292, 50, 25], 'FontSize', 14);

uicontrol('Parent', p_funcs, 'Style', 'pushbutton', 'String', 'Apply Mod to dFF', 'Position', [5, 255, 200, 30], 'FontSize', 14,...
    'Callback', {@Apply_change_dFF, h_Detrend, h_LowCut, h_LowCutFrq,...
    h_Offset, h_OffsetFrame, h_Norm});

%% Calculate trial f
uicontrol('Parent', p_funcs, 'Style', 'pushbutton', 'String', 'Average by Stim', 'Position', [210, 255, 140, 30], 'FontSize', 14,...
    'Callback', @Get_Trial_Averages, 'BackGroundColor', 'g')

%% plot figures
uicontrol('Parent', p_funcs, 'Style', 'pushbutton', 'String', 'Show selected', 'Position', [5, 220, 200, 30], 'FontSize', 14,...
    'Callback',  {@Plot_Selected_Averages, h_Cmin, h_Cmax})

uicontrol('Parent', p_funcs, 'Style', 'pushbutton', 'String', 'Show All', 'Position', [210, 220, 140, 30], 'FontSize', 14,...
    'Callback',  {@Plot_All_Averages, h_Cmin, h_Cmax})

%%
visible = 'on';
visible2 = 'off';

switch sobj.pattern
    case {'Uni', 'FineMap'}
        text_tuning = 'RF Tuning';
        visible2 = 'on';
    case 'Size_rand'
        text_tuning = 'Size Tuning';
        
    case {'Sin', 'Rect', 'Gabor', 'MoveBar', 'MoveSpot'}
        text_tuning = 'Show Tuning (Dir/Ori)';
        visible2 = 'on';
        
    case 'StaticBar'
        text_tuning = 'Show Tuning (Ori)';
        visible2 = 'on';
        
    case {'Images'}
        text_tuning = 'Image selectivity';
        
    otherwise
        text_tuning = '';
        visible = 'off';
end
uicontrol('Parent', p_funcs, 'Style', 'pushbutton', 'String', text_tuning, 'Position', [5, 185, 200, 30], 'FontSize', 14,...
    'Callback', @Plot_Stim_Tuning_selected, 'Visible', visible)

hfig.h_CB = uicontrol('Parent', p_funcs, 'Style', 'checkbox', 'String', 'plot', 'Position', [335, 185, 50, 30], 'FontSize', 12, 'Visible', visible2);
uicontrol('Parent', p_funcs, 'Style', 'pushbutton', 'String', 'Show Fits', 'Position', [210, 185, 120, 30], 'FontSize', 14,...
    'Callback', {@Get_Fit_params2, hfig.h_CB}, 'BackGroundColor', 'g', 'Visible', visible2)


uicontrol('Parent', p_funcs, 'Style', 'pushbutton', 'String', 'Show tuning Map', 'Position', [5, 150, 200, 30], 'FontSize', 14,...
    'Callback', {@Plot_Tuning_Distributions})


%% update params
uicontrol('Parent', p_funcs, 'Style', 'text', 'String', 'Add to name:', 'Position', [5, 3, 95, 25], 'FontSize', 14);
h_save_name = uicontrol('Parent', p_funcs, 'Style', 'edit', 'String', '_', 'Position', [100, 7, 50, 25], 'FontSize', 14);
uicontrol('Parent', p_funcs, 'Style', 'pushbutton', 'String', 'Update Params', 'Position', [155, 5, 150, 30], 'FontSize', 14,...
    'Callback', {@Update_Params, h_save_name})

end


%% modify trace
function Apply_change_dFF(~,~, h1, h2, h_freq, h3, h_frames, h4)
global imgobj
%delete dFF field
%imgobj = rmfield(imgobj, 'dFF');

%% Detrend
if get(h1, 'value')
    dFF_mod = detrend(imgobj.dFF_raw);
else
    dFF_mod = imgobj.dFF_raw;
end

%% LowCutFilter
if get(h2, 'value')
    lowcutfreq = str2double(get(h_freq, 'string'));
    Fs = 1/imgobj.FVsampt;
    Fc = lowcutfreq;
    [b, a] = butter(2, Fc/Fs*2, 'high');
    dFF_mod = filtfilt(b, a, dFF_mod);
    %[dFF_mod, ~, ~] = filtbutter(2, lowcutfreq, 'high', 1/imgobj.FVsampt, dFF_mod);
end

%% Offset
if get(h3, 'value')
    F0frames = str2double(get(h_frames, 'string'));
    imgobj.f0 = F0frames; % update f0 info
    dFF_base= mean(dFF_mod(1:F0frames,:),1);
    for i = 1:imgobj.maxROIs
        dFF_mod(:,i) = dFF_mod(:,i) - dFF_base(i);
    end
end

%% Normalize
if get(h4, 'value')
    MaxdFF = max(dFF_mod);
    disp(size(dFF_mod))
    for i = 1:imgobj.maxROIs
        
        dFF_mod(:,i) = dFF_mod(:,i)/abs(MaxdFF(i));
        
    end
end
%%if
imgobj.dFF = dFF_mod;
Plot_dFF_next([],[],0);
end

%% Update parameters
function Update_Params(~,  ~, h)
global DataSave
global imgobj
global ParamsSave
global recobj
global sobj

global mainvar


if ~exist(mainvar.dirname, 'dir')
    mainvar.dirname = uigetdir;
    mainvar.dirname = [mainvar.dirname, '/'];
end
suf = get(h, 'string');
[~, name, ext] = fileparts(mainvar.fname);
save_name = [mainvar.dirname, name, suf, ext];
%update parameters

save(save_name, 'DataSave', 'imgobj', 'mainvar', 'ParamsSave', 'recobj', 'sobj');
%save save_name DataSave imgobj mainvar ParamsSave recobj sobj;

disp(['save as ', save_name]);

end

%% Use KeyPress
function callback_keypress(~, eventdata)
switch eventdata.Key
    case {'rightarrow', 'uparrow', 'return', 'space'}
        Plot_dFF_next([], [], 1);
    case {'leftarrow', 'downarrow', 'backspace'}
        Plot_dFF_next([], [], -1);
end
end
