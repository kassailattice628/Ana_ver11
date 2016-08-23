function h = GUI_NBA(data, params, recobj, sobj, fname)
%open fig
h.fig1 = figure('position', [10, 20, 1000, 800], 'Name', ['NBA ver:', num2str(recobj.NBAver)], 'NumberTitle', 'off', 'Menubar', 'none', 'Resize', 'off');
area_alpha = 0.1;
%% Eye Position %%
% Vertical & Horizontal eye position
h.axes1_1 = axes('Units', 'Pixels', 'Position', [70, 590, 600, 100]);
h.area1_1 = area([NaN, NaN], [NaN, NaN], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
alpha(area_alpha);
hold on
h.plot1_1 = plot(NaN, NaN);
hold off

set(h.axes1_1, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [], 'YLimMode', 'Auto');
title('EYE-Pos (Vertical)', 'FontSize', 14)
ylabel(h.axes1_1, 'Down <--> UP')

%%
h.axes1_2 = axes('Units', 'Pixels', 'Position', [70, 470, 600, 100]);
h.area1_2 = area([NaN, NaN], [NaN, NaN], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
alpha(area_alpha);
hold on
h.plot1_2 = plot(NaN, NaN);
hold off

set(h.axes1_2, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [], 'YLimMode', 'Auto');
title('EYE-Pos (Horizontal)', 'FontSize', 14)
ylabel(h.axes1_2, 'Tempo <--> Nasal');

%% plot Eye velocity %%
% Vertical & Horizontal eye velocity
h.axes2 = axes('Units', 'Pixels', 'Position', [70, 330, 600, 100]);
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
h.axes3 = axes('Units', 'Pixels', 'Position', [70, 190, 600, 100]);
h.area3 = area([NaN, NaN], [NaN, NaN], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
alpha(area_alpha);
hold on
h.plot3 = plot(NaN, NaN, 'LineWidth', 2);
hold off
set(h.axes3, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [], 'YLim', [-0.02, 2]);
title('Locomotion Velocity (Rotary)', 'FontSize', 14)
ylabel(h.axes3, 'cm/sec')

%% plot Photo Sensor
h.axes4 = axes('Units', 'Pixels', 'Position', [70, 50, 600, 100]);
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

%% plot eye position X-Y
h.axes5 = axes('Units', 'Pixels', 'Position', [760, 490, 200, 200]);
h.plot5 = patch(data(:,1,1), data(:,2,1), 1:size(data(:,1,1),1),...
    'EdgeColor', 'interp', 'Marker', '.', 'MarkerFaceColor','flat');

range_axes5 = 0.04;
set(h.axes5, 'XLim', [-range_axes5, range_axes5], 'YLim', [-range_axes5, range_axes5]);
title('Position XY', 'FontSize', 14)

%% Controler
uicontrol('Style', 'text', 'String', 'Filter', 'Position',[640, 430, 80, 20]) 
h.slider2 = uicontrol('Style', 'slider', 'Position', [675, 330, 20, 100],...
    'Min', 1, 'Max', 200, 'Value', 100, 'Callback', {@Plot_next, data, 0, params});

uicontrol('Style', 'text', 'String', 'Threshold', 'Position',[640, 150, 80, 20]) 
h.slider4 = uicontrol('Style', 'slider', 'Position', [675, 50, 20, 100],...
    'Min', 0.001, 'Max', 0.2, 'Value', 0.025, 'Callback', {@Plot_next, data, 0, params});

uicontrol('Style', 'pushbutton', 'String', 'New File', 'position', [10, 750, 100, 30], 'Callback', 'Select_Open_MAT', 'FontSize', 14);
h.file_name = uicontrol('Style', 'text', 'String', fname, 'position', [115, 745, 150, 30], 'FontSize', 14);
uicontrol('Style', 'text', 'String', ['Stim Pattern: ' sobj.pattern], 'position', [270, 745, 200, 30], 'FontSize', 14);

%% trial select
uicontrol('Style', 'pushbutton', 'String', '+', 'position', [10, 710, 50, 30], 'Callback', {@Plot_next, data, 1, params}, 'FontSize', 14);
uicontrol('Style', 'pushbutton', 'String', 'Å|', 'position', [65, 710, 50, 30], 'Callback', {@Plot_next, data, -1, params}, 'FontSize', 14);
uicontrol('Style', 'text', 'String', 'Trial#: ', 'position', [120, 725, 50, 30], 'FontSize', 14);
h.set_n = uicontrol('Style', 'edit', 'String', 1, 'position', [120, 710, 50, 25], 'Callback', {@Plot_next, data, 0, params}, 'FontSize', 14, 'BackGroundColor', 'w');

%%
set(h.fig1, 'KeyPressFcn', {@callback_keypress, h, data});

%%
    function callback_keypress(~, eventdata, h, data)
        switch eventdata.Key
            case {'rightarrow', 'uparrow', 'return', 'space'}
                Plot_next([], [], h, data, 1)
            case {'leftarrow', 'downarrow', 'backspace'}
                Plot_next([], [], h, data, -1)
        end
    end
end