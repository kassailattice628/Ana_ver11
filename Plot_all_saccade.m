
figure
hold on
for n = (recobj.prestim + 1) : size(ParamsSave,2);
    recTime = ParamsSave{1,n}.AIStartTime:1/recobj.sampf:ParamsSave{1,n}.AIEndTime+1/recobj.sampf;
    if isfield(ParamsSave{1,n}, 'sac_t')
        sac_t = ParamsSave{1,n}.sac_t;
        locs = zeros(1, length(sac_t));
    end
    
    %%
    
    if exist('locs', 'var') && ~isempty(locs)
        time = 1/recobj.sampf : 1/recobj.sampf : 400 * 1/recobj.sampf;
        time = repmat(time', [1, length(locs)]);
        for i = 1:length(locs)
            t_point = (locs(i)-100):(locs(i)+299);
            if max(t_point) > size(DataSave,1)
                t_end = 400 + size(DataSave,1)-max(t_point);
                t_point(1:t_end)= (locs(i)-100):size(DataSave,1);
                t_point(t_end + 1: end) = size(DataSave,1);
            elseif t_point(1) <= 0
                t_point(t_point <= 0) = 1;
            end
            
            H(:, i) = DataSave(t_point, 1, n) - DataSave(t_point(1), 1, n);
            V(:, i) = DataSave(t_point, 2, n) - DataSave(t_point(1), 2, n);
        end
        
        
        plot(time, H)
    end
    
end
hold off