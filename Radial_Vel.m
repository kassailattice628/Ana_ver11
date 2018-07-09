function [data1_offset, data2_offset, velocity, pks, locs] = Radial_Vel(r, data, recTime)
global n
global hfig
% update saccade time info 
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

%d_filt_eye = designfilt('lowpassfir', 'FilterOrder', 10,...
%    'CutoffFrequency', 20, 'SampleRate', r.sampf);

d_filt_vel = designfilt('bandpassfir', 'FilterOrder', 10,...
    'CutoffFrequency1',100, 'CutoffFrequency2', 200,...
    'SampleRate', r.sampf);

d_filt_eye = designfilt('lowpassiir', ...        % Response type
       'PassbandFrequency',20, ...     % Frequency constraints
       'StopbandFrequency',200, ...
       'PassbandRipple',4, ...          % Magnitude constraints
       'StopbandAttenuation',55, ...
       'DesignMethod','butter', ...      % Design method
       'MatchExactly','stopband', ...   % Design method options
       'SampleRate',r.sampf) ;              % Sample rate   
   
data1_filt = filter(d_filt_eye ,data1_offset);
data2_filt = filter(d_filt_eye ,data2_offset);

% calc differential
data1_diff = diff(data1_filt);
data2_diff = diff(data2_filt);
[~, r_amp] = cart2pol(data2_diff, -data1_diff);
velocity_pre = r_amp * r.sampf;
%low-pass filt
velocity = filter(d_filt_vel, velocity_pre);
%offset
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
    th = str2double(get(hfig.vel_th, 'String'));
    %disp(max(velocity))
    [pks,locs] = findpeaks(velocity, 'MinPeakHeight', th,...
        'MinPeakDistance', 200);%200
    locs =  locs - 10;
    
    %pks_threshold =  250;%default 250
    %pks = pks(pks < pks_threshold);
    %locs = locs(pks < pks_threshold);
    
    if isempty(pks)
        ParamsSave{1,n}.sac_t = [];
    else
        ParamsSave{1,n}.sac_t = recTime(locs);
    end
    
end
%
data1_offset(end) = NaN;


%{
%test_filter(data1_offset, data2_offset)
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
        plot(velocity_pre - mean(velocity_pre(1:100)))
        hold on
        plot(velocity)
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

