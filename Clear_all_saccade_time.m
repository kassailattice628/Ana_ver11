function Clear_all_saccade_time(~,~)
global ParamsSave

for n = 1:size(ParamsSave, 2)
    ParamsSave{1,n}.sac_t = [];
end
