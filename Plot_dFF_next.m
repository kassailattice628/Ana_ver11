function Plot_dFF_next(~, ~, set_n)
%%
global imgobj
global hfig
%%

imgobj.nROI = update_n(set_n);

%update_info_text(sobj);

% Single
update_plot(hfig.two_photon_plot1, imgobj.FVt, imgobj.dFF, imgobj.nROI);
% plot
refreshdata(hfig.two_photon, 'caller')

%% %%%%%%%%subfunctions%%%%%%%%%% %%
%%
    function update_area(threshold, params)
        if isfield(params{1,imgobj.nROI}, 'stim1')
            ind_stim_on = find(imgobj.dFF(:, 3, imgobj.nROI) > threshold, 1);
            ind_stim_off = find(imgobj.dFF(:, 3, imgobj.nROI) > threshold, 1, 'last');
            
            if isempty(ind_stim_on) == 0 && isempty(ind_stim_off) == 0
                set_area(hfig.area1_1, recTime, ind_stim_on, ind_stim_off, imgobj.dFF(:,1,imgobj.nROI));
                set_area(hfig.area1_2, recTime, ind_stim_on, ind_stim_off, imgobj.dFF(:,2,imgobj.nROI));
            else
                set(hfig.area1_1,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
                set(hfig.area1_2,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
            end
        else
            set(hfig.area1_1,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
            set(hfig.area1_2,'XData', [NaN, NaN], 'YData', [NaN, NaN]);
        end
    end

%%
    function set_area(harea, recTime, ind_on, ind_off, data)
        y_max = max(data);
        y_min = min(data);
        if ind_off == length(recTime)
            ind_off = ind_off - 1;
        end
        set(harea, 'XData', [recTime(ind_on), recTime(ind_off)], 'YData', [y_max, y_max], 'basevalue', y_min);
    end

%%
    function N = update_n(set_n)
        if set_n == 1
            if imgobj.nROI < imgobj.maxROIs
                N = imgobj.nROI + 1;
            else
                N = imgobj.nROI;
                disp('No more ROI.')
            end
            set(hfig.two_photon_set_roi_n, 'string', num2str(N))
        elseif set_n == -1
            if imgobj.nROI < imgobj.maxROIs + 1 && imgobj.nROI > 1
                N = imgobj.nROI - 1;
            else
                N = imgobj.nROI;
                disp('First ROI.')
            end
            set(hfig.two_photon_set_roi_n, 'string', num2str(N))
        else
            N = str2double(get(hfig.two_photon_set_roi_n, 'string'));
        end
    end

%%
    function update_plot(h_plot, x, y, n)
        set(h_plot, 'XData', x, 'YData', y(:,n));
    end


end