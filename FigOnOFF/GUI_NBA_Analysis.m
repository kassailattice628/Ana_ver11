function h = GUI_NBA_Analysis(data, p, r, sobj, fname)
global imgobj
%open fig
h.fig1 = figure('Position', [10, 20, 1000, 800], 'Name', ['Analayse DATA for NBA ver:', num2str(r.NBAver)],...
    'NumberTitle', 'off','Resize', 'off',... %'Menubar', 'none', 
    'DeleteFcn', @Close_NBA11_Analysys);

area_alpha = 0.1;

%% Eye Position %%
% Vertical & Horizontal eye Position
axes1_height_max = 690;
axes1_height = 100;

axes_height = 100;

axes_space = 30;
axes_left = 70;
axes_width = 600;

%%
axes1_1_h_base = axes1_height_max-axes1_height;
h.axes1_1 = axes('Units', 'Pixels', 'Position', [axes_left, axes1_1_h_base, axes_width, axes1_height]);
h.area1_1 = area([NaN, NaN], [NaN, NaN], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
alpha(area_alpha);
hold on
h.plot1_1 = plot(NaN, NaN);
h.plot1_1_sac = plot(NaN, NaN, 'om');
hold off

set(h.axes1_1, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [], 'YLimMode', 'manual');
title('EYE-Pos (Horizontal)', 'FontSize', 14)
ylabel(h.axes1_1, 'T <--> N')

%%
axes1_2_h_base = axes1_1_h_base - axes1_height - axes_space;
h.axes1_2 = axes('Units', 'Pixels', 'Position', [axes_left, axes1_2_h_base, axes_width, axes1_height]);
h.area1_2 = area([NaN, NaN], [NaN, NaN], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
alpha(area_alpha);
hold on
h.plot1_2 = plot(NaN, NaN);
h.plot1_2_sac = plot(NaN, NaN, 'om');
hold off

set(h.axes1_2, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [], 'YLimMode', 'manual');
title('EYE-Pos (Vertical)', 'FontSize', 14)
ylabel(h.axes1_2, 'D <--> U');

%% plot Eye velocity %%
% Vertical & Horizontal eye velocity
axes2_h_base = axes1_2_h_base - axes_height - axes_space;
h.axes2 = axes('Units', 'Pixels', 'Position', [axes_left, axes2_h_base, axes_width, axes_height]);
h.area2 = area([NaN, NaN], [NaN, NaN], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
alpha(0.1);
hold on
patch_x = 1:size(data,1)-1;
h.plot2_1 = patch(patch_x, patch_x, patch_x,...
    'EdgeColor', 'interp', 'Marker', '.', 'MarkerFaceColor','flat');
h.plot2_2 = plot(NaN, NaN, '*m');
hold off
set(h.axes2, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [], 'YLim', [-10, 250]);
title('Radial-Velocity', 'FontSize', 14);
ylabel(h.axes2, 'Pix/sec');
%% plot Rotary Velocity%%
axes3_h_base =  axes2_h_base - axes_height - axes_space;
h.axes3 = axes('Units', 'Pixels', 'Position', [axes_left, axes3_h_base, axes_width, axes_height]);
h.area3 = area([NaN, NaN], [NaN, NaN], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
alpha(area_alpha);
hold on
h.plot3 = plot(NaN, NaN, 'LineWidth', 2);
hold off
set(h.axes3, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [], 'YLim', [-0.02, 10]);
title('Locomotion Velocity (Rotary)', 'FontSize', 14)
ylabel(h.axes3, 'cm/sec');

%% plot Photo Sensor
axes4_h_base =  axes3_h_base - axes1_height - axes_space;
h.axes4 = axes('Units', 'Pixels', 'Position', [axes_left, axes4_h_base, axes_width, axes1_height]);
h.area4 = area([NaN, NaN], [NaN, NaN], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
alpha(area_alpha)
hold on
h.plot4 = plot(NaN, NaN);
h.line4 = line([NaN, NaN], [NaN, NaN],'Color','r');
h.line4_correct_ON = line([NaN, NaN], [NaN, NaN],'Color','r');
h.line4_correct_OFF = line([NaN, NaN], [NaN, NaN],'Color','g');
hold off
set(h.axes4, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'YLimMode', 'manual', 'YLim', [-inf, inf]);
ylabel(h.axes4, 'Diode (V)')
title('Visual Stimulus', 'FontSize', 14)
xlabel('Time (s)');


%% Controler
%{
slider2_height = axes2_h_base + axes_height;
uicontrol('Style', 'text', 'String', 'Filter', 'Position',[640, slider2_height, 80, 20])
h.slider2 = uicontrol('Style', 'slider', 'Position', [675, axes2_h_base, 20, axes_height],...
    'Min', 1, 'Max', 200, 'Value', 20, 'Callback', {@Plot_next, data, 0, p, r});
%}

slider4_height = axes4_h_base + axes1_height;
uicontrol('Style', 'text', 'String', 'Threshold', 'Position',[640, slider4_height, 80, 20])
h.slider4 = uicontrol('Style', 'slider', 'Position', [675, axes4_h_base, 20, axes1_height],...
    'Min',0, 'Max', 500, 'Value', 10, 'Callback', {@Plot_next, data, 0, p, r});


%% Select NBA DATA file
uicontrol('Style', 'pushbutton', 'String', 'New File', 'Position', [10, 760, 100, 30],...
    'Callback', {@Select_Open_MAT, r}, 'FontSize', 14);

%% Data Infomation
h.file_name = uicontrol('Style', 'text', 'String', fname, 'Position', [115, 755, 150, 30], 'FontSize', 14);
uicontrol('Style', 'text', 'String', ['Stim Pattern: ' sobj.pattern], 'Position', [270, 755, 200, 30], 'FontSize', 14, 'HorizontalAlignment', 'Left');
h.stim1_info = uicontrol('Style', 'text', 'String', '', 'Position', [470, 770, 500, 25], 'FontSize', 14, 'HorizontalAlignment', 'Left');
h.stim2_info = uicontrol('Style', 'text', 'String', '', 'Position', [470, 750, 500, 25], 'FontSize', 14, 'HorizontalAlignment', 'Left');


%% trial select
%main[10, 20, 1000, 800]
h.p_trial =  uipanel('Title', 'Stim Trial', 'FontSize', 12, 'Position', [0.01 0.88, 0.7, 0.065]);

uicontrol('Parent', h.p_trial, 'Style', 'pushbutton', 'String', '+', 'Position', [10, 5, 50, 30], 'Callback', {@Plot_next, data, 1, p, r}, 'FontSize', 14);
uicontrol('Parent', h.p_trial, 'Style', 'pushbutton', 'String', '-', 'Position', [65, 5, 50, 30], 'Callback', {@Plot_next, data, -1, p, r}, 'FontSize', 14);
uicontrol('Parent', h.p_trial, 'Style', 'text', 'String', '#: ', 'Position', [120, 2, 20, 25], 'FontSize', 14);
h.set_n = uicontrol('Parent', h.p_trial, 'Style', 'edit', 'String', 1, 'Position', [140, 7, 50, 25], 'Callback', {@Plot_next, data, 0, p, r}, 'FontSize', 14, 'BackGroundColor', 'w');

uicontrol('Parent', h.p_trial, 'Style', 'text', 'String', 'Threshold:', 'Position', [200, 2, 80, 25], 'FontSize', 14);
h.set_threshold = uicontrol('Parent', h.p_trial, 'Style', 'edit', 'String',...
    num2str(get(h.slider4, 'value')),'Position', [285, 7, 50, 25],...
    'Callback', {@Set_threshold, h, data, p}, 'FontSize', 14, 'BackGroundColor', 'w');
h.apply_threshold = uicontrol('Parent', h.p_trial, 'Style', 'togglebutton',...
    'String', 'Apply All', 'Position', [340, 5, 90, 30], 'Callback', {@Apply_threshold_to_all, h.set_threshold, data}, 'FontSize', 14);

uicontrol('Parent', h.p_trial, 'Style', 'pushbutton', 'String', 'Get F0#', 'Position', [435, 5, 80, 30], 'FontSize', 14,...
    'Callback', @GetF0);

uicontrol('Parent', h.p_trial, 'Style', 'text', 'String', 'FVsampt=', 'Position', [515, 2, 80, 25], 'FontSize', 14);
h.FVsampt = uicontrol('Parent', h.p_trial, 'Style', 'edit', 'String', imgobj.FVsampt,...
    'Position', [595, 5, 100, 30], 'FontSize', 14, 'Callback', @Update_FVsampt);

%% saccade timing select
uicontrol('Units', 'Pixels', 'Style', 'text', 'String', 'Detect Events', 'FontSize', 14,...
    'Position', [axes_left + axes_width + 5, axes2_h_base + axes_height , 300, 20]);
h.sac_locs = uicontrol('Units', 'Pixels', 'Style', 'Edit', 'String', '19', 'FontSize', 14,...
    'Position', [axes_left+axes_width+5, axes2_h_base + axes_height - 30, 300, 30],...
    'Callback', {@Update_saccade_time, p, r, data});
    
%% Load two-photon traces
h.roi_traces = uicontrol('Style', 'togglebutton', 'String', 'Two-photon', 'Position', [785, 760, 100, 30],...
    'Callback', {@Open_subwindow, p, r, sobj, 'two_photon'}, 'FontSize', 14);

h.button_eyepos = uicontrol('Style', 'togglebutton', 'String', 'Sac-Traces','Position', [785, 725, 100, 30],...
    'Callback', {@Open_subwindow, p, r, sobj, 'peri_saccade'}, 'FontSize', 14);

h.button_table = uicontrol('Style', 'togglebutton', 'String', 'All params','Position', [890, 725, 100, 30],...
    'Callback', {@Open_subwindow, p, r, sobj, 'params_table'}, 'FontSize', 14);

h.button_eyepos = uicontrol('Style', 'togglebutton', 'String', 'Eye-Pos','Position', [890, 760, 100, 30],...
    'Callback', {@Open_subwindow, p, r, sobj, 'eye_position'}, 'FontSize', 14);


%% Use KeyPress
set(h.fig1, 'KeyPressFcn', @callback_keypress);
    function callback_keypress(~, eventdata)
        switch eventdata.Key
            case {'rightarrow', 'uparrow', 'return', 'space'}
                Plot_next([], [], data, 1, p, r)
            case {'leftarrow', 'downarrow', 'backspace'}
                Plot_next([], [], data, -1, p, r)
        end
    end

%%
    function Update_FVsampt(hobj,~)
        imgobj.FVsampt = str2double(get(hobj, 'string'));
    end
% end of GUI_Analysis
end

%% subfunction

function Close_NBA11_Analysys(~,~)
close all
clear DataSave
%clear valuables

end


function GetF0(~,~)
global pSave
global r
global imgobj

if isfield(pSave{1,r.prestim + 1}.stim1, 'corON')
    numF0 = floor(pSave{1,r.prestim + 1}.stim1.corON / imgobj.FVsampt) - 1;
    
    msgbox(['The number of frames for prestimulus is :: ', num2str(numF0)] );
else
    warndlg('Onset of the first stimulus timing is not defined !!!')
end
end
