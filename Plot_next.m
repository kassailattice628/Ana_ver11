function Plot_next(~, ~, data, set_n, params)
global recobj
global n
global hfig

n = update_n(set_n, data);

recTime = linspace(params{1,n}.AIStartTime, params{1,n}.AIEndTime, size(data,1));

% eye position
update_plot(hfig.plot1_1, recTime, -data(:, 1, n));
update_plot(hfig.plot1_2, recTime, data(:, 2, n));

% velocity
[data1_offset, data2_offset, vel] = Radial_Vel(data, n);
vel(end) = NaN;
update_plot(hfig.plot2, recTime(1:end-1), vel);

% rotary
[~, rotVel] = DecodeRot(data(:, 4, n));%
update_plot(hfig.plot3, recTime(1:end-1), rotVel);

% photo sensor
update_plot(hfig.plot4, recTime, data(:, 3, n));

% position XY
data1_offset(end) = NaN;
update_plot(hfig.plot5, data2_offset, -data1_offset);

% STIM timing
update_area(get(hfig.slider4, 'value'), params)
set(hfig.line4, 'XData', [recTime(1), recTime(end)], 'YData',[get(hfig.slider4, 'value'), get(hfig.slider4, 'value')])
% plot
refreshdata(hfig.fig1, 'caller')

%%
    function update_area(threshold, params)
        if isfield(params{1,n}, 'stim1')
            ind_stim_on = find(data(:, 3, n) > threshold, 1);
            ind_stim_off = find(data(:, 3, n) > threshold, 1, 'last');
            
            if isempty(ind_stim_on) == 0 && isempty(ind_stim_off) == 0
                set_area(hfig.area1_1, recTime, ind_stim_on, ind_stim_off, -data(:,1,n));
                set_area(hfig.area1_2, recTime, ind_stim_on, ind_stim_off, data(:,2,n));
                set_area(hfig.area2, recTime(1:end-1), ind_stim_on, ind_stim_off, [0, 150]);
                set_area(hfig.area3, recTime(1:end-1), ind_stim_on, ind_stim_off, [-0.02, 2]);
                set_area(hfig.area4, recTime, ind_stim_on, ind_stim_off, [-0.01, 0.25]);
            else
                set(hfig.area1_1,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
                set(hfig.area1_2,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
                set(hfig.area2,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
                set(hfig.area3,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
                set(hfig.area4,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
            end
        else
            set(hfig.area1_1,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
            set(hfig.area1_2,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
            set(hfig.area2,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
            set(hfig.area3,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
            set(hfig.area4,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
        end
    end

%%
    function [data1_offset, data2_offset, velocity] = Radial_Vel(data, n)
        a = round(get(hfig.slider2, 'value')/(recobj.sampf/1000));
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

%%
    function [positionDataDeg, rotVel] = DecodeRot(CTRin)
        % Transform counter data from rotary encoder into angular position (deg).
        signedThreshold = 2^(32-1); %resolution 32 bit
        signedData = CTRin; % data from DAQ
        signedData(signedData > signedThreshold) = signedData(signedData > signedThreshold) - 2^32;
        positionDataDeg = signedData * 360 / 1000 / 4;
        
        rotMove = positionDataDeg / 360 * 12; %12 cm Disk
        rotMove = rotMove - rotMove(1);
        a = round(get(hfig.slider2, 'value')/(recobj.sampf/1000));
        b = ones(1,a)/a;
        rotMove_filt = filter(b, a, rotMove);
        rotVel = abs(diff(rotMove_filt)/params{1,n}.AIstep);
        
    end

%%
    function set_area(harea, recTime, ind_on, ind_off, data)
        y_max = max(data);
        y_min = min(data);
        if ind_off == length(recTime)
            ind_off = ind_off - 1;
        end
        set(harea, 'XData', [recTime(ind_on), recTime(ind_off)], 'YData', [y_max, y_max], 'basevalue', y_min);
    end

%%
    function N = update_n(set_n, data)
        if set_n == 1
            if n < size(data, 3)
                N = n + 1;
            else
                N = n;
            end
            set(hfig.set_n, 'string', num2str(N))
        elseif set_n == -1
            if n < size(data, 3) + 1 && n > 1
                N = n - 1;
            else
                N = n;
            end
            set(hfig.set_n, 'string', num2str(N))
        else
            N = str2double(get(hfig.set_n, 'string'));
        end
    end

%%
    function update_plot(hplot, x, y)
        set(hplot, 'XData', x, 'YData', y);
    end


end
