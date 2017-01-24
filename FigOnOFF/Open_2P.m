function  Open_2P(hfig_handle, p, r)
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
uicontrol('Parent', p_roi, 'Style', 'pushbutton', 'String', 'Load Xls', 'Position', [10, 5, 100, 30],...
    'Callback', {@Load2P}, 'FontSize', 14);

uicontrol('Parent', p_roi, 'Style', 'edit', 'String', imgobj.FVsampt, 'Position', [120, 7, 100, 25],...
    'Callback', {}, 'FontSize', 14);

uicontrol('Parent', p_roi, 'Style', 'text', 'String', 's/Flame', 'Position', [225, 2, 50, 20], 'FontSize', 12);
% ROI select
uicontrol('Parent', p_roi, 'Style', 'pushbutton', 'String', '+', 'Position', [285, 5, 50, 30],...
    'Callback', {@Plot_dFF_next, 1}, 'FontSize', 14);
uicontrol('Parent', p_roi, 'Style', 'pushbutton', 'String', 'Å|', 'Position', [340, 5, 50, 30],...
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

%% plot1:: Single ROI
hfig.two_photon_axes1 = axes('Units', 'Pixels', 'Position', [70, 290, 600, 120]);

hfig.two_photon_plot1 = plot(NaN, NaN);
set(hfig.two_photon_plot1, 'Parent', hfig.two_photon_axes1);

Get_Plot_stim_timing(r, p);

set(hfig.two_photon_axes1, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [],...
    'YLimMode', 'manual', 'YLim', [-0.5, 3.5]);
title('Single ROI', 'FontSize', 14)
ylabel(hfig.two_photon_axes1, 'dF/F0')
%% plot2:: Multiple ROIs
hfig.two_photon_axes2 = axes('Units', 'Pixels', 'Position', [70, 50, 600, 200]);

set(hfig.two_photon_axes2, 'XLimMode', 'manual', 'XLim', [-inf, inf],...
    'YLimMode', 'manual', 'YLim', [-0.5, 3.5]);
title('Select ROIs', 'FontSize', 14)
ylabel(hfig.two_photon_axes2, 'dF/F0')
xlabel(hfig.two_photon_axes2, 'Time (sec)');

Get_Plot_stim_timing(r, p);

%%Load2P([], []);
end

%% subfunctions
function Load2P(~,~)
global imgobj
global mainvar
global hfig
%%
if isfield(imgobj, 'dFF') == 0
    %select file
    [fname, dirname] = uigetfile([mainvar.dirname, '*.xls']);
    if dirname == 0 %cancel select file
        %skip open file
    else
        Open_file(dirname, fname);
    end
else
    % 2P.xls is alread loaded the base workspace.
        % select another file
        [fname, dirname] = uigetfile([mainvar.dirname, '*.xls']);
        Open_file(dirname, fname);
end

if isempty(imgobj.dFF)
    errordlg('dFF is missing!')
    %skip open file
else
    Plot_dFF_next([], [], 0)
    Plot_dFF_selectROIs([], [])
end


%% GUI
%% panel2
p_funcs = uipanel('Parent', hfig.two_photon, 'Title', 'Ctr', 'FontSize', 12, 'Position', [0.63 0.05 0.36 0.83]);
h_Detrend = uicontrol('Parent', p_funcs, 'Style', 'togglebutton', 'String', 'Detrend', 'Position', [5, 360, 100, 30], 'FontSize', 14);

h_LowCut =  uicontrol('Parent', p_funcs, 'Style', 'togglebutton', 'String', 'Low-Cut', 'Position', [115, 360, 100, 30], 'FontSize', 14);
LowCutFrq = 0.005;
h_LowCutFrq = uicontrol('Parent', p_funcs, 'Style', 'edit', 'String', LowCutFrq, 'Position', [225, 362, 80, 25],'FontSize', 14);
uicontrol('Parent', p_funcs, 'Style', 'text', 'String', 'Hz', 'Position', [305, 355, 30, 25], 'FontSize', 14);

h_Offset = uicontrol('Parent', p_funcs, 'Style', 'togglebutton', 'String', 'Offset', 'Position', [5, 325, 100, 30], 'FontSize', 14);
uicontrol('Parent', p_funcs, 'Style', 'text', 'String', 'F0 = 1:', 'Position', [115, 322, 60, 25], 'FontSize', 14);
OffsetFrame = 1;
h_OffsetFrame = uicontrol('Parent', p_funcs, 'Style', 'edit', 'String', OffsetFrame, 'Position', [175, 327, 50, 25], 'FontSize', 14);

h_Norm = uicontrol('Parent', p_funcs, 'Style', 'togglebutton', 'String', 'Normalize', 'Position', [5, 290, 100, 30], 'FontSize', 14);

uicontrol('Parent', p_funcs, 'Style', 'pushbutton', 'String', 'Apply dFF', 'Position', [5, 255, 200, 30], 'FontSize', 14,...
    'Callback', {@Applay_change_dFF, h_Detrend, h_LowCut, h_LowCutFrq,...
    h_Offset, h_OffsetFrame, h_Norm});

%%
uicontrol('Parent', p_funcs, 'Style', 'pushbutton', 'String', 'Average by Stim', 'Position', [5, 205, 200, 30], 'FontSize', 14,...
    'Callback', @Average_dFF_by_stim)

%%
    function Open_file(d,f)
                imgobj.dFF = dlmread([d, f], '\t', 1, 1);
                imgobj.dFF_raw =  imgobj.dFF;
        [FVflames, imgobj.maxROIs] = size(imgobj.dFF);
        imgobj.FVt = 0:imgobj.FVsampt:imgobj.FVsampt*(FVflames-1);
    end
end

%% %%%%%subfunctions%%%%% %%
%% plot stim timing
function Get_Plot_stim_timing(r, p)
area_Y =  [-1, 10, 10, -1];

hold on
% get stim timing
for i =  r.prestim+1 : r.cycleCount
    if isfield(p{1,i}.stim1, 'corON')
        ON = p{1,i}.stim1.corON;
        OFF = p{1,i}.stim1.corOFF;
    else
        ON = p{1,i}.AIStartTime + p{1,i}.stim1.On_time + p{1,i}.stim1.centerY_pix/1024/75;
        OFF = p{1,i}.AIStartTime + p{1,i}.stim1.Off_time + p{1,i}.stim1.centerY_pix/1024/75;
    end
    area_X = [ON, ON, OFF, OFF];
    fill(area_X, area_Y, [0.8 0.8 0.8], 'EdgeColor', 'none');
end
hold off

end

%% Detrend
function Applay_change_dFF(~,~, h1, h2, h_freq, h3, h_frames, h4)
global imgobj

    %%Detrend
    if get(h1, 'value')
        dFF_mod = detrend(imgobj.dFF_raw);
    else
        dFF_mod = imgobj.dFF_raw;
    end
    %%LowCutFilter
    if get(h2, 'value')
        lowcutfreq = str2double(get(h_freq, 'string'));
        [dFF_mod, ~, ~] = filtbutter(2, lowcutfreq, 'high', 1/imgobj.FVsampt, dFF_mod);
    end
    %%Normalize
    if get(h4, 'value')
        MaxdFF = max(dFF_mod);
        for i = 1:size(imgobj.dFF,2)
            dFF_mod(:,i) = dFF_mod(:,i)/abs(MaxdFF(i));
        end
    end
    %%Offset
    if get(h3, 'value')
        F0frames = str2double(get(h_frames, 'string'));
        dFF_base= mean(dFF_mod(1:F0frames,:),1);
        for i = 1:size(imgobj.dFF,2)
            dFF_mod(:,i) = dFF_mod(:,i) - dFF_base(i);
        end
    end
    
    %%if
    imgobj.dFF = dFF_mod;
    Plot_dFF_next([],[],0);
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
