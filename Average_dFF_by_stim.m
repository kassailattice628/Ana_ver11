function Average_dFF_by_stim(~,~, cmin, cmax)
%%%%%%%%%%%
% Get averaged traces for each stimulus.
% frame rate are over sampled *** times higher.
%%%%%%%%%%%
global imgobj
global sobj
%%%%%%%%%%%

c_min = str2double(get(cmin, 'string'));
c_max = str2double(get(cmax, 'string'));


mag_os = 200; %oversampling x200
sampt_os = imgobj.FVsampt/mag_os;

%% Get_dFF, Averaged by Stim Types
if ~isfield(imgobj, 'dFF_s_ave')
    [stim_list, datap, datap_os, prep] = Get_dFF_Ave(mag_os);
    nstim = length(stim_list);
    
else
    nstim = size(imgobj.dFF_s_ave, 2);
    datap = size(imgobj.dFF_s_ave, 1);
    datap_os = size(imgobj.dFF_s_ave_os, 1);
    pret = 1;
    prep = ceil(pret/imgobj.FVsampt);
end
%% %%%%%%%%%%%%%%%%% Show Plot %%%%%%%%%%%%%%%%%%%% %%

%duration
switch sobj.pattern
    case {'MoveBar', 'Looming'}
        duration = max(sobj.moveDuration);
        
        if length(sobj.moveDuration) > 1
            A = 1:length(sobj.moveDuration);
            B = flip(A);
            C = repmat([A, B(2:end-1)],1,2);
        end
        
    otherwise
        sobj.moveDuration = 0;
        duration = sobj.duration;
end

%% plot (imagesc)
figure,
img_x = 1:nstim;
t = ((0:datap-1)*imgobj.FVsampt)';

for i = 1:length(imgobj.selectROI)
    
    subplot(1, length(imgobj.selectROI), i)
    imagesc(t, img_x, imgobj.dFF_s_ave(:,:,imgobj.selectROI(i))')
    %caxis([0.02, 1.0])
    caxis([c_min, c_max])
    
    title(['ROI=#', num2str(imgobj.selectROI(i))])
    set(gca,'YTick',1:nstim);% something like this
    ylabel('Stim')
    xlabel('Time(s)')
    
    %stim onset
    line([t(prep+1), t(prep+1)],[0, nstim+1], 'Color', 'g', 'LineWidth', 1);
    
    %stim offset
    if length(sobj.moveDuration) > 1
        for i2 = 1:nstim
            x_off = t(prep+1) + sobj.moveDuration(C(i2));
            y = [i2-0.5, i2+0.5];
            line([x_off, x_off], y, 'Color', 'r', 'LineWidth', 1);
        end
    else
        line([t(prep+1)+duration, t(prep+1)+duration],[0, nstim+1], 'Color', 'r', 'LineWidth', 1);
    end
end


%% plot (imagesc over sampling)
figure
img_x = 1:nstim;
t_os = ((0:datap_os-1)*sampt_os)';

for i = 1:length(imgobj.selectROI)
    subplot(1, length(imgobj.selectROI), i)
    %imagesc(img_y, img_x, dFF_s_ave_os(:,:,i)')
    imagesc(t_os, img_x, imgobj.dFF_s_ave_os(:,:,imgobj.selectROI(i))')
    caxis([c_min, c_max])
    title(['ROI=#', num2str(imgobj.selectROI(i))]);
    
    set(gca,'YTick', 1:nstim);% something like this
    ylabel('Stim')
    xlabel('Time(s), (Over Sampled)')
    
    line([t_os(prep*mag_os+1), t_os(prep*mag_os+1)],[0,nstim+1], 'Color', 'g', 'LineWidth', 1);
    
    %stim offset
    if length(sobj.moveDuration) > 1
        for i2 = 1:nstim
            x_off = t_os(prep*mag_os+1) + sobj.moveDuration(C(i2));
            y = [i2-0.5, i2+0.5];
            line([x_off, x_off], y, 'Color', 'r', 'LineWidth', 1);
        end
    else
        %line([x_off, x_off],[0, nstim+1], 'Color', 'r', 'LineWidth', 1);
        line([t_os(prep*mag_os+1)+duration, t_os(prep*mag_os+1)+duration],[0, nstim+1], 'Color', 'r', 'LineWidth', 1);
    end
    
    
end

%% plot trace

s_off_p = ceil(duration/imgobj.FVsampt);

figure
for i = 1:length(imgobj.selectROI)
    for i2 = 1:nstim
        subplot(nstim, length(imgobj.selectROI), i + (i2-1)*length(imgobj.selectROI))
        
        plot(t, imgobj.dFF_s_ave(:,i2, imgobj.selectROI(i)), '-r', 'linewidth', 2);
        xlim([0 , datap*imgobj.FVsampt])
        ylim([-0.2 1.5])
        if i2 == 1
            title(['ROI=#', num2str(imgobj.selectROI(i))])
        end
        %stim onset
        line([t(prep+1), t(prep+1)],[-1,3], 'Color', 'g', 'LineWidth', 2);
        
        if length(sobj.moveDuration) > 1
                x_off = t(prep+1) + sobj.moveDuration(C(i2));
                y = [-1, 3];
                line([x_off, x_off], y, 'Color', 'g', 'LineWidth', 2);
        else
            line([t(prep+1)+duration, t(prep+1)+duration],[-1,3], 'Color', 'g', 'LineWidth', 2);
        end
        
    end
end

%% overlay plot
%%%%
for i = 1:length(imgobj.selectROI)
    min_ = min(min(imgobj.dFF_s_ave(:, 1:nstim, imgobj.selectROI(i))));
    max_ = max(max(imgobj.dFF_s_ave(:, 1:nstim, imgobj.selectROI(i))));
    
    figure
    hold on
    %subplot(nstim+1, length(imgobj.selectROI), i + nstim*length(imgobj.selectROI))
    for i2 = 1:nstim
        plot(t, imgobj.dFF_s_ave(:, i2, imgobj.selectROI(i)), 'linewidth', 2);
        if i2 == 1
            title(['ROI=#', num2str(imgobj.selectROI(i))])
        end
    end
    legend('show')
    
    area([t(prep+1), t(prep+1+s_off_p)],[max_, max_], min_, 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
    alpha(0.1);
    hold off
    ylim([min_, max_])
    
end

%% plot trace (Oversampled)
%stim area
%s_off_p = ceil(sobj.duration/imgobj.FVsampt);

figure
for i = 1:length(imgobj.selectROI)
    
    for i2 = 1:nstim
        subplot(nstim, length(imgobj.selectROI), i + (i2-1)*length(imgobj.selectROI))
        plot(t_os, imgobj.dFF_s_ave_os(:,i2, imgobj.selectROI(i)), '-r', 'linewidth', 2);
        xlim([0 , datap_os*sampt_os])
        ylim([-0.2 1.5])
        if i2==1
            title(['ROI=#', num2str(imgobj.selectROI(i))])
        end
        
        % stim onset
        line([t_os(prep*mag_os+1), t_os(prep*mag_os+1)],[-1,3], 'Color', 'g', 'LineWidth', 2);
        
        % stim offset
        if length(sobj.moveDuration) > 1
            x_off = t_os(prep*mag_os+1) + sobj.moveDuration(C(i2));
            y = [-1, 3];
            line([x_off, x_off], y, 'Color', 'g', 'LineWidth', 2);
        else
            
            line([t_os(prep*mag_os+1)+duration, t_os(prep*mag_os+1)+duration],[-1,3], 'Color', 'g', 'LineWidth', 2);
        end
    end
    
    %{
    figure,
    %subplot(nstim+1, length(imgobj.selectROI), i + nstim*length(imgobj.selectROI))
    area([(prep*mag_os+1), (s_off_p*mag_os+1)],[1, 1], 'FaceColor', 'k', 'LineStyle', 'none', 'ShowBaseLine', 'off');
    alpha(0.1);
    hold on
    plot(imgobj.dFF_s_ave_os(:, 1:nstim, imgobj.selectROI(i)), 'linewidth', 2);
    title(['ROI=#', num2str(imgobj.selectROI(i))])
    legend('show')
    hold off
    
    min_ = min(min(imgobj.dFF_s_ave_os(:, 1:nstim, imgobj.selectROI(i))));
    max_ = max(max(imgobj.dFF_s_ave_os(:, 1:nstim, imgobj.selectROI(i))));
    ylim([min_, max_])
    %}
end
%}
end