function Update_saccade_time(~, ~, p, r, data, opt)
% detect saccade event
% opt == 1, update sac_time from GUI
% opt == 2, re-calcurate sac_time from velocity data
%%
global hfig
global n
global ParamsSave

%%

recTime = p{1,n}.AIStartTime:1/r.sampf:p{1,n}.AIEndTime+1/r.sampf;
[~, ~, vel, ~, ~] = Radial_Vel(r, data, recTime);

%%
if opt ==  1
    str = get(hfig.sac_locs, 'string');
    sac_t = str2num(str);
    ParamsSave{1,n}.sac_t = sac_t;
    
    if length(recTime) ~= size(data,1)
        recTime = recTime(1:size(data,1));
    end
    locs = zeros(1, length(sac_t));
    pks = locs;
    for i = 1:length(sac_t)
        locs(i) = find(sac_t(i) > recTime, 1, 'last') + 1;
        pks(i) = vel(locs(i));
    end
    
    
    
elseif opt == 2
    [pks,locs] = findpeaks(vel, 'MinPeakHeight', 45, 'MinPeakDistance', 500);
    pks = pks(pks < 250);
    locs = locs(pks < 250);
    if isempty(pks)
        ParamsSave{1,n}.sac_t = [];
    else
        ParamsSave{1,n}.sac_t = recTime(locs);
    end
    
    str_n = zeros(1, length(locs));
    for i = 1:length(locs)
        loc_t = round(recTime(locs(i))*1000)/1000;
        str_n(i) = loc_t;
    end
    str = num2str(str_n);
    set(hfig.sac_locs, 'string', str)
    
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reset event plot
set(hfig.plot1_1_sac, 'XData', NaN, 'YData', NaN);
set(hfig.plot1_2_sac, 'XData', NaN, 'YData', NaN);
set(hfig.plot2_2, 'XData', NaN, 'YData', NaN);

% Update plot
set(hfig.plot1_1_sac, 'XData', ParamsSave{1,n}.sac_t, 'YData', data(locs, 1, n));
set(hfig.plot1_2_sac, 'XData', ParamsSave{1,n}.sac_t, 'YData', data(locs, 2, n));
set(hfig.plot2_2, 'XData', ParamsSave{1,n}.sac_t, 'YData', pks);

% update additional plot
if isfield(hfig, 'peri_saccade')
    get_peri_saccade(locs, data, n, r);
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
