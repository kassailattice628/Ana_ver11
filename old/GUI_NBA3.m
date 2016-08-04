function h = GUI_NBA(data, params, recobj, sobj, fname)
%open fig
h.fig1 = figure('position', [10, 20, 1000, 800], 'Name', ['NBA ver:', num2str(recobj.NBAver)], 'NumberTitle', 'off', 'Menubar', 'none', 'Resize', 'off');

%% plot Eye position %%
n = 1;
% calc AI recording time
recTime = linspace(params{1,n}.AIStartTime, params{1,n}.AIEndTime, size(data,1));
ind_stim_on = find(data(:, 3, n) > 0.025, 1); 
ind_stim_off = find(data(:, 3, n) > 0.025, 1, 'last');

% Vertical & Horizontal eye position
h.axes1_1 = axes('Units', 'Pixels', 'Position', [70, 590, 600, 100]);

if isempty(ind_stim_on) || isempty(ind_stim_off)
    h.area1 = area([NaN, NaN], [NaN, NaN], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
    alpha(0.2);
else
    h.area1 = area([recTime(ind_stim_on), recTime(ind_stim_off)], [max(-data(:, 1, n)), max(-data(:, 1, n))], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
    alpha(0.2);
end

hold on
%[h.axes1_1, h.plot1_1, h.plot1_2] = plotyy(recTime, -data(:, 1, n), recTime, data(:, 2, n));
h.plot1_1 = plot(recTime, -data(:, 1, n));
hold off

set(h.axes1_1, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [], 'YLimMode', 'Auto');

title('EYE-Position', 'FontSize', 14)
ylabel(h.axes1_1, 'Down <--> UP')

%%
h.axes1_2 = axes('Units', 'Pixels', 'Position', [70, 470, 600, 100]);
h.plot1_2 = plot(recTime, data(:, 2, n));
set(h.axes1_2, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [], 'YLimMode', 'Auto');
ylabel(h.axes1_2, 'Tempo <--> Nasal');
%% plot Eye velocity %%
% Vertical & Horizontal eye velocity
h.axes2 = axes('Units', 'Pixels', 'Position', [70, 330, 600, 100]);
[data1_offset, data2_offset, vel] = Radial_Vel(data, n);
%h.plot2 = plot(data(1:end-1, 1, n), vel);
vel(end) = NaN;
h.plot2 = patch(recTime(1:end-1), vel, recTime(1:end-1),...
    'EdgeColor', 'interp', 'Marker', '.', 'MarkerFaceColor','flat');

set(h.axes2, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [], 'YLim', [0, 130]);

title('Radial-Velocity', 'FontSize', 14);
ylabel(h.axes2, 'Pix/sec');

%% plot Rotary Velocity%%
h.axes3 = axes('Units', 'Pixels', 'Position', [70, 190, 600, 100]);
[angle, rotVel] = DecodeRot(data(:, 4, n));
%h.plot3 = plot(recTime, -angle/360 * 12, 'LineWidth', 2);
h.plot3 = plot(recTime(1:end-1), rotVel, 'LineWidth', 2);

set(h.axes3, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'xticklabel', [], 'YLim', [-0.02, 0.5]);

title('Locomotion Velocity (Rotary)', 'FontSize', 14)
ylabel(h.axes3, 'cm/sec')

%% plot Photo Sensor
h.axes4 = axes('Units', 'Pixels', 'Position', [70, 50, 600, 100]);
h.area4 = area([NaN, NaN], [NaN, NaN], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
alpha(0.2)
hold on
h.plot4 = plot(recTime, data(:, 3, n));
hold off

set(h.axes4, 'XLimMode', 'manual', 'XLim', [-inf, inf], 'YLim', [-0.05, 0.25]);

title('Photo Sensor', 'FontSize', 14)
xlabel('Time (s)');
ylabel(h.axes4, 'V')
%% plot eye position X-Y
h.axes5 = axes('Units', 'Pixels', 'Position', [760, 490, 200, 200]);
data1_offset(end) = NaN;
h.plot5 = patch(data2_offset, -data1_offset, recTime,...
    'EdgeColor', 'interp', 'Marker', '.', 'MarkerFaceColor','flat');

range_axes5 = 0.04;
set(h.axes5, 'XLim', [-range_axes5, range_axes5], 'YLim', [-range_axes5, range_axes5]);
title('Position XY', 'FontSize', 14)

%% Controler
uicontrol('style', 'pushbutton', 'string', 'New File', 'position', [10, 750, 100, 30], 'Callback', 'Select_Open_MAT', 'FontSize', 14);
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
        recTime = linspace(params{1,n}.AIStartTime, params{1,n}.AIEndTime, size(data,1));
        %% eye position
        set(h.plot1_1, 'XData', recTime, 'YData', -data(:, 1, n));
        set(h.plot1_2, 'XData', recTime, 'YData', data(:, 2, n));
        
        if isfield(params{1,n}, 'stim1')
            ind_stim_on = find(data(:, 3, n) > 0.025, 1);
            ind_stim_off = find(data(:, 3, n) > 0.025, 1, 'last');
            y_max = max(-data(:, 1, n));
            y_min = min(-data(:, 1, n));
            set(h.area1,'XData', [recTime(ind_stim_on), recTime(ind_stim_off)], 'YData', [y_max, y_max], 'basevalue', y_min);
        else
            y_min = min(-data(:, 1, n));
            set(h.area1,'XData', [NaN, NaN], 'YData', [NaN, NaN], 'basevalue', y_min);
        end
        
        %% velocity
        [data1_offset, data2_offset, vel] = Radial_Vel(data, n);
        vel(end) = NaN;
        set(h.plot2, 'XData', recTime(1:end-1), 'YData', vel);
        
        %% rotary
        [angle, rotVel] = DecodeRot(data(:, 4, n));%
        %set(h.plot3, 'XData', recTime, 'YData', -angle/360 * 12);
        set(h.plot3, 'XData', recTime(1:end-1), 'YData', rotVel);
        
        %% photo sensor
        set(h.plot4, 'XData', recTime, 'YData', data(:, 3, n));
        if isfield(params{1,n}, 'stim1')
            y_min = min(data(:, 3, n));
            set(h.area4, 'XData', [recTime(ind_stim_on), recTime(ind_stim_off)], 'YData', [0.1, 0.1], 'basevalue', y_min);
        else
            y_min = min(data(:, 3, n));
            set(h.area4, 'XData', [NaN, NaN], 'YData', [NaN, NaN], 'basevalue', y_min);
        end
        %% position XY
        data1_offset(end) = NaN;
        set(h.plot5, 'XData', data2_offset, 'YData', -data1_offset);
        %% plot
        refreshdata(h.fig1, 'caller')
    end

%%
    function [data1_offset, data2_offset, velocity] = Radial_Vel(data, n)
        a = round(80/(recobj.sampf/1000));
        b = ones(1,a)/a;
        
        data1_filt = filter(b, a ,data(:, 1, n) - data(1, 1, n));
        data2_filt = filter(b, a ,data(:, 2, n) - data(1, 2, n));
        
        data1_offset = data1_filt - data1_filt(1);
        data2_offset = data2_filt - data2_filt(1);
        
        data1_diff = diff(data1_offset);
        data2_diff = diff(data2_offset);
        
        diff_t = params{1,n}.AIstep;
        [~, r] = cart2pol(data2_diff, -data1_diff);
        velocity = r / diff_t * 100;
        
    end

    function [positionDataDeg, rotVel] = DecodeRot(CTRin)
        % Transform counter data from rotary encoder into angular position (deg).
        signedThreshold = 2^(32-1); %resolution 32 bit
        signedData = CTRin; % data from DAQ
        signedData(signedData > signedThreshold) = signedData(signedData > signedThreshold) - 2^32;
        positionDataDeg = signedData * 360 / 1000 / 4;
        
        rotMove = positionDataDeg / 360 * 12; %12 cm Disk
        rotMove = rotMove - rotMove(1);
        a = round(80/(recobj.sampf/1000));
        b = ones(1,a)/a;
        rotMove_filt = filter(b, a, rotMove);
        rotVel = abs(diff(rotMove_filt)/params{1,n}.AIstep);
        
    end
end

%%
function plot_trace(handle, n, x, y, photo_threshold)

end
