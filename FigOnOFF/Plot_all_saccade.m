function  Plot_all_saccade(~, ~, r, data)
global ParamsSave
figure
%
ax1 = subplot(2,2,1);
set(ax1, 'YLim',[-1,1]);
title('horizontal')
%
ax2 = subplot(2,2,3);
set(ax2, 'YLim',[-1,1]);
title('vertical')
%
ax3 = subplot(2,2,[2 4]);
title('end position')
axis square
grid on

set(ax3, 'XLim',[data(1,1,1)-0.5, data(1,1,1)+0.5], 'YLim',[data(1,2,1)-0.5, data(1,2,1)+0.5]);
hold on

d_filt_eye = designfilt('lowpassfir', 'FilterOrder', 12,...
    'CutoffFrequency', 30, 'SampleRate', r.sampf);

for n = (r.prestim + 1) : size(ParamsSave,2)
    %eye_position, Horizontal
    data1 = data(:,1,n);
    data_filt1 = filter(d_filt_eye, data1);
    
    %eye_position, Vertical
    data2 = data(:,2,n);
    data_filt2 = filter(d_filt_eye, data2);
    
    %saccade timing
    recTime = ParamsSave{1,n}.AIStartTime:1/r.sampf:ParamsSave{1,n}.AIEndTime+1/r.sampf;
    if isfield(ParamsSave{1,n}, 'sac_t')
        sac_t = ParamsSave{1,n}.sac_t;
        locs = zeros(1, length(sac_t));
        for i = 1:length(sac_t)
            locs(i) = find(sac_t(i) > recTime, 1, 'last') +1;
        end
    end
    
    %%
    %extract saccade
    if exist('locs', 'var') && ~isempty(locs)
        H=[];
        V=[];
        
        H_end = [];
        V_end = [];
        %use 400 point (0.2 sec)
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
            
            %offset start eye position at trial start
            H(:, i) = data_filt1(t_point) - data_filt1(t_point(1));
            V(:, i) = data_filt2(t_point) - data_filt2(t_point(1));
            
            %saccade endposition
            H_end(i) = data_filt1(t_point(200));
            V_end(i) = data_filt2(t_point(200));
        end
        subplot(ax1)
        hold on
        plot(time, H)
        hold off
        
        subplot(ax2)
        hold on
        plot(time, V)
        hold off
        
        subplot(ax3)
        hold on
        plot(H_end, V_end, 'o');
        hold off
    end
end
end
