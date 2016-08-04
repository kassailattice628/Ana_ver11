function h = GUI_NBA2(data, params, recobj, sobj, fname)
%open fig
h.fig1 = figure('position', [10, 20, 1000, 800], 'Name', ['NBA ver:', num2str(recobj.NBAver)], 'NumberTitle', 'off', 'Menubar', 'none', 'Resize', 'off');

%% plot Eye position %%
n = 1;
% find visual stim
ind_stim_on = find(data(:, 5, n) > 0.025, 1);
ind_stim_off = find(data(:, 5, n) > 0.025, 1, 'last');

% Vertical & Horizontal eye position
h.axes1 = axes('Units', 'Pixels', 'Position', [70, 490, 600, 200]);
if isempty(ind_stim_on) || isempty(ind_stim_off)
else
    h.area1 = area([data(ind_stim_on, 1, n), data(ind_stim_off, 1, n)], [min(-data(:, 2, n)), max(-data(:, 2, n))], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
    alpha(0.2);
end
hold on
[h.axes1, h.plot1_1, h.plot1_2] = plotyy(data(:, 1, n), -data(:, 2, n), data(:, 1, n), data(:, 3, n));
hold off

set(h.axes1, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [], 'YLimMode', 'Auto');

title('EYE-Position', 'FontSize', 14)
ylabel(h.axes1(1), 'Down <- V -> UP')
ylabel(h.axes1(2), 'Temporal <- H -> Nasal');


%% plot Eye velocity %%
% Vertical & Horizontal eye velocity
h.axes2 = axes('Units', 'Pixels', 'Position', [70, 320, 600, 130]);
[data2_offset, data3_offset, vel] = Radial_Vel(data, n);
%h.plot2 = plot(data(1:end-1, 1, n), vel);
vel(end) = NaN;
h.plot2 = patch(data(1:end-1, 1, n), vel, data(1:end-1, 1, n),...
    'EdgeColor', 'interp', 'Marker', '.', 'MarkerFaceColor','flat');

set(h.axes2, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [], 'YLim', [0, 1.3*100]);

title('Radial-Velocity', 'FontSize', 14);
ylabel(h.axes2, 'Pix/sec');

%% plot Rotary %%
h.axes3 = axes('Units', 'Pixels', 'Position', [70, 150, 600, 130]);
angle = DecodeRot(data(:, 6, n));
h.plot3 = plot(data(:, 1, n), -angle/360 * 12, 'LineWidth', 2);

set(h.axes3, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', []);

title('Rotary position', 'FontSize', 14)
ylabel(h.axes3, 'cm')

%% plot Photo Sensor
h.axes4 = axes('Units', 'Pixels', 'Position', [70, 40, 600, 70]);
h.area4 = area([NaN, NaN], [NaN, NaN], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
alpha(0.2);
hold on
h.plot4 = plot(data(:, 1, n), data(:, 4, n));
hold off

set(h.axes4, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'YLim', [-0.05, 0.1]);

title('Photo Sensor', 'FontSize', 14)
xlabel('Time (s)');
ylabel(h.axes4, 'V')
%% plot eye position X-Y
h.axes5 = axes('Units', 'Pixels', 'Position', [760, 490, 200, 200]);
data2_offset(end) = NaN;
h.plot5 = patch(data3_offset, -data2_offset, data(:, 1, n),...
    'EdgeColor', 'interp', 'Marker', '.', 'MarkerFaceColor','flat');

range_axes5 = 0.04;
set(h.axes5, 'XLim', [-range_axes5, range_axes5], 'YLim', [-range_axes5, range_axes5]);
title('Position XY', 'FontSize', 14)

%% Controler
uicontrol('style', 'pushbutton', 'string', 'New File', 'position', [10, 750, 100, 30], 'Callback', 'Select_Open_MAT2', 'FontSize', 14);
h.file_name = uicontrol('style', 'text', 'string', fname, 'position', [115, 745, 150, 30], 'FontSize', 14);
uicontrol('style', 'text', 'string', ['Stim Pattern: ' sobj.pattern], 'position', [270, 745, 200, 30], 'FontSize', 14);


h.set_n = uicontrol('style', 'edit', 'string', 1, 'position', [120, 710, 50, 30], 'Callback', {@Plot_next, h, data, 0}, 'FontSize', 14, 'BackGroundColor', 'w');
uicontrol('style', 'pushbutton', 'string', '+', 'position', [10, 710, 50, 30], 'Callback', {@Plot_next, h, data, 1}, 'FontSize', 14);
uicontrol('style', 'pushbutton', 'string', 'Å|', 'position', [65, 710, 50, 30], 'Callback', {@Plot_next, h, data, -1}, 'FontSize', 14);

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

%%
    function Plot_next(hobj, ~, h, data, set_n)
        %change_n
        if set_n == 1
            if n < size(data, 3)
                n = n + 1;
            end
            set(h.set_n, 'string', num2str(n))
        elseif set_n == -1
            if n < size(data, 3)+1 && n > 1
                n = n - 1;
                set(h.set_n, 'string', num2str(n))
            end
        else
            n = str2double(get(hobj, 'string'));
        end
        
        %% eye position
        set(h.plot1_1, 'XData', data(:, 1, n), 'YData', -data(:, 2, n));
        set(h.plot1_2, 'XData', data(:, 1, n), 'YData', data(:, 3, n));
        
        if isfield(params{1,n}, 'stim1')
            ind_stim_on = find(data(:, 4, n) > 0.025, 1);
            ind_stim_off = find(data(:, 4, n) > 0.025, 1, 'last');
            y_min = min(-data(:, 2, n));
            set(h.area1,'XData', [data(ind_stim_on, 1, n), data(ind_stim_off, 1, n)], 'YData', [max(-data(:, 2, n)), max(-data(:, 2, n))], 'basevalue', y_min);
        else
            y_min = min(-data(:, 2, n));
            set(h.area1,'XData', [NaN, NaN], 'YData', [NaN, NaN], 'basevalue', y_min);
        end
        
        %% velocity
        [data2_offset, data3_offset, vel] = Radial_Vel(data, n);
        vel(end) = NaN;
        set(h.plot2, 'XData', data(2:end, 1, n), 'YData', vel);
        
        %% rotary
        angle = DecodeRot(data(:, 6, n));%
        set(h.plot3, 'XData', data(:, 1, n), 'YData', -angle/360 * 12);
        
        %% photo sensor
        set(h.plot4, 'XData', data(:, 1, n), 'YData', data(:, 4, n));
        if isfield(params{1,n}, 'stim1')
            y_min = min(data(:, 4, n));
            set(h.area4,'XData', [data(ind_stim_on, 1, n), data(ind_stim_off, 1, n)], 'YData', [0.1, 0.1], 'basevalue', y_min);
        else
            y_min = min(data(:, 4, n));
            set(h.area4,'XData', [NaN, NaN], 'YData', [NaN, NaN], 'basevalue', y_min);
        end
        %% position XY
        data2_offset(end) = NaN;
        set(h.plot5, 'XData', data3_offset, 'YData', -data2_offset);
        %% plot
        refreshdata(h.fig1, 'caller')
    end

%%
    function [data2_offset, data3_offset, velocity] = Radial_Vel(data, n)
        a = 100;
        b = ones(1,a)/a;
        data2_filt = filter(b, a ,data(:, 2, n) - data(1, 2, n));
        data3_filt = filter(b, a ,data(:, 3, n) - data(1, 3, n));
        
        data2_offset = data2_filt - data2_filt(1);
        data3_offset = data3_filt - data3_filt(1);
        
        data2_diff = diff(data2_offset);
        data3_diff = diff(data3_offset);
        
        diff_t = data(2,1,1) - data(1,1,1);
        [~, r] = cart2pol(data3_diff, -data2_diff);
        velocity = r / diff_t * 100;

    end

    function positionDataDeg = DecodeRot(CTRin)
        % Transform counter data from rotary encoder into angular position (deg).
        signedThreshold = 2^(32-1); %resolution 32 bit
        signedData = CTRin; % data from DAQ
        signedData(signedData > signedThreshold) = signedData(signedData > signedThreshold) - 2^32;
        positionDataDeg = signedData * 360/1000/4;
        
    end

end
