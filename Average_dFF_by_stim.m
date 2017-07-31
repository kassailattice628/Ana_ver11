function Average_dFF_by_stim(~,~, cmin, cmax)
%%%%%%%%%%%
% Get averaged traces for each stimulus.
% frame rate are over sampled *** times higher.
%%%%%%%%%%%
global imgobj
%%%%%%%%%%%

c_min = str2double(get(cmin, 'string'));
c_max = str2double(get(cmax, 'string'));


mag_os = 200; %oversampling x200
sampt_os = imgobj.FVsampt/mag_os;

%% Get_dFF, Averaged by Stim Types
if ~isfield(imgobj, 'dFF_s_ave');
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
    
    line([t(prep+1), t(prep+1)],[0,nstim+1], 'Color', 'g', 'LineWidth', 2);
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
    
    line([t_os(prep*mag_os+1), t_os(prep*mag_os+1)],[0,nstim+1], 'Color', 'g', 'LineWidth', 2);
end

%% plot trace
figure
for i = 1:length(imgobj.selectROI)
    
    for i2 = 1:nstim
        subplot(nstim, length(imgobj.selectROI), i + (i2-1)*length(imgobj.selectROI))
        
        plot(t, imgobj.dFF_s_ave(:,i2, imgobj.selectROI(i)), '-r', 'linewidth', 2);
        xlim([0 , datap*imgobj.FVsampt])
        ylim([-0.2 1.5])
        if i2 ==  1
            title(['ROI=#', num2str(imgobj.selectROI(i))])
        end
        line([t(prep+1), t(prep+1)],[-1,3], 'Color', 'g', 'LineWidth', 2);
    end
    
end

%% plot trace (Oversampled)
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
        line([t_os(prep*mag_os+1), t_os(prep*mag_os+1)],[-1,3], 'Color', 'g', 'LineWidth', 2);
    end
    
end
%}
end