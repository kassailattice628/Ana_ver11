function h = GUI_NBA_Analysis(data, params, recobj, sobj, fname)
%open fig
h.fig1 = figure('Position', [10, 20, 1000, 800], 'Name', ['Analayse DATA for NBA ver:', num2str(recobj.NBAver)],...
    'NumberTitle', 'off', 'Menubar', 'none', 'Resize', 'off');
area_alpha = 0.1;

%% Eye Position %%
% Vertical & Horizontal eye Position
axes1_height_max = 690;
axes1_height = 60;
axes_height = 100;
axes_space = 30;
axes_left = 70;
axes_width = 600;
axes1_1_h_base = axes1_height_max-axes1_height;
%%
h.axes1_1 = axes('Units', 'Pixels', 'Position', [axes_left, axes1_1_h_base, axes_width, axes1_height]);
h.area1_1 = area([NaN, NaN], [NaN, NaN], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
alpha(area_alpha);
hold on
h.plot1_1 = plot(NaN, NaN);
hold off

set(h.axes1_1, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [], 'YLimMode', 'Auto');
title('EYE-Pos (Vertical)', 'FontSize', 14)
ylabel(h.axes1_1, 'D <--> U')

%%
axes1_2_h_base = axes1_1_h_base - axes1_height - axes_space;
h.axes1_2 = axes('Units', 'Pixels', 'Position', [axes_left, axes1_2_h_base, axes_width, axes1_height]);
h.area1_2 = area([NaN, NaN], [NaN, NaN], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
alpha(area_alpha);
hold on
h.plot1_2 = plot(NaN, NaN);
hold off

set(h.axes1_2, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [], 'YLimMode', 'Auto');
title('EYE-Pos (Horizontal)', 'FontSize', 14)
ylabel(h.axes1_2, 'T <--> N');

%% plot Eye velocity %%
% Vertical & Horizontal eye velocity
axes2_h_base = axes1_2_h_base - axes_height - axes_space;
h.axes2 = axes('Units', 'Pixels', 'Position', [axes_left, axes2_h_base, axes_width, axes_height]);
h.area2 = area([NaN, NaN], [NaN, NaN], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
alpha(0.1);
hold on
patch_x = 1:size(data,1)-1;
h.plot2 = patch(patch_x, patch_x, patch_x,...
    'EdgeColor', 'interp', 'Marker', '.', 'MarkerFaceColor','flat');
hold off
set(h.axes2, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [], 'YLim', [0, 150]);
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
set(h.axes3, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [], 'YLim', [-0.02, 2]);
title('Locomotion Velocity (Rotary)', 'FontSize', 14)
ylabel(h.axes3, 'cm/sec')

%% plot Photo Sensor
axes4_h_base =  axes3_h_base - axes1_height - axes_space;
h.axes4 = axes('Units', 'Pixels', 'Position', [axes_left, axes4_h_base, axes_width, axes1_height]);
h.area4 = area([NaN, NaN], [NaN, NaN], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
alpha(area_alpha)
hold on
h.plot4 = plot(NaN, NaN);
h.line4 = line([NaN, NaN], [NaN, NaN],'Color','r');
hold off

set(h.axes4, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'YLim', [-0.01, 0.25]);

ylabel(h.axes4, 'Diode (V)')
title('Visual Stimulus', 'FontSize', 14)
xlabel('Time (s)');

%% plot eye Position X-Y
h.axes5 = axes('Units', 'Pixels', 'Position', [760, 490, 200, 200]);
h.plot5 = patch(data(:,1,1), data(:,2,1), 1:size(data(:,1,1),1),...
    'EdgeColor', 'interp', 'Marker', '.', 'MarkerFaceColor','flat');

range_axes5 = 0.04;
set(h.axes5, 'XLim', [-range_axes5, range_axes5], 'YLim', [-range_axes5, range_axes5]);
title('Position XY', 'FontSize', 14)

%% plot ROI Traces
axes6_h_base =  axes4_h_base - axes_height - axes_space -20;
h.axes6 = axes('Units', 'Pixels', 'Position', [axes_left, axes6_h_base, axes_width, axes_height]);
h.area6 = area([NaN, NaN], [NaN, NaN], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
alpha(area_alpha);
hold on
h.plot6 = plot(NaN, NaN, 'LineWidth', 2);
hold off
set(h.axes6, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', []);
title('ROI Traces', 'FontSize', 14)
ylabel(h.axes6, 'dF/F %')

%% Controler
slider2_height = axes2_h_base + axes_height;
uicontrol('Style', 'text', 'String', 'Filter', 'Position',[640, slider2_height, 80, 20])
h.slider2 = uicontrol('Style', 'slider', 'Position', [675, axes2_h_base, 20, axes_height],...
    'Min', 1, 'Max', 200, 'Value', 100, 'Callback', {@Plot_next, data, 0, params});

slider4_height = axes4_h_base + axes1_height;
uicontrol('Style', 'text', 'String', 'Threshold', 'Position',[640, slider4_height, 80, 20])
h.slider4 = uicontrol('Style', 'slider', 'Position', [675, axes4_h_base, 20, axes1_height],...
    'Min', 0.001, 'Max', 0.2, 'Value', 0.025, 'Callback', {@Plot_next, data, 0, params});


%% Select NBA DATA file
uicontrol('Style', 'pushbutton', 'String', 'New File', 'Position', [10, 760, 100, 30], 'Callback', 'Select_Open_MAT', 'FontSize', 14);
%Select_Open_MAT は function ではなくて script M ファイルとして呼んで workspace の変数を編集

%% Data Infomation
h.file_name = uicontrol('Style', 'text', 'String', fname, 'Position', [115, 755, 150, 30], 'FontSize', 14);
uicontrol('Style', 'text', 'String', ['Stim Pattern: ' sobj.pattern], 'Position', [270, 755, 200, 30], 'FontSize', 14, 'HorizontalAlignment', 'Left');
h.stim1_info = uicontrol('Style', 'text', 'String', '', 'Position', [470, 755, 500, 30], 'FontSize', 14, 'HorizontalAlignment', 'Left');
h.stim2_info = uicontrol('Style', 'text', 'String', '', 'Position', [470, 725, 500, 30], 'FontSize', 14, 'HorizontalAlignment', 'Left');


%% trial select
%main[10, 20, 1000, 800]
h.p_trial =  uipanel('Title', 'Stim Trial', 'FontSize', 12, 'Position', [0.01 0.88, 0.2, 0.065]);

uicontrol('Parent', h.p_trial, 'Style', 'pushbutton', 'String', '+', 'Position', [10, 5, 50, 30], 'Callback', {@Plot_next, data, 1, params}, 'FontSize', 14);
uicontrol('Parent', h.p_trial, 'Style', 'pushbutton', 'String', '－', 'Position', [65, 5, 50, 30], 'Callback', {@Plot_next, data, -1, params}, 'FontSize', 14);
uicontrol('Parent', h.p_trial, 'Style', 'text', 'String', '#: ', 'Position', [120, 2, 20, 25], 'FontSize', 14);
h.set_n = uicontrol('Parent', h.p_trial, 'Style', 'edit', 'String', 1, 'Position', [140, 7, 50, 25], 'Callback', {@Plot_next, data, 0, params}, 'FontSize', 14, 'BackGroundColor', 'w');


%% Load two-photon traces
uicontrol('Style', 'togglebutton', 'String', 'Two-photon', 'Position', [800, 760, 100, 30],...
    'Callback', {@Open_subwindow, params, recobj, sobj, 'two_photon'}, 'FontSize', 14);

h.button_table = uicontrol('Style', 'togglebutton', 'String', 'All Params','Position', [800, 725, 100, 30],...
    'Callback', {@Open_subwindow, params, recobj, sobj, 'params_table'}, 'FontSize', 14);

%% Use KeyPress
set(h.fig1, 'KeyPressFcn', @callback_keypress);
    function callback_keypress(~, eventdata)
        switch eventdata.Key
            case {'rightarrow', 'uparrow', 'return', 'space'}
                Plot_next([], [], data, 1, params)
            case {'leftarrow', 'downarrow', 'backspace'}
                Plot_next([], [], data, -1, params)
        end
    end
%%
end


%%
function Open_subwindow(hObject, ~, params, recobj, sobj, name)
global hfig
if get(hObject, 'value')
    if strcmp(name,'two_photon')
            Open_2P(hObject, params, recobj);
    elseif strcmp(name, 'params_table')
            Open_Params_Table(hObject, params, recobj, sobj);
    end
else
    if isfield(hfig, name)
        close(getfield(hfig, name))
        %hfig = rmfield(hfig, 'params_table');
    end
end
end