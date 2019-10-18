function trial = Detect_trial_EyeMove(P, R)
% DETECT_TRIAL_EYEMOVE(ParamsSave, recboj)
trial = [];
prestim = R.prestim;
for i = (prestim + 1) :size(P,2)
    t_sac = P{1,i}.sac_t;
    %check saccade?
    if ~isempty(t_sac)
        if isfield(P{1,i}.stim1, 'corON')
            t1 = P{1,i}.stim1.corON;
            t2 = P{1,i}.stim1.corOFF;
        end
        
        %push saccade trial
        for i2 = 1:length(t_sac)
            if t1 < t_sac(i2) &&  t2 > t_sac(i2)
                trial = [trial, i-prestim];
                break
            end
        end
        
    end
end