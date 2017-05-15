function Average_dFF_by_stim(~,~)
global sobj
global imgobj
global recobj
global ParamsSave
%plot(imgobj.FVt, imgobj.dFF(:, imgobj.selectROI(i)), 'k');

%stim pattern
%switch sobj.pattern

%by stim center position
%%
range =  zeros(1, size(ParamsSave,2) - recobj.prestim);
stim = range;

for i = (recobj.prestim + 1):size(ParamsSave,2)
    range(i-recobj.prestim) = floor((ParamsSave{1,i}.stim1.corON)/imgobj.FVsampt);
    switch sobj.pattern
        case {'Uni'}
            stim(i-recobj.prestim) = ParamsSave{1,i}.stim1.center_position;
        case {'Size_rand'}
            stim(i-recobj.prestim) = ParamsSave{1,i}.stim1.size_deg;
    end
end

stim_list = unique(stim);
nstim = length(stim_list);

pret = 1;
prep = ceil(pret/imgobj.FVsampt);
postt = 10;
postp = ceil(postt/imgobj.FVsampt);

%% get_stim_average
% %figure('Position', [100, 20, 800, 800], 'Menubar', 'none', 'Resize', 'off');
% ax=cell(1, nstim);
% ymax = zeros(1, nstim);

imgobj.dFF_s_ave = zeros(prep+postp+1, nstim, length(imgobj.selectROI));

for i2 = 1:length(imgobj.selectROI)
    for i = 1:nstim
        ext_fs = range(stim==stim_list(i))-prep:range(stim==stim_list(i))+postp;
        imgobj.dFF_s_ave(:,i, i2) = mean(imgobj.dFF(ext_fs, imgobj.selectROI(i2)),2);
    end
end


%% plot (imagesc)
figure,
for i = 1:size(imgobj.dFF_s_ave,3)
    subplot(1, size(imgobj.dFF_s_ave, 3), i)
    imagesc(imgobj.dFF_s_ave(:,:,i))
    caxis([0.025 1.5])
    title(['ROI=#', num2str(imgobj.selectROI(i))])
end

%% plot trace
figure,
for i = 1:size(imgobj.dFF_s_ave,2)
    for i2 = 1:size(imgobj.dFF_s_ave, 3)

        subplot(size(imgobj.dFF_s_ave,2), size(imgobj.dFF_s_ave, 3), i2 + (i-1)*size(imgobj.dFF_s_ave, 3))
        plot(imgobj.dFF_s_ave(:,i,i2), 'color', 'r', 'linewidth', 2);
        xlim([1, prep+postp+1])
        ylim([-0.2 1.5])
        if i==1
            title(['ROI=#', num2str(imgobj.selectROI(i2))])
        end
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