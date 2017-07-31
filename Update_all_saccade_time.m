function Update_all_saccade_time(~,~, p, r, data)
global ParamsSave
global hfig
global n

for n = 1:size(ParamsSave, 2)
    disp(n)
    Plot_next([],[],data, 1, p, r)
    
    str = get(hfig.sac_locs, 'string');
    sac_t = str2num(str);
    
    ParamsSave{1,n}.sac_t = sac_t;
end
