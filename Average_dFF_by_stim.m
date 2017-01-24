function Average_dFF_by_stim(~,~)
global sobj
global imgobj
global recobj
global ParamsSave
%plot(imgobj.FVt, imgobj.dFF(:, imgobj.selectROI(i)), 'k');

%stim pattern
switch sobj.pattern
    case {'Uni', 'FineMap'}
        %by stim center position
        range =  zeros(1, size(ParamsSave,2) - recobj.prestim);
        stim = range;
        for i = (recobj.prestim + 1):size(ParamsSave,2)
            range(i) = floor((ParamsSave{1,i}.stim1.corON)/imgobj.FVsampt);
            stim(i) = ParamsSave{1,i}.stim1.center_position;
        end
        stim_list = unique(stim);
        stim_list_num = length(stim_list);
        
        pret = 1;
        prep = ceil(pret/imgobj.FVsampt);
        postt = 5;
        postp = ceil(postt/imgobj.FVsampt);
        
            
        
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
        
        figure;
        for i =  1:stim_list_num
            i_stim = find(stim==stim_list(i));
            ave_dFF = zeros(prep+postp+1, length(imgobj.selectROI), length(i_stim));
            subplot(stim_list_num, 1, i)
            for i2 = 1:length(i_stim)
                ave_dFF(:,:,i2)= imgobj.dFF(range(i_stim(i2))-prep:range(i_stim(i2))+postp, imgobj.selectROI);
                hold on
                plot(ave_dFF(:,:,i2),'k');
            end
            mean_dFF = mean(ave_dFF,3);
            plot(mean_dFF, 'r');
            hold off
        end
            
            
    case '1P_Conc'
        %by stim1 positino
    case '2P_Conc'
        %by stim2 position
    case 'Looming'
        % constant
    case {'Sin', 'Rect', 'Gabor'}
        %by moving angle
    case 'Image'
        %by image number
    case 'Mosaic'
        %by ...?
        
figure;
end