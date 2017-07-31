function Update_saccade_time(h, ~, p, r, data)
global hfig
global ParamsSave
global n

str = get(h, 'string');
sac_t = str2num(str);

%update, saccade event
ParamsSave{1,n}.sac_t = sac_t;

%reset event plot
set(hfig.plot1_1_sac, 'XData', NaN, 'YData', NaN);
set(hfig.plot1_2_sac, 'XData', NaN, 'YData', NaN);
set(hfig.plot2_2, 'XData', NaN, 'YData', NaN);

%update event
if ~isempty(sac_t)
    recTime = p{1,n}.AIStartTime:1/r.sampf:p{1,n}.AIEndTime+1/r.sampf;
    [~, ~, vel, ~, ~] = Radial_Vel(r, data, recTime);
    [locs, pks] = time2loc(sac_t, vel);
    
    %Update plot
    set(hfig.plot1_1_sac, 'XData', ParamsSave{1,n}.sac_t, 'YData', data(locs, 1, n));
    
    set(hfig.plot1_2_sac, 'XData', ParamsSave{1,n}.sac_t, 'YData', data(locs, 2, n));
    
    set(hfig.plot2_2, 'XData', ParamsSave{1,n}.sac_t, 'YData', pks);
    
    %update plot
    if isfield(hfig, 'peri_saccade')
        get_peri_saccade(locs, data, n, r);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [l, p] = time2loc(t, vel)
        %find nerest data point from time
        recTime = ParamsSave{1,n}.AIStartTime:1/r.sampf:ParamsSave{1,n}.AIEndTime+1/r.sampf;
        if length(recTime) ~= size(data,1)
            recTime = recTime(1:size(data,1));
        end
        
        l = zeros(1, length(t));
        p = l;
        for i = 1:length(t)
            l(i) = find(t(i) > recTime, 1, 'last') + 1;
            p(i) = vel(l(i));
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end