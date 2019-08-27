function Plot_next(~, ~, data, set_n, p, r)
%%
global sobj
global hfig
global n
global ParamsSave
%global imgobj
%%
zoom out
n = Update_n(set_n);

recTime = p{1,n}.AIStartTime:1/r.sampf:p{1,n}.AIEndTime+1/r.sampf;
if length(recTime) ~= size(data,1)
    recTime = recTime(1:size(data,1));
end
Update_info_text;

% eye position
Update_plot(hfig.plot1_1, recTime, data(:, 1, n));
Update_plot(hfig.plot1_2, recTime, data(:, 2, n));

% eye velocity
[data1_offset, data2_offset, vel, pks, locs] = Radial_Vel(r, data, recTime);
vel(end) = NaN;

Update_plot(hfig.plot2_1, recTime(1:end-1), vel);
Update_plot(hfig.plot2_2, NaN, NaN);
set(hfig.plot2_2, 'XDATA', recTime(locs), 'YData', pks);

Update_plot(hfig.plot1_1_sac, NaN, NaN)
set(hfig.plot1_1_sac, 'XDATA', recTime(locs), 'YData', data(locs, 1, n));
Update_plot(hfig.plot1_2_sac, NaN, NaN)
set(hfig.plot1_2_sac, 'XDATA', recTime(locs), 'YData', data(locs, 2, n));

% saccade timing
if ~isempty(locs)
    locs_text = cell(length(locs), 1);
    str_n = zeros(1, length(locs));
    for i = 1:length(locs)
        % round
        loc_t = round(recTime(locs(i))*1000)/1000;
        locs_text{i} = num2str(loc_t);
        str_n(i) = loc_t;
    end
    str = num2str(str_n);
    set(hfig.sac_locs, 'string', str);
else
    set(hfig.sac_locs, 'string', '');
end

% running, rotary encoder

if size(data,2) == 4
    ch_rot = 4;
    
elseif size(data,2) == 5
    ch_rot = 5;
    %eye_open_ratio
    %Update_plot(hfig.line2, recTime(1:end-1), data(1:end-1, 4, n));
    Update_plot(hfig.plot3_2, recTime(1:end-1), data(1:end-1, 4, n));
end

[~, rotVel] = DecodeRot(data(:, ch_rot, n), n, p, r);%
Update_plot(hfig.plot3_1, recTime(1:end-1), rotVel);
%Update_plot(hfig.line1, recTime(1:end-1), rotVel);

% photo sensor
Update_plot(hfig.plot4, recTime, data(:, 3, n));

% STIM timing
threshold  =  get(hfig.slider4, 'value');
Update_area(threshold)
set(hfig.line4, 'XData', [recTime(1), recTime(end)], 'YData',[threshold,threshold]);

% position XY
if isfield(hfig, 'eye_position')
    Update_plot(hfig.plot5, data1_offset, data2_offset);
end

% peri-saccade
if isfield(hfig, 'peri_saccade')
    get_peri_saccade(locs, data, n, r);
end

%%
% Adjust Y range
range_plot1_1 = str2num(get(hfig.range_p1_1, 'String'));
range_plot1_2 = str2num(get(hfig.range_p1_2, 'String'));
set(hfig.axes1_1, 'YLim', range_plot1_1);
set(hfig.axes1_2, 'YLim', range_plot1_2);
set(hfig.axes4, 'YLim', [min(data(:, 3, n))*0.9, max(data(:, 3, n))*1.1]);

%% Update plots
%refreshdata(hfig.fig1, 'caller')
drawnow % <- faster than 'refreshdata' ?

% Update Eye position
if isfield(hfig, 'eye_position')
    refreshdata(hfig.eye_position, 'caller');
end

% Update Table info
if isfield(hfig, 'params_table')
    [rnames, values]= Get_stim_param_values(r, sobj);
    set(hfig.params_table_contents, 'Data', values, 'RowName', rnames);
end


%% —ÕŽž
%{
figure,
subplot(3,1,1)
plot(recTime, data(:, 1, n))
xlim([recTime(1), recTime(end)])
ylim([-4, -3.6])

subplot(3,1,2)
plot(recTime, data(:, 2, n))
xlim([recTime(1), recTime(end)])
ylim([-4.3, -3.9])
subplot(3,1,3)
plot(recTime(1:end-1), rotVel)
xlim([recTime(1), recTime(end-1)])
ylim([0, 15])
%}

%% %%%%%%%%subfunctions%%%%%%%%%% %%
%%
    function Update_info_text
        if isfield(p{1,n}, 'stim1')
            stim =  p{1,n}.stim1;
            pos = num2str(stim.center_position);
            sz = num2str(stim.size_deg);
            switch sobj.pattern
                case {'Uni', 'Size_rand'}
                    stim1_info_txt = ['Pos:', pos, ', Size:', sz, 'deg'];
                    if strcmp(sobj.mode, 'Concentric')
                        dist_deg = num2str(stim.dist_deg);
                        angle_deg = num2str(stim.angle_deg);
                        stim1_info_txt = ['Center:', pos, ', Size:', sz, 'deg',...
                            ', dist:', dist_deg, 'deg', ', Ang:', angle_deg, 'deg'];
                    end
                    %%%%%% for old version %%%%%%%
                case {'1P_Conc'}
                    dist_deg = num2str(stim.dist_deg);
                    angle_deg = num2str(stim.angle_deg);
                    stim1_info_txt = ['Stim1::Dist:', dist_deg, ', Ang:', angle_deg, 'deg',...
                        ', Size:', sz, 'deg'];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                case {'2P', '2P_Conc'}
                    dist_deg = num2str(stim.dist_deg);
                    angle_deg = num2str(stim.angle_deg);
                    
                    stim2 =  p{1,n}.stim2;
                    sz2 = num2str(stim2.size_deg);
                    stim1_info_txt = ['Stim1::Pos', pos, ', Size:', sz, 'deg'];
                    stim2_info_txt = ['Stim2::Dist:', dist_deg, ', Ang:', angle_deg, 'deg',...
                        ', Size:', sz2, 'deg'];
                    set(hfig.stim2_info, 'String', stim2_info_txt);
                    
                case {'B/W'}
                    dist_deg = num2str(stim.dist_deg);
                    angle_deg = num2str(stim.angle_deg);
                    stim1_info_txt = ['Center:', pos, ', Size:', sz, 'deg'];
                    stim2_info_txt = ['Dist:', dist_deg, 'deg', ', Ang:', angle_deg, 'deg',...
                        ', Lumi:', num2str(stim.color)];
                    set(hfig.stim2_info, 'String', stim2_info_txt);
                    
                case {'Looming'}
                    spd = num2str(stim.LoomingSpd_deg_s);
                    maxsz = num2str(stim.LoomingMaxSize_deg);
                    stim1_info_txt = ['Pos:', pos, ', MaxSize:', maxsz, 'deg',...
                        ', Spd:', spd, 'deg/s'];
                    
                case {'Sin', 'Rect', 'Gabor'}
                    sf = num2str(stim.gratingSF_cyc_deg);
                    spd = num2str(stim.gratingSpd_Hz);
                    angle = num2str(stim.gratingAngle_deg);
                    stim1_info_txt = ['Pos:', pos, ', Size:', sz, 'deg'];
                    stim2_info_txt = ['SF:', sf, 'cpd', ', Spd:', spd, 'Hz',...
                        ', Ang:', angle, 'deg'];
                    set(hfig.stim2_info, 'String', stim2_info_txt);
                    
                case {'MoveBar', 'MoveSpot'}
                    angle=num2str(stim.MovebarDir_angle_deg);
                    spd = num2str(stim.MovebarSpd_deg_s);
                    stim1_info_txt = ['Width:', sz, 'deg', ', Spd:', spd,...
                        'deg/s', ', Ang:', angle, 'deg'];
                    
                case 'StaticBar'
                    angle = num2str(stim.BarOri_angle_deg);
                    stim1_info_txt = ['Width:', sz, 'deg', ', Ang:', angle, 'deg'];
                    
                case {'Images'}
                    ImgNum = stim.Image_index;
                    stim1_info_txt = ['Pos:', pos, ', Size:', sz, 'deg',...
                        ', Image#:', num2str(ImgNum)];
                    
                case {'Mosaic'}
                    stim1_info_txt = ['Pos:', pos, ', Size:', sz, 'deg',...
                        ', Density:', num2str(sobj.dots_density), '%'];
                    
                case {'FineMap'}
                    pos = num2str(stim.center_position);
                    fine_pos =  num2str(stim.center_position_FineMap);
                    stim1_info_txt = ['Center:', pos, ', Size:', sz, 'deg'];
                    stim2_info_txt = ['Fine Map:', fine_pos,...
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
        if isfield(p{1,n}, 'stim1')
            ind_stim_on = find(data(:, 3, n) > threshold, 1);
            ind_stim_off = find(data(:, 3, n) > threshold, 1, 'last');
            
            if ~isempty(ind_stim_on) && ~isempty(ind_stim_off)
                
                [corON, corOFF] = Correct_stim_timing(ind_stim_on, ind_stim_off);
                
                set(hfig.area1_1, 'XData', [corON, corOFF], 'YData', [10,10], 'basevalue', -10);
                set(hfig.area1_2, 'XData', [corON, corOFF], 'YData', [10,10], 'basevalue', -10);
                set(hfig.area2, 'XData', [corON, corOFF], 'YData', [250,250], 'basevalue', 0);
                set(hfig.area3, 'XData', [corON, corOFF], 'YData', [30,30], 'basevalue', -0.02);
                set(hfig.area4, 'XData', [corON, corOFF], 'YData', [300, 300], 'basevalue', -10);
                
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
        if get(hfig.apply_threshold, 'value') == 0
            
            %Stim Timing, Corrected by Photo Sensor
            %Onset
            corON= recTime(ind_on) - (p{1,n}.stim1.centerY_pix - 40)/1024/75;
            ParamsSave{1,n}.stim1.corON =  corON;
            
            %Offset
            corOFF =  recTime(ind_off) - (p{1,n}.stim1.centerY_pix - 40)/1024/75;
            ParamsSave{1,n}.stim1.corOFF =  corOFF;
        else
            %Stim Timing, Corrected by PTB3 info
            corON =  ParamsSave{1,n}.stim1.corON;
            corOFF =  ParamsSave{1,n}.stim1.corOFF;
        end
        
        set(hfig.line4_correct_ON, 'XData',[corON, corON],'YData', [-10, 500])
        set(hfig.line4_correct_OFF, 'XData',[corOFF, corOFF],'YData', [-10, 500])
    end
%%
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