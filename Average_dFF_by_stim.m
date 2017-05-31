function Average_dFF_by_stim(~,~)
global sobj
global imgobj
global recobj
global ParamsSave
%%%%%%%%%%%

nframe = size(imgobj.dFF,1);
frame_stimON =  zeros(1, size(ParamsSave,2) - recobj.prestim);
stim = frame_stimON;

%oversampling by 200 times;
mag_os = 200;

sampt_os = imgobj.FVsampt/mag_os;

%%%%%%%%%%

for i = (recobj.prestim + 1):size(ParamsSave,2)
    %nearest frame for stim onset
    frame_stimON(i-recobj.prestim) = floor((ParamsSave{1,i}.stim1.corON)/imgobj.FVsampt);
    
    %stim specific index
    switch sobj.pattern
        case {'Uni'}
            stim(i-recobj.prestim) = ParamsSave{1,i}.stim1.center_position;
        case {'Size_rand'}
            stim(i-recobj.prestim) = ParamsSave{1,i}.stim1.size_deg;
        case {'MoveBar'}
            stim(i-recobj.prestim) = ParamsSave{1,i}.stim1.direction;
        case {'Images'}
            stim(i-recobj.prestim) = ParamsSave{1,i}.stim1.Image_index;
    end
end

stim_list = unique(stim);
nstim = length(stim_list);

%get prestim trace for 1 sec
pret = 1;
prep = ceil(pret/imgobj.FVsampt);

%post time for 10 sec
postt = 10;
postp = ceil(postt/imgobj.FVsampt);

datap = prep+postp+1;


%% get_stim_average
%prep mat for averaged response for each stim
imgobj.dFF_s_ave = zeros(prep+postp+1, nstim, length(imgobj.selectROI));

%time
%time_frame = linspace(0,(nframe-1)*imgobj.FVsampt, nframe);

%number of over sampled frames
nframe_os = nframe * mag_os;

%prep mat for oversampled average, 4000 time poitns are picked.
n_cut = 4;
dFF_s_os_ave = zeros((datap - n_cut)*mag_os, nstim, length(imgobj.selectROI));

%time for OverSampling2
%time_frame_os = 0: sampt_os : (nframe_os)*sampt_os;2
time_frame_os = linspace(0, (nframe-1)*imgobj.FVsampt, nframe_os);

%% get averaged reseponses over each ROI and each stimulus
for i2 = 1:length(imgobj.selectROI)
    %%%%%%%%%%%%%%%%
    % i2 = each ROI
    %%%%%%%%%%%%%%%%
    dFF_os = interp1(0:nframe-1, imgobj.dFF(:,imgobj.selectROI(i2)), 0:1/mag_os: nframe-1/mag_os, 'spline');
    
    
    for i = 1:nstim
        %%%%%%%%%%
        % i = each stimulus
        %%%%%%%%%%
        
        %index of same stim property (= number of trials)
        i_ext_stim = find(stim== stim_list(i));
        %prep mat for extracted response
        dFF_ext = zeros(prep+postp+1,length(i_ext_stim));
        
        %rate of over sampling and prep mat
        dFF_ext_os = zeros((prep+postp+1)*mag_os, length(i_ext_stim));
        
        %1sec before stimON is used. OK?
        dFF_ext_os_cut = dFF_ext_os(mag_os*n_cut : end-1, :);
        l_os_cut = size(dFF_ext_os_cut,1);
        
        for i3 = 1:length(i_ext_stim)
            %%%%%%%%%%
            % i3 = each trials
            %%%%%%%%%%
            %pick up frames from prep to postp
            ext_fs = frame_stimON(i_ext_stim(i3))-prep:frame_stimON(i_ext_stim(i3))+postp;
            dFF_ext(:,i3) = imgobj.dFF(ext_fs, imgobj.selectROI(i2));
            
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
            
            [~, ind] = min(abs(ParamsSave{1,i_ext_stim(i3)+recobj.prestim}.stim1.corON - time_frame_os));
            
            %align OS Traces 4 Frames before stimON in the OS time frame.
            if ind == mag_os*n_cut
                ind = ind + 1;
            end
            
            % align oversampled traces at nearest time point
            i_start = ind - mag_os*n_cut;
            i_end = l_os_cut + i_start-1;
            %dFF_ext_os_cut(:,i3) = dFF_ext_os(ind - mag_os*4 : l_os_cut + (ind - mag_os*4) -1, i3);
            dFF_ext_os_cut(:,i3) =  dFF_os(i_start:i_end);
        end
        
        %closed stimulus time point for over sampled trace
        dFF_s_os_ave(:,i,i2) = mean(dFF_ext_os_cut,2);
        
        imgobj.dFF_s_ave(:,i, i2) = mean(dFF_ext,2);
        
        
        
        % check trial variance and mean
        %{
        figure;
        plot(1:l_os_cut, dFF_ext_os_cut, '-k');
        hold on;
        plot(1:l_os_cut,  mean(dFF_ext_os_cut,2), '-r');
        line([mag_os*n_cut, mag_os*n_cut],[-0.2,1])
        hold off;
        %}
        
        %{
        figure;
        plot(1:21, dFF_ext, '-ok');
        hold on;
        plot(1:21, mean(dFF_ext,2), '-or');
        line([prep+1,prep+1],[-0.2,1])
        hold off;
        %}
        
    end
end

%%
%stim on, frame
sof = prep + 1;
%stim on, time
sot = imgobj.FVsampt*sof;

%OverSampled stim On, time
sot_os = imgobj.FVsampt*4;

%% plot (imagesc)
figure,
img_x = 1:nstim;
img_y = 0:imgobj.FVsampt:(size(imgobj.dFF_s_ave, 1)-1)*imgobj.FVsampt;
for i = 1:size(imgobj.dFF_s_ave,3)
    subplot(1, size(imgobj.dFF_s_ave, 3), i)
    imagesc(img_y, img_x, imgobj.dFF_s_ave(:,:,i)')
    caxis([0.025 1.5])
    
    title(['ROI=#', num2str(imgobj.selectROI(i))])
    set(gca,'YTick',1:nstim);% something like this
    ylabel('Stim')
    xlabel('Time(s)')
    
    line([sot, sot],[0,nstim+1], 'Color', 'g', 'LineWidth', 2);
end

%% imagesc (over sampling)
figure
img_x = 1:nstim;

img_y = 0 : sampt_os : (size(dFF_s_os_ave,1)-1)*sampt_os;
for i = 1:size(dFF_s_os_ave,3)
    subplot(1, size(dFF_s_os_ave, 3), i)
    imagesc(img_y, img_x, dFF_s_os_ave(:,:,i)')
    caxis([0.025 1.5])
    
    title(['ROI=#', num2str(imgobj.selectROI(i))]);
    
    set(gca,'YTick', 1:nstim);% something like this
    ylabel('Stim')
    xlabel('Time(s), (OverSampled)')
    
    line([sot_os, sot_os],[0,nstim+1], 'Color', 'g', 'LineWidth', 2);
end
%% plot trace
figure
t_FV = 0:imgobj.FVsampt:((size(imgobj.dFF_s_ave, 1))-1)*imgobj.FVsampt;
 %t_FV = linspace(0, (prep+postp+1)*imgobj.FVsampt, size(imgobj.dFF_s_ave,1));
for i = 1:size(imgobj.dFF_s_ave,2)
    
    for i2 = 1:size(imgobj.dFF_s_ave, 3)
        subplot(size(imgobj.dFF_s_ave,2), size(imgobj.dFF_s_ave, 3), i2 + (i-1)*size(imgobj.dFF_s_ave, 3))
        plot(t_FV, imgobj.dFF_s_ave(:,i,i2), 'color', 'r', 'linewidth', 2);
        xlim([0 , (prep+postp+1)*imgobj.FVsampt])
        ylim([-0.2 1.5])
        if i==1
            title(['ROI=#', num2str(imgobj.selectROI(i2))])
        end
        line([sot, sot],[-1,3], 'Color', 'g', 'LineWidth', 2);
    end
    
end



%%
%%
%{
for i =  1:nstim
    i_stim = find(stim==stim_list(i));
    ave_dFF = zeros(prep+postp+1, length(i_stim), length(imgobj.selectROI));
    
    switch sobj.pattern
        case {'Uni'}
            i_div = sobj.divnum;
            i_col = rem(i, i_div);
               
            if i_col == 0
                i_col = i_div;
            end
             
            ax{i} = subplot(i_div, i_div, i);
            
        otherwise
            ax{i} = subplot(nstim, 1, i);
    end
    
    %get_average by stimulus
    for i3 = length(imgobj.selectROI)
        for i2 = 1:length(i_stim)
            ave_dFF(:,i2, imgobj.selectROI==i3) = imgobj.dFF(range(i_stim(i2))-prep:range(i_stim(i2))+postp, :, imgobj.selectROI==i3);
            hold on
            plot(ave_dFF(:,i2),'k');
        end
    end
    mean_dFF = mean(ave_dFF,2);
    ymax(i) = max(max(max(ave_dFF)));
    plot(mean_dFF, 'color', 'r', 'linewidth', 2);
    hold off
end





%%
%
        %%%%%%%%%%%%%%
    case 'Size_rand'
        %by stim size
        range =  zeros(1, size(ParamsSave,2) - recobj.prestim);
        trial_w_stim = (recobj.prestim + 1):size(ParamsSave,2);
        stim = range;
        
        for i = 1:length(trial_w_stim);
            range(i) = floor((ParamsSave{1,trial_w_stim(i)}.stim1.corON)/imgobj.FVsampt);
            stim(i) = ParamsSave{1,trial_w_stim(i)}.stim1.size_deg;
        end
        stim_list = unique(stim);
        stim_list_num = length(stim_list);
        
        pret = 1;
        prep = ceil(pret/imgobj.FVsampt);
        postt = 8;
        postp = ceil(postt/imgobj.FVsampt);
        
        figure('Position', [100, 20, 250, 800], 'Menubar', 'none', 'Resize', 'off');
        
        ax=cell(1, stim_list_num);
        ymax = zeros(1, stim_list_num);
        
        for i =  1:stim_list_num
            i_stim = find(stim==stim_list(i));
            ave_dFF = zeros(prep+postp+1, length(imgobj.selectROI), length(i_stim));
            
            ax{i} = subplot(stim_list_num, 1, i);
            for i2 = 1:length(i_stim)
                ave_dFF(:,:,i2)= imgobj.dFF(range(i_stim(i2))-prep:range(i_stim(i2))+postp, imgobj.selectROI);
                hold on
                plot(ave_dFF(:,:,i2),'k');
            end
            mean_dFF = mean(ave_dFF,3);
            ymax(i) = max(max(max(ave_dFF)));
            plot(mean_dFF, 'color', 'r', 'linewidth', 2);
            title(['ROI# =  ', num2str(imgobj.selectROI)])
            hold off
        end
        
        for i = 1:stim_list_num
            if get(h, 'value') == 1
                ylim(ax{i}, [-0.1, 1]);
            else
                ylim(ax{i}, [-0.2, max(ymax)*1.2]);
            end
        end
        
            
            
    case '1P_Conc'
        %by stim1 positino
    case '2P_Conc'

        
        
    case 'Looming'
        % constant
    case {'Sin', 'Rect', 'Gabor'}
        %by moving angle
    case 'Images'
        
        %by stim size
        range =  zeros(1, size(ParamsSave,2) - recobj.prestim);
        trial_w_stim = (recobj.prestim + 1):size(ParamsSave,2);
        stim = range;
        
        for i = 1:length(trial_w_stim);
            range(i) = floor((ParamsSave{1,trial_w_stim(i)}.stim1.corON)/imgobj.FVsampt);
            stim(i) = ParamsSave{1,trial_w_stim(i)}.stim1.Image_index;
        end
        stim_list = unique(stim);
        stim_list_num = length(stim_list);
        
        pret = 1;
        prep = ceil(pret/imgobj.FVsampt);
        postt = 8;
        postp = ceil(postt/imgobj.FVsampt);
        
        figure('Position', [100, 20, 250, 800], 'Menubar', 'none', 'Resize', 'off');
        
        ax=cell(1, stim_list_num);
        ymax = zeros(1, stim_list_num);
        
        for i =  1:stim_list_num
            i_stim = find(stim==stim_list(i));
            ave_dFF = zeros(prep+postp+1, length(imgobj.selectROI), length(i_stim));
            
            ax{i} = subplot(stim_list_num, 1, i);
            for i2 = 1:length(i_stim)
                ave_dFF(:,:,i2)= imgobj.dFF(range(i_stim(i2))-prep:range(i_stim(i2))+postp, imgobj.selectROI);
                hold on
                plot(ave_dFF(:,:,i2),'k');
            end
            mean_dFF = mean(ave_dFF,3);
            ymax(i) = max(max(max(ave_dFF)));
            plot(mean_dFF, 'color', 'r', 'linewidth', 2);
            title(['ROI# =  ', num2str(imgobj.selectROI)])
            hold off
        end
        
        for i = 1:stim_list_num
            if get(h, 'value') == 1
                ylim(ax{i}, [-0.1, 1]);
            else
                ylim(ax{i}, [-0.2, max(ymax)*1.2]);
            end
        end
        
    case 'Mosaic'
        %by ...?
        
        
%}


end