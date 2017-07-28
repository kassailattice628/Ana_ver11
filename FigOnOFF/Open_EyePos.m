function Open_EyePos(hfig_handle, p, r)
%create plot window for transition of pupil center
global hfig
global DataSave
data = DataSave;

%%
h_name = 'eye_position';

hfig.eye_position = figure('Position', [1010, 520, 300, 300], 'Name', 'Eye-Position',...
    'NumberTitle', 'off', 'Menubar', 'none', 'Resize', 'off', 'DeleteFcn', {@Close_subwindow, hfig_handle, h_name});
%%
hfig.axes5 = axes('Units', 'Pixels', 'Position', [60, 70, 200, 200]);
hfig.plot5 = patch(data(:,1,1), data(:,2,1), 1:size(data(:,1,1),1),...
    'EdgeColor', 'interp', 'Marker', '.', 'MarkerFaceColor','flat');

range_axes5 = 5;
set(hfig.axes5, 'XLim', [-range_axes5, range_axes5], 'YLim', [-range_axes5, range_axes5]);
title('Position (Nasa<->Temporal)', 'FontSize', 14)


uicontrol('Style', 'text', 'String', 'V:', 'Position', [30, 20, 30, 25], 'FontSize', 14);
hfig.offsetV = uicontrol('Style', 'edit', 'String', 0, 'Position', [60, 25, 60, 25], 'FontSize', 14,...
    'Callback', {@Plot_next, data, 0, p, r});

uicontrol('Style', 'text', 'String', 'H:', 'Position', [125, 20, 30, 25], 'FontSize', 14);
hfig.offsetH = uicontrol('Style', 'edit', 'String', 0, 'Position', [160, 25, 60, 25], 'FontSize', 14,...
    'Callback', {@Plot_next, data, 0, p, r});

hfig.sfhit_eye_pos = uicontrol('Style', 'pushbutton', 'String', 'Shift', 'Position', [225, 23, 50, 30],...
    'FontSize', 14, 'Callback', {@Plot_next, data, 0, p, r});

Plot_next([], [], data, 0, p, r)


end