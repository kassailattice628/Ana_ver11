function trial = Detect_trial_with_Behavior(P, R, Type)
% DETECT_TRIAL_EYEMOVE(ParamsSave, recboj)

trial = [];
prestim = R.prestim;
for i = (prestim + 1) :size(P,2)
    
    switch Type
        case 'Saccade'
            timing = P{1,i}.sac_t;
            
        case 'Locomotion'
            timing = P{1,i}.loc_t;
    end
    
    %timing = P{1,i}.sac_t;
    %check saccade?
    if ~isempty(timing)
        if isfield(P{1,i}.stim1, 'corON')
            t1 = P{1,i}.stim1.corON;
            t2 = P{1,i}.stim1.corOFF;
        end
        
        %push behaving trial into the list
        for i2 = 1:length(timing)
            if t1 < timing(i2) &&  t2 > timing(i2)
                trial = [trial, i-prestim];
                break
            end
        end
        
    end
end