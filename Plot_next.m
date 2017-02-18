function Plot_next(~, ~, data, set_n, params)
%%
global sobj
global recobj
global hfig
global n
%global imgobj
%%

n = Update_n(set_n);

%recTime = linspace(params{1,n}.AIStartTime - params{1,1}.AIStartTime,...
%    params{1,n}.AIEndTime - params{1,1}.AIStartTime, size(data,1));

recTime = params{1,n}.AIStartTime:1/recobj.sampf:params{1,n}.AIEndTime+1/recobj.sampf;
if length(recTime) ~= size(data,1)
    recTime = recTime(1:size(data,1));
end
Update_info_text;

% eye position
Update_plot(hfig.plot1_1, recTime, -data(:, 1, n));
Update_plot(hfig.plot1_2, recTime, data(:, 2, n));

% velocity
[data1_offset, data2_offset, vel] = Radial_Vel;
vel(end) = NaN;
Update_plot(hfig.plot2, recTime(1:end-1), vel);

% rotary
[~, rotVel] = DecodeRot(data(:, 4, n));%
Update_plot(hfig.plot3, recTime(1:end-1), rotVel);

% photo sensor
Update_plot(hfig.plot4, recTime, data(:, 3, n));

% position XY
data1_offset(end) = NaN;
Update_plot(hfig.plot5, -data1_offset, data2_offset);

% STIM timing
threshold  =  get(hfig.slider4, 'value');
Update_area(threshold)
set(hfig.line4, 'XData', [recTime(1), recTime(end)], 'YData',[threshold,threshold])

%%
% Adjust Y range
set(hfig.axes1_1, 'YLim', [min(-data(:, 1, n)), max(-data(:, 1, n))]);
set(hfig.axes1_2, 'YLim', [min(data(:, 2, n)), max(data(:, 2, n))]);
set(hfig.axes4, 'YLim', [min(data(:, 3, n))*0.9, max(data(:, 3, n))*1.1]);
%set(hfig.slider4, 'Min', min(data(:, 3, n))*1.1, 'Max', max(data(:, 3, n))*1.1);
%{
%% Update ROI Trace
if isfield(imgobj, 'dFF')  && isempty(imgobj.dFF) == 0
    %imgobj.dFF にデータがある場合は 切り出して plot に表示
    index = find(imgobj.FVt >= recTime(1) &...
        imgobj.FVt <= recTime(1) + recobj.rect/1000 + recobj.interval);
    hold on
    for i = 1:length(hfig.plot6)
        set(hfig.plot6(i), 'XData', NaN, 'YData', NaN);
    end
    clear hfig.plot6
    
    hfig.plot6 = zeros(length(imgobj.selectROI), 1);
    for i = 1:length(imgobj.selectROI)
        hfig.plot6(i) =  plot(imgobj.FVt(index), imgobj.dFF(index, imgobj.selectROI(i)));
        set(hfig.plot6(i), 'Parent', hfig.axes6);
    end
    hold off
    % Update_plot(hfig.plot6, imgobj.FVt(index), imgobj.dFF(index, imgobj.selectROI));
end
%}

%% Update plots
refreshdata(hfig.fig1, 'caller')

% Update Table info
if isfield(hfig, 'params_table')
    [rnames, values]= Get_stim_param_values(params, recobj, sobj);
    set(hfig.params_table_contents, 'Data', values, 'RowName', rnames);
end

%% %%%%%%%%subfunctions%%%%%%%%%% %%
%%
    function Update_info_text
        if isfield(params{1,n}, 'stim1')
            stim =  params{1,n}.stim1;
            pos = num2str(stim.center_position);
            sz = num2str(stim.size_deg);
            switch sobj.pattern
                case {'Uni', 'Size_rand'}
                    stim1_info_txt = ['Pos:', pos, ', Size:', sz, 'deg'];
                    
                case {'1P_Conc'}
                    dist_deg = num2str(stim.dist_deg);
                    angle_deg = num2str(stim.angle_deg);
                    stim1_info_txt = ['Center:', pos, ', Size:', sz, 'deg',...
                        ', dist:', dist_deg, 'deg', ', Ang:', angle_deg, 'deg'];
                    
                case {'2P_Conc'}
                    dist_deg = num2str(stim.dist_deg);
                    angle_deg = num2str(stim.angle_deg);
                    
                    stim2 =  params{1,n}.stim2;
                    sz2 = num2str(stim2.size_deg);
                    stim1_info_txt = ['Stim1::Pos', pos, ', Size:', sz, 'deg'];
                    stim2_info_txt = ['Stim2::Dist:', dist_deg, ', Ang:', angle_deg, 'deg',...
                        ', Size:', sz2, 'deg'];
                    set(hfig.stim2_info, 'String', stim2_info_txt);
                    
                case {'B/W'}
                    dist_deg = num2str(stim.dist_deg);
                    angle_deg = num2str(stim.angle_deg);
                    stim1_info_txt = ['Center:', pos, ', Size:', sz, 'deg',...
                        ', Dist:', dist_deg, 'deg', ', Ang:', angle_deg, 'deg',...
                        ', Lumi:', num2str(stim.color)];
                    
                case {'Looming'}
                    spd = num2str(stim.LoomingSpd_deg_s);
                    maxsz = num2str(stim.LoomingMaxSize_deg);
                    stim1_info_txt = ['Pos:', pos, 'MaxSize:', maxsz, 'deg',...
                        ', Spd:', spd, 'deg/s', ', StimLumi:', stim.lumi,...
                        ', BGLumi:'];
                    
                case {'Sin', 'Rect', 'Gabor'}
                    sf = num2str(stim.gratingSF_cyc_deg);
                    spd = num2str(stim.gratingSpd_Hz);
                    angle = num2str(stim.gratingAngle_deg);
                    stim1_info_txt = ['Pos:', pos, ', Size:', sz, 'deg',...
                        ', SF:', sf, 'cpd', ', Spd:', spd, 'Hz',...
                        ', Ang:', angle, 'deg'];
                    
                case {'Images'}
                    ImgNum = stim.Image_index;
                    stim1_info_txt = ['Pos:', pos, ', Size:', sz, 'deg',...
                        ', Image#:', ImgNum];
                    
                case {'Mosaic'}
                    stim1_info_txt = ['Pos:', pos, ', Size:', sz, 'deg',...
                        ', Density:', num2str(sobj.dots_density), '%'];
                    
                case {'FineMap'}
                    pos = num2str(stim.center_position);
                    fine_pos =  num2str(stim.center_position_FineMap);
                    stim1_info_txt = ['Center:', pos, ', Size:', sz, 'deg'];
                    stim2_info_txt = ['Center Fine Map:', fine_pos,...
                        ', Div:', num2str(sobj.div_zoom), ', Dist: ', num2str(sobj.dist), 'deg'];
                    set(hfig.stim2_info, 'String', stim2_info_txt);
                    
            end
            set(hfig.stim1_info, 'String', stim1_info_txt);
            
        else
            set(hfig.stim1_info, 'String', 'Prestim');
        end
        
    end
%%
    function Update_area(threshold)
        if isfield(params{1,n}, 'stim1')
            ind_stim_on = find(data(:, 3, n) > threshold, 1);
            ind_stim_off = find(data(:, 3, n) > threshold, 1, 'last');
            
            if isempty(ind_stim_on) == 0 && isempty(ind_stim_off) == 0
                
                [corON, corOFF] = Correct_stim_timing(ind_stim_on, ind_stim_off);
                
                set(hfig.area1_1, 'XData', [corON, corOFF], 'YData', [10,10], 'basevalue', -10);
                set(hfig.area1_2, 'XData', [corON, corOFF], 'YData', [10,10], 'basevalue', -10);
                set(hfig.area2, 'XData', [corON, corOFF], 'YData', [150,150], 'basevalue', 0);
                set(hfig.area3, 'XData', [corON, corOFF], 'YData', [2,2], 'basevalue', -0.02);
                set(hfig.area4, 'XData', [corON, corOFF], 'YData', [500, 500], 'basevalue', -10);

            else
                Erase_area;
            end
        else
            Erase_area;
        end
    end

%%
    function Erase_area
        set(hfig.area1_1,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
        set(hfig.area1_2,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
        set(hfig.area2,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
        set(hfig.area3,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
        set(hfig.area4,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
        %set(hfig.area6,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
        
        set(hfig.line4_correct_ON, 'XData',[NaN NaN],'YData',[NaN NaN])
        set(hfig.line4_correct_OFF, 'XData',[NaN NaN],'YData',[NaN NaN])
    end
%%
    function [corON, corOFF] = Correct_stim_timing(ind_on, ind_off)
        global ParamsSave
        if get(hfig.apply_threshold, 'value') == 0
            
            %Stim Timing, Corrected by Photo Sensor
            %Onset
            corON= recTime(ind_on) - (params{1,n}.stim1.centerY_pix - 40)/1024/75;
            ParamsSave{1,n}.stim1.corON =  corON;
            
            %Offset
            corOFF =  recTime(ind_off) - (params{1,n}.stim1.centerY_pix - 40)/1024/75;
            ParamsSave{1,n}.stim1.corOFF =  corOFF;
        else
            corON =  ParamsSave{1,n}.stim1.corON;
            corOFF =  ParamsSave{1,n}.stim1.corOFF;
            
            
        end
        
        set(hfig.line4_correct_ON, 'XData',[corON, corON],'YData', [-10, 500])
        set(hfig.line4_correct_OFF, 'XData',[corOFF, corOFF],'YData', [-10, 500])
    end

%%
    function [data1_offset, data2_offset, velocity] = Radial_Vel
        a = round(get(hfig.slider2, 'value')/(recobj.sampf/1000));
        b = ones(1,a)/a;
        
        data1_filt = filter(b, a ,data(:, 1, n) - data(1, 1, n));
        off1 =  str2double(get(hfig.offsetV, 'String'));
        if off1 == 0
            data1_offset = data1_filt - data1_filt(1);
        else
            data1_offset = data1_filt - off1;
        end
        
        data2_filt = filter(b, a ,data(:, 2, n) - data(1, 2, n));
        off2 =  str2double(get(hfig.offsetH, 'String'));
        if off2 == 0
            data2_offset = data2_filt - data2_filt(1);
        else
            data2_offset = data2_filt - off2;
        end
        
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
    function N = Update_n(set_n)
        if set_n == 1
            if n < size(data, 3)
                N = n + 1;
            else
                N = n;
                disp('No more trials.')
            end
            set(hfig.set_n, 'string', num2str(N))
        elseif set_n == -1
            if n < size(data, 3) + 1 && n > 1
                N = n - 1;
            else
                N = n;
                disp('First trials.')
            end
            set(hfig.set_n, 'string', num2str(N))
        else
            N = str2double(get(hfig.set_n, 'string'));
        end
    end
%%
    function Update_plot(hplot, x, y)
        set(hplot, 'XData', x, 'YData', y);
    end
%%
% end of Plot_next
end