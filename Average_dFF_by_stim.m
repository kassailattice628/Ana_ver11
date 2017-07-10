function Average_dFF_by_stim(~,~)
%%%%%%%%%%%
% Get averaged traces for each stimulus.
% frame rate are over sampled *** times higher.
%%%%%%%%%%%
global sobj
global imgobj
global recobj
global ParamsSave
%%%%%%%%%%%

nframe = size(imgobj.dFF,1);
%time_frame = linspace(0, (nframe-1)*imgobj.FVsampt, nframe);

% get frame for nearby stimulus onset.
frame_stimON =  zeros(1, size(ParamsSave,2) - recobj.prestim);
frame_stimON_os = frame_stimON;
stim = frame_stimON;

%oversampling by 200 times,
%'os' means 'over sampled' params.
mag_os = 200;
sampt_os = imgobj.FVsampt/mag_os;


%%%%%%%%%%
for i = (recobj.prestim + 1):size(ParamsSave,2)
    %nearest frame for stim onset
    frame_stimON(i-recobj.prestim) = floor((ParamsSave{1,i}.stim1.corON)/imgobj.FVsampt);
    frame_stimON_os(i-recobj.prestim) = floor((ParamsSave{1,i}.stim1.corON)/sampt_os);
    
    %stim specific index
    switch sobj.pattern
        case {'Uni', 'Looming'}
            stim(i-recobj.prestim) = ParamsSave{1,i}.stim1.center_position;
        case {'Size_rand'}
            stim(i-recobj.prestim) = ParamsSave{1,i}.stim1.size_deg;
        case {'MoveBar'}
            stim(i-recobj.prestim) = ParamsSave{1,i}.stim1.MovebarDir_angle_deg;
        case {'Images'}
            stim(i-recobj.prestim) = ParamsSave{1,i}.stim1.Image_index;
        case {'Rect'}
            stim(i-recobj.prestim) = ParamsSave{1,i}.stim1.gratingAngle_deg;
    end
end

stim_list = unique(stim);
nstim = length(stim_list);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Set time point for stimulus average

%pre stimulus time for 1 sec
pret = 1;
prep = ceil(pret/imgobj.FVsampt);

%post stimulus time for 10 sec
postt = recobj.rect/1000;
postp = ceil(postt/imgobj.FVsampt);

datap = prep+postp+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Set over sampled time point
%nframe_os = nframe * mag_os;
%time for OverSampling
%time_frame_os = linspace(0, (nframe-1)*imgobj.FVsampt, nframe_os);


%% get_stim_average
%prep mat for averaged response for each stim
imgobj.dFF_s_ave = zeros(datap, nstim, length(imgobj.selectROI));

%prep mat for oversampled average
datap_os = (prep+postp) * mag_os + 1;
dFF_s_ave_os = zeros(datap_os, nstim, length(imgobj.selectROI));
%disp(datap_os)


%% get averaged reseponses over each ROI and each stimulus
for i2 = 1:length(imgobj.selectROI)
    %%%%%%%%%%%%%%%%
    % i2 = each ROI
    %%%%%%%%%%%%%%%%
    dFF_os = interp1(0:nframe-1, imgobj.dFF(:,imgobj.selectROI(i2)),...
        0:1/mag_os: nframe-1/mag_os, 'spline'); %'spline', 'nearest'
    
    for i = 1:nstim
        %%%%%%%%%%
        % i = each stimulus
        %%%%%%%%%%
        %index of same stim property (= number of trials)
        i_ext_stim = find(stim == stim_list(i));
        %prep mat for extracted response
        dFF_ext = zeros(datap, length(i_ext_stim));
        %prep mat for over sampled responses
        dFF_ext_os = zeros(datap_os, length(i_ext_stim));
        
        for i3 = 1:length(i_ext_stim)
            %%%%%%%%%%
            % i3 = each trials
            %%%%%%%%%%
            %ext_fs : extracted frames
            ext_fs = frame_stimON(i_ext_stim(i3)) - prep : frame_stimON(i_ext_stim(i3))+postp;
            
            ext_fs_os = frame_stimON_os(i_ext_stim(i3)) - prep*mag_os : ...
                frame_stimON_os(i_ext_stim(i3)) + postp*mag_os;
            
            if max(ext_fs) < size(imgobj.dFF,1)
                dFF_ext(:,i3) = imgobj.dFF(ext_fs, imgobj.selectROI(i2));
                
                dFF_ext_os(:,i3) = dFF_os(ext_fs_os);
                %{
            %over sampled trace
            dFF_ext_os(:,i3) = interp1(1:size(dFF_ext,1), dFF_ext(:,i3),...
                1:1/mag_os:(size(dFF_ext,1)+1)-1/mag_os, 'spline');
            %search nearst over sampled frame of stim ON from the original
            %time frame.
            [~, start_f_os] = min(abs(time_frame(frame_stimON(i_ext_stim(i3)))-time_frame_os));
            
            %search a nearest time point for stim ON from the oversampled
            %tf, (extra 1 frame is selected (prep+1))
            ext_fs_os = (start_f_os - (prep+1)*mag_os) : (start_f_os + postp*mag_os -1);
            
            %search a nearst point of stimON, from the extracted OverSampled time frame
            [~, ind] = min(abs(ParamsSave{1,i_ext_stim(i3)+recobj.prestim}.stim1.corON - time_frame_os(ext_fs_os)));
            
                %}
            else
                dFF_ext = dFF_ext(:,1:i3-1);
                dFF_ext_os = dFF_ext_os(:, 1:i3-1);
                continue;
            end
        end
        
        %Get mean traces for each stimulus
        imgobj.dFF_s_ave(:,i, i2) = mean(dFF_ext,2);
        dFF_s_ave_os(:,i,i2) = mean(dFF_ext_os,2);
        
        % check trial variance and mean
        %{
        figure;
        t_os = ((0:datap_os-1)*sampt_os)';
        plot(t_os, dFF_ext_os, '-k');
        hold on;
        plot(t_os, mean(dFF_ext_os,2), '-r');
        line([t_os(prep*mag_os+1),t_os(prep*mag_os+1)], [-0.2, 1])
        hold off;
        %}
        
        %{
        figure;
        t = ((0:datap-1)*imgobj.FVsampt)';
        plot(t, dFF_ext, '-ok');
        hold on;
        plot(t, mean(dFF_ext,2), '-or');
        line([t(prep+1),t(prep+1)],[-0.2,1])
        hold off;
        %}
        
    end
end
%%

%% plot (imagesc)
figure,
img_x = 1:nstim;
%img_y = 0:imgobj.FVsampt:(size(imgobj.dFF_s_ave, 1)-1)*imgobj.FVsampt;
t = ((0:datap-1)*imgobj.FVsampt)';

for i = 1:size(imgobj.dFF_s_ave,3)
    subplot(1, size(imgobj.dFF_s_ave, 3), i)
    %imagesc(img_y, img_x, imgobj.dFF_s_ave(:,:,i)')
    imagesc(t, img_x, imgobj.dFF_s_ave(:,:,i)')
    caxis([0.02, 1.0])
    caxis([-1.0, 1.0])
    
    title(['ROI=#', num2str(imgobj.selectROI(i))])
    set(gca,'YTick',1:nstim);% something like this
    ylabel('Stim')
    xlabel('Time(s)')
    
    line([t(prep+1), t(prep+1)],[0,nstim+1], 'Color', 'g', 'LineWidth', 2);
end

%% imagesc (over sampling)
figure
img_x = 1:nstim;
%img_y = 0 : sampt_os : (size(dFF_s_ave_os,1)-1)*sampt_os;
t_os = ((0:datap_os-1)*sampt_os)';

for i = 1:size(dFF_s_ave_os,3)
    subplot(1, size(dFF_s_ave_os, 3), i)
    %imagesc(img_y, img_x, dFF_s_ave_os(:,:,i)')
    imagesc(t_os, img_x, dFF_s_ave_os(:,:,i)')
    caxis([0.02, 1.0])
    
    title(['ROI=#', num2str(imgobj.selectROI(i))]);
    
    set(gca,'YTick', 1:nstim);% something like this
    ylabel('Stim')
    xlabel('Time(s), (Over Sampled)')
    
    line([t_os(prep*mag_os+1), t_os(prep*mag_os+1)],[0,nstim+1], 'Color', 'g', 'LineWidth', 2);
end
%% plot trace
figure

for i = 1:size(imgobj.dFF_s_ave,2)
    
    for i2 = 1:size(imgobj.dFF_s_ave, 3)
        subplot(size(imgobj.dFF_s_ave,2), size(imgobj.dFF_s_ave, 3), i2 + (i-1)*size(imgobj.dFF_s_ave, 3))
        plot(t, imgobj.dFF_s_ave(:,i,i2), '-r', 'linewidth', 2);
        xlim([0 , datap*imgobj.FVsampt])
        ylim([-0.2 1.5])
        if i==1
            title(['ROI=#', num2str(imgobj.selectROI(i2))])
        end
        line([t(prep+1), t(prep+1)],[-1,3], 'Color', 'g', 'LineWidth', 2);
    end
    
end

%% plot trace (Oversampled)
figure

for i = 1:size(dFF_s_ave_os,2)
    
    for i2 = 1:size(dFF_s_ave_os, 3)
        subplot(size(dFF_s_ave_os,2), size(dFF_s_ave_os, 3), i2 + (i-1)*size(dFF_s_ave_os, 3))
        plot(t_os, dFF_s_ave_os(:,i,i2), '-r', 'linewidth', 2);
        xlim([0 , datap_os*sampt_os])
        ylim([-0.2 1.5])
        if i==1
            title(['ROI=#', num2str(imgobj.selectROI(i2))])
        end
        line([t_os(prep*mag_os+1), t_os(prep*mag_os+1)],[-1,3], 'Color', 'g', 'LineWidth', 2);
    end
    
end

end