function  Open_2P(hfig_handle, p, r)
global hfig
global imgobj

%%
h_name = 'two_photon';
hfig.two_photon = figure('Position', [10, 20, 1100, 500], 'Name', 'Two-photon Traces',...
    'NumberTitle', 'off', 'Menubar', 'none', 'Resize', 'off',...
    'DeleteFcn', {@Close_subwindow, hfig_handle, h_name});

p_roi =  uipanel('Title', 'ROI traces', 'FontSize', 12, 'Position', [0.01 0.89, 0.95, 0.1]);
%% Load DATA
uicontrol('Parent', p_roi, 'Style', 'pushbutton', 'String', 'Load', 'Position', [10, 5, 100, 30],...
    'Callback', {@Load2P}, 'FontSize', 14);

uicontrol('Parent', p_roi, 'Style', 'edit', 'String', imgobj.FVsampt, 'Position', [120, 7, 100, 25],...
    'Callback', {}, 'FontSize', 14);

uicontrol('Parent', p_roi, 'Style', 'text', 'String', 's/Flame', 'Position', [225, 2, 50, 20], 'FontSize', 12);
%% ROI select
uicontrol('Parent', p_roi, 'Style', 'pushbutton', 'String', '+', 'Position', [285, 5, 50, 30],...
    'Callback', {@Plot_dFF_next, 1}, 'FontSize', 14);
uicontrol('Parent', p_roi, 'Style', 'pushbutton', 'String', '－', 'Position', [340, 5, 50, 30],...
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
%
area_Y =  [-1, 5, 5, -1];
hold on;
% get stim timing
for i =  r.prestim+1 : r.cycleCount
    %ON_Time 補正必要
    ON = p{1,i}.AIStartTime + p{1,i}.stim1.On_time;
    OFF = p{1,i}.AIStartTime + p{1,i}.stim1.Off_time;
    area_X = [ON, ON, OFF, OFF];
    fill(area_X, area_Y, [0.8 0.8 0.8], 'EdgeColor', 'none');
end

hfig.two_photon_plot1 = plot(NaN, NaN);
hold off

set(hfig.two_photon_axes1, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [],...
    'YLimMode', 'manual', 'YLim', [-0.5, 3.5]);
title('Single ROI', 'FontSize', 14)
ylabel(hfig.two_photon_axes1, 'dF/F0')

%% plot2:: Multiple ROIs
hfig.two_photon_axes2 = axes('Units', 'Pixels', 'Position', [70, 50, 600, 200]);
hold on
for i =  r.prestim+1 : r.cycleCount
    %ON_Time 補正必要
    ON = p{1,i}.AIStartTime + p{1,i}.stim1.On_time;
    OFF = p{1,i}.AIStartTime + p{1,i}.stim1.Off_time;
    area_X = [ON, ON, OFF, OFF];
    fill(area_X, area_Y, [0.8 0.8 0.8], 'EdgeColor', 'none');
end
%hfig.two_photon_plot2 = plot(NaN, NaN, 'k');
hold off

set(hfig.two_photon_axes2, 'XLimMode', 'manual', 'XLim', [-inf, inf],...
    'YLimMode', 'manual', 'YLim', [-0.5, 3.5]);
title('Select ROIs', 'FontSize', 14)
ylabel(hfig.two_photon_axes2, 'dF/F0')
xlabel(hfig.two_photon_axes2, 'Time (sec)');
end

%%
%%
function Load2P(~,~)
global imgobj
%%
if exist('dFF', 'var') == 0
    %select file
    [fname, dirname] = uigetfile('*.xls');
    imgobj.dFF = dlmread([dirname, fname], '\t', 1, 1);
    [FVflames, imgobj.maxROIs] = size(imgobj.dFF);
    imgobj.FVt = 0:imgobj.FVsampt:imgobj.FVsampt*(FVflames-1);
    while isempty(imgobj.dFF)
        errordlg('dFF  is missing!')
        % select another file
       imgobj.dFF = dlmread([dirname, fname], '\t', 1, 1);
        [FVflames, imgobj.maxROIs] = size(imgobj.dFF);
        imgobj.FVt = 0:imgobj.FVsampt:imgobj.FVsampt*(FVflames-1);
    end
else
    % 2P.xls is alread loaded the base workspace.
    if isempty(imgobj.dFF)
        while isempty(imgobj.dFF)
            errordlg('dFF is missing!')
            % select another file
           imgobj.dFF = dlmread([dirname, fname], '\t', 1, 1);
            [FVflames, imgobj.maxROIs] = size(imgobj.dFF);
            imgobj.FVt = 0:imgobj.FVsampt:imgobj.FVsampt*(FVflames-1);
        end
    end
end
%%
Plot_dFF_next([], [], 0)
Plot_dFF_selectROIs([], [])
end
