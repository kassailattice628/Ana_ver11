function Correlation_Eye_Run(P, R)


t_sac_all = [];
t_loc_all = [];
trial_sac_with_stim  = [];
trial_sac_without_stim  = [];
trial_loc_with_stim  = [];
trial_loc_without_stim  = [];
prestim = R.prestim;

for i = 1 :size(P,2)
    t_sac = P{1,i}.sac_t;
    t_sac_all = [t_sac_all, t_sac];
    
    t_loc = P{1,i}.loc_t(:,1);
    t_loc = t_loc';
    t_loc_all = [t_loc_all, t_loc];
    
    %%
    if i > prestim
        if isfield(P{1,i}.stim1, 'corON')
            t1 = P{1,i}.stim1.corON;
            t2 = P{1,i}.stim1.corOFF;
        else
            t1 = P{1,i}.AIStartTime + P{1,i}.vbl_2;
            t2 = P{1,i}.AIStartTime + P{1,i}.vbl_3;
        end
    else
        t1 = P{1,i}.AIStartTime;
        t2 = P{1,i}.AIEndTime;
    end
    
    
    
    %%
    if ~isempty(t_sac)
        i_out =  PushList(t1, t2, t_sac, i, 1);
        trial_sac_with_stim = [trial_sac_with_stim, i_out];
        
        i_out =  PushList(t1, t2, t_sac, i, 0);
        trial_sac_without_stim = [trial_sac_without_stim, i_out];
    end
    
    if ~isempty(t_loc)
        i_out =  PushList(t1, t2, t_loc, i, 1);
        trial_loc_with_stim = [trial_loc_with_stim, i_out];
        
        i_out =  PushList(t1, t2, t_loc, i, 0);
        trial_loc_without_stim = [trial_loc_without_stim, i_out];
    end
    
end
disp('End')
%% saccade のタイミングと Locomotion のタイミングを比較
edges = 1:2:1500;
figure
histogram(t_loc_all, edges);
hold on
histogram(t_sac_all, edges);



end

%%
function i_out = PushList(t1, t2, timing, i_list, type)
i_out = [];

for i = 1:length(timing)
    switch type
        %with stim
        case 1
            if t1 < timing(i) &&  t2 > timing(i)
                i_out = i_list;
                break
            end
            
            %without stim
        case 0
            if t2 < timing(i)
                i_out = i_list;
                break
            end
    end
end
end