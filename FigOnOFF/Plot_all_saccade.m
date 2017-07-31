function  Plot_all_saccade(~, ~, r, data)
global ParamsSave
figure
ax1 = subplot(2,1,1);
set(ax1, 'YLim',[-4,4]);
ax2 = subplot(2,1,2);
set(ax2, 'YLim',[-4,4]);
hold on

d_filt_eye = designfilt('lowpassfir', 'FilterOrder', 12,...
    'CutoffFrequency', 30, 'SampleRate', r.sampf);

for n = (r.prestim + 1) : size(ParamsSave,2);
    data1 = data(:,1,n);
    data_filt1 = filter(d_filt_eye, data1);
    
    data2 = data(:,2,n);
    data_filt2 = filter(d_filt_eye, data2);
    
    recTime = ParamsSave{1,n}.AIStartTime:1/r.sampf:ParamsSave{1,n}.AIEndTime+1/r.sampf;
    if isfield(ParamsSave{1,n}, 'sac_t')
        sac_t = ParamsSave{1,n}.sac_t;
        locs = zeros(1, length(sac_t));
        for i = 1:length(sac_t)
            locs(i) = find(sac_t(i) > recTime, 1, 'last') +1;
        end
    end
    
    %%
    
    if exist('locs', 'var') && ~isempty(locs)
        H=[];
        V=[];
        time = 1/r.sampf : 1/r.sampf : 400 * 1/r.sampf;
        time = repmat(time', [1, length(locs)]);
        for i = 1:length(locs)
            t_point = (locs(i)-100):(locs(i)+299);
            if max(t_point) > size(data1,1)
                t_end = 400 + size(data1,1)-max(t_point);
                t_point(1:t_end)= (locs(i)-100):size(data1,1);
                t_point(t_end + 1: end) = size(data1,1);
            elseif t_point(1) <= 0
                t_point(t_point <= 0) = 1;
            end
            
            H(:, i) = data_filt1(t_point) - data_filt1(t_point(1));
            V(:, i) = data_filt2(t_point) - data_filt2(t_point(1));
        end
        subplot(ax1)
        hold on
        plot(time, H)
        hold off
        
        subplot(ax2)
        hold on
        plot(time, V)
        hold off
    end
end
end
