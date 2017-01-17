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