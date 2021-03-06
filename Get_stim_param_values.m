function [rnames, values] = Get_stim_param_values(r, s)
global n
global ParamsSave
%% common parameters
values = {
    r.rect;...
    r.sampf;...
    s.pattern;...
    n
    };

%% stimulus specific parameters
pos = [num2str(s.divnum),'x',num2str(s.divnum),'=>'];
switch s.pattern
    case {'Uni', 'Size_rand'}
        rnames = {
            'Recording Time(ms)';...
            'Sampling Freq(Hz)';...
            'Stim_Pattern';...
            'Trial#';...
            'Size(deg)';...
            'Position';...
            'Stim_lumi';...
            'Stim_Color';...
            'BG_lumi';...
            'Duration(sec)';...
            'Corrected Stim ON(sec)';...
            'Corrected Stim OFF(sec)';...
            };
        
        if n <= r.prestim
            pre_val={'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA'};
            values = [values; pre_val];
        else
            s1n = ParamsSave{1,n}.stim1;
            specific_val={s1n.size_deg;...
                [pos,num2str(s1n.center_position)];...
                s1n.lumi; s1n.color(1); s.bgcol;...
                s1n.Off_time - s1n.On_time;...
                s1n.corON;...
                s1n.corOFF;...
                };
            values = [values; specific_val];
        end
        
    case {'1P_Conc'}
        rnames = {
            'Recording Time(ms)';...
            'Sampling Time(us)';...
            'Stim_Pattern';...
            'Trial#';...
            'Size(deg)';...
            'Center';...
            'Position (dist * angle)';...
            'Stim_lumi';...
            'Stim_Color';...
            'BG_lumi';...
            'Duration(sec)';...
            'Corrected Stim ON(sec)';...
            'Corrected Stim OFF(sec)'
            };
        if n <= r.prestim
            pre_val={'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA'};
            values = [values; pre_val];
        else
            s1n = ParamsSave{1,n}.stim1;
            specific_val={s1n.size_deg;... %size
                [pos,num2str(s1n.center_position)];... %center
                [num2str(s1n.dist_deg), 'deg * ', num2str(s1n.angle_deg),'deg'];... %dist * angle
                s1n.lumi; s1n.color(1); s.bgcol;...
                s1n.Off_time - s1n.On_time;...
                s1n.corON;...
                s1n.corOFF;...
                };
            values = [values; specific_val];
        end
        
    case {'2P_Conc'}
        rnames = {
            'Recording Time(ms)';...
            'Sampling Time(us)';...
            'Stim_Pattern';...
            'Trial#';...
            %stim1
            'Stim1 Size(deg)';...
            'Stim1 Position (Center)';...
            'Stim1_lumi';...
            'Stim1_Color';...
            'Stim1_Duration(sec)';...
            'Corrected Stim1 ON(sec)';...
            'Corrected Stim1 OFF(sec)';...
            %stim2
            'Stim2 Size(deg)';...
            'Stim2 Position (dist * angle)';...
            'Stim2_lumi';...
            'Stim1_Color';...
            'Stim1_Duration(sec)';...
            'Corrected Stim1 ON(sec)';...
            'Corrected Stim1 OFF(sec)';...
            'BG_lumi';...
            };
        
        if n <= r.prestim
            pre_val={'NA';'NA';'NA';'NA';'NA';'NA';'NA';...
                'NA';'NA';'NA';'NA';'NA';'NA';'NA';...
                'Na'};
            values = [values; pre_val];
        else
            s1n = ParamsSave{1,n}.stim1;
            s2n = ParamsSave{1,n}.stim2;
            specific_val={
                %stim1
                s1n.size_deg;...
                [pos,num2str(s1n.center_position)];...
                s1n.lumi; s1n.color(1);...
                s1n.Off_time - s1n.On_time;...
                s1n.corON;...
                s1n.corOFF;...
                %stim2
                s2n.size_deg;...
                [num2str(s2n.dist_deg), 'deg * ', num2str(s2n.angle_deg),'deg'];...
                s2n.lumi; s2n.color(1);...
                s2n.Off_time - s2n.On_time;...
                s2n.corON;...
                s2n.corOFF;...
                %
                num2str(s.bgcol)
                };
            values = [values; specific_val];
        end
        
    case {'B/W'}
        rnames = {
            'Recording Time(ms)';...
            'Sampling Time(us)';...
            'Stim_Pattern';...
            'Trial#';...
            'Size(deg)';...
            'Center';...
            'Position (dist * angle)';...
            'Stim_lumi';...
            'Stim_Color';...
            'BG_lumi';...
            'Duration(sec)';...
            'Corrected Stim ON(sec)';...
            'Corrected Stim OFF(sec)'
            };
        if n <= r.prestim
            pre_val={'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA'};
            values = [values; pre_val];
        else
            s1n = ParamsSave{1,n}.stim1;
            specific_val={s1n.size_deg;...
                [pos,num2str(s1n.center_position)];...
                [num2str(s1n.dist_deg), 'deg * ', num2str(s1n.angle_deg),'deg'];...
                s1n.lumi; s1n.color(1); s.bgcol;...
                s1n.Off_time - s1n.On_time;...
                s1n.corON;...
                s1n.corOFF;...
                };
            values = [values; specific_val];
        end
        
    case {'Looming'}
        rnames = {
            'Recording Time(ms)';...
            'Sampling Time(us)';...
            'Stim_Pattern';...
            'Trial#';...
            'Position';...
            'Speed(deg/s)';...
            'Max Size(deg)';...
            'Stim_lumi';...
            'Stim_Color';...
            'BG_lumi';...
            'Duration(sec)';...
            'Corrected Stim ON(sec)';...
            'Corrected Stim OFF(sec)'
            };
        
        if n <= r.prestim
            pre_val={'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA'};
            values = [values; pre_val];
        else
            s1n = ParamsSave{1,n}.stim1;
            specific_val={[pos,num2str(s1n.center_position)];...
                s1n.LoomingSpd_deg_s; s1n.LoomingMaxSize_deg;...
                s1n.lumi; s.bgcol; s1n.color(1);...
                s1n.Off_time - s1n.On_time;...
                s1n.corON;...
                s1n.corOFF;...
                };
            values = [values; specific_val];
        end
        
        
    case {'Sin', 'Rect', 'Gabor'}
        rnames = {
            'Recording Time(ms)';...
            'Sampling Time(us)';...
            'Stim_Pattern';...
            'Trial#';...
            'Size(deg)';...
            'Position';...
            'Spatial Freq(cycle/deg)';...
            'Temporal Freq(Hz)';...
            'Angle (deg)';
            'Stim_lumi';...
            'Stim_Color';...
            'BG_lumi';...
            'Duration(sec)';...
            'Corrected Stim ON(sec)';...
            'Corrected Stim OFF(sec)'
            };
        if n <= r.prestim
            pre_val={'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA'};
            values = [values; pre_val];
        else
            s1n = ParamsSave{1,n}.stim1;
            specific_val={s1n.size_deg;...
                [pos,num2str(s1n.center_position)];...
                s1n.gratingSF_cyc_deg; s1n.gratingSpd_Hz; s1n.gratingAngle_deg;...
                s1n.lumi; s1n.color(1); s.bgcol;...
                s1n.Off_time - s1n.On_time;...
                s1n.corON;...
                s1n.corOFF;...
                };
            values = [values; specific_val];
        end
          
    case {'Images'}
        rnames = {
            'Recording Time(ms)';...
            'Sampling Time(us)';...
            'Stim_Pattern';...
            'Trial#';...
            'Size(deg)';...
            'Position';...
            'Image#';...
            'BG_lumi';...
            'Duration(sec)';
            'Corrected Stim ON(sec)';...
            'Corrected Stim OFF(sec)'
            };
        if n <= r.prestim
            pre_val={'NA';'NA';'NA';'NA';'NA';'NA';'NA'};
            values = [values; pre_val];
        else
            s1n = ParamsSave{1,n}.stim1;
            specific_val={s1n.size_deg;...
                [pos,num2str(s1n.center_position)];...
                s1n.Image_index; s.bgcol;...
                s1n.Off_time - s1n.On_time;...
                s1n.corON;...
                s1n.corOFF;...
                };
            values = [values; specific_val];
        end
        
    case {'Mosaic'}
        rnames = {
            'Recording Time(ms)';...
            'Sampling Time(us)';...
            'Stim_Pattern';...
            'Trial#';...
            %
            'Center';...
            'Dist(deg)';...
            'Div';...
            'Dot density';...
            'Stim_lumi';...
            'Stim_Color';...
            'BG_lumi';...
            'Duration(sec)';
            'Corrected Stim ON(sec)';...
            'Corrected Stim OFF(sec)'
            };
        if n <= r.prestim
            pre_val={'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA'};
            values = [values; pre_val];
        else
            s1n = ParamsSave{1,n}.stim1;
            specific_val={
                [pos,num2str(s1n.center_position)];...
                s.dist;...%dist
                s.div_zoom;...%div
                s.dots_density;...%density
                s1n.lumi; s1n.color(1); s.bgcol;...
                s1n.Off_time - s1n.On_time;...
                s1n.corON;...
                s1n.corOFF;...
                };
            values = [values; specific_val];
        end
        
    case 'MoveBar'
        rnames = {
            'Recording Time(ms)';...
            'Sampling Time(us)';...
            'Stim_Pattern';...
            'Trial#';...
            %
            'Bar Width(deg)';...
            'Speed (deg/s)';...
            'Angle (deg)';...
            'Stim_lumi';...
            'Stim_Color';...
            'BG_lumi';...
            'Duration(sec)';
            'Corrected Stim ON(sec)';...
            'Corrected Stim OFF(sec)'
            };
        
        if n <= r.prestim
            pre_val={'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA'};
            values = [values; pre_val];
        else
            s1n = ParamsSave{1,n}.stim1;
            specific_val={s1n.size_deg;...
                s1n.MovebarSpd_deg_s;...
                s1n.MovebarDir_angle_deg;...
                s1n.lumi; s1n.color(1); s.bgcol;...
                s1n.Off_time - s1n.On_time;...
                s1n.corON;...
                s1n.corOFF;...
                };
            values = [values; specific_val];
        end
        
    case {'FineMap'}
        rnames = {
            'Recording Time(ms)';...
            'Sampling Time(us)';...
            'Stim_Pattern';...
            'Trial#';...
            %
            'Size(deg)';...
            'Center';...
            'Division';...
            'Division length(deg)';...
            'Stim_lumi';...
            'Stim_Color';...
            'BG_lumi';...
            'Duration(sec)';
            'Corrected Stim ON(sec)';...
            'Corrected Stim OFF(sec)'
            };
        if n <= r.prestim
            pre_val={'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA';'NA'};
            values = [values; pre_val];
        else
            s1n = ParamsSave{1,n}.stim1;
            fpos = [num2str(s.div_zoom),'x',num2str(s.div_zoom),'=>'];
            specific_val={s1n.size_deg;...
                [pos,num2str(s1n.center_position)];...
                [fpos,num2str(s1n.center_position_FineMap)];...%division n*n => n
                s.dist;...%dist(deg)
                s1n.lumi; s1n.color(1); s.bgcol;...
                s1n.Off_time - s1n.On_time;...
                s1n.corON;...
                s1n.corOFF;...
                };
            values = [values; specific_val];
        end
end
%{
rnames = {'Recording Time (ms)';...
    'Sampling Time (us)';...
    'PlotType';'Cycle#';...
    'StimON/OFF';...
    'Stim_Sz1(pix)';...
    'Stim_Sz2(pix)';...
    'Monitor Divide';...
    'Stim1_Pos';...
    'Stim2_Pos(dist&ang)';...
    'Stim_Pattern';...
    'Duration';...
    'Stim_Color';...
    'BG_Color';...
    'Direction';...
    'Shift_Angle';...
    'Grating_Freq';...
    'Shift_Speed';...
    'Dealy TTL2(sec)';...
    'Delay PTBon (sec)';...
    'Correct Delay PTBon';...
    'Elapsed PTBon (sec)';...
    'Images_#';};
%}
end
