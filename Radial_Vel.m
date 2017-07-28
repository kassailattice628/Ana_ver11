function [data1_offset, data2_offset, velocity, pks, locs] = Radial_Vel(r, data, recTime)
global n
global hfig
global ParamsSave

%% % prep data % 
if isfield(hfig, 'offsetV')
    off1 = str2double(get(hfig.offsetV, 'string'));
    off2 = str2double(get(hfig.offsetH, 'string'));
else
    off1 = 0;
    off2 = 0;
end

% offset data
data1_offset = shift_data(data(:, 1, n) - data(1, 1, n), off1);
data2_offset = shift_data(data(:, 2, n) - data(1, 2, n), off2);

d_filt_eye = designfilt('lowpassfir', 'FilterOrder', 12,...
    'CutoffFrequency', 50, 'SampleRate', r.sampf);
d_filt_vel = designfilt('bandpassfir', 'FilterOrder', 5,...
    'CutoffFrequency1',5, 'CutoffFrequency2', 200,...
    'SampleRate', r.sampf);

data1_filt = filter(d_filt_eye ,data1_offset);
data2_filt = filter(d_filt_eye ,data2_offset);

% calc differential
data1_diff = diff(data1_filt);
data2_diff = diff(data2_filt);
[~, r_amp] = cart2pol(data2_diff, -data1_diff);
velocity = r_amp * r.sampf;
velocity = filter(d_filt_vel, velocity);
velocity = velocity - mean(velocity(1:100));

if isfield(ParamsSave{1,n}, 'sac_t')
    sac_t = ParamsSave{1,n}.sac_t;
    locs = zeros(1, length(sac_t));
    pks = locs;
    for i =  1:length(sac_t)
        locs(i) = find(sac_t(i) > recTime, 1, 'last') + 1;
        pks(i) = velocity(locs(i));
    end
else
    [pks,locs] = findpeaks(velocity, 'MinPeakHeight', 45,...
        'MinPeakDistance', 800);
    pks = pks(pks < 250);
    locs = locs(pks < 250);
    
    if isempty(pks)
        ParamsSave{1,n}.sac_t = [];
    end
end

%
data1_offset(end) = NaN;

%plot_spectrum(velocity)
%plot_show;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function plot_show
        figure
        subplot(3,1,1)
        plot(data1_offset(1:end-1))
        hold on
        plot(data1_filt(1:end-1))
        title('Horizontal')
        
        subplot(3,1,2)
        plot(data2_offset(1:end-1))
        hold on
        plot(data2_filt(1:end-1))
        title('Vertical')
        
        subplot(3,1,3)
        plot(velocity)
        hold on
        plot(locs, pks, '*');
        hold off
        title('Velocity')
    end
%
    function plot_spectrum(signal)
        Y = fft(signal, length(signal));
        L = length(Y);
        P2 = abs(Y/L);
        P1 = P2(1:L/2 + 1);
        P1(2:end-1) = 2*P1(2:end-1);
        
        f = r.sampf * (0:(L/2))/L;
        figure,
        plot(f, P1)
    end
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data_out = shift_data(data_in, offset)
if offset == 0
    data_out = data_in - data_in(1);
else
    data_out = data_in - offset;
end
end

