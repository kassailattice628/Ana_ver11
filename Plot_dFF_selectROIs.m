function Plot_dFF_selectROIs(~, ~)
%%
global hfig
global imgobj
%%
% str2double だと 配列データが取れないので str2num を使用
selectedROI = str2num(get(hfig.two_photon_select_roi_n,'String'));
if isempty(get(hfig.two_photon_select_roi_n,'String'))
    selectedROI = 1:imgobj.maxROIs;
end

deselectROI = str2num(get(hfig.two_photon_deselect_roi_n,'String'));
if isempty(get(hfig.two_photon_deselect_roi_n,'String'))
    deselectROI =[];
end

%%
imgobj.selectROI = setdiff(selectedROI, deselectROI);

hold on
if isfield(hfig, 'two_photon_plot2')
    for i = 1:length(hfig.two_photon_plot2)
        set(hfig.two_photon_plot2(i), 'XData', NaN, 'YData', NaN);
    end
    clear hfig.two_photon_plot2;
    %hfig = rmfield(hfig, 'two_photon_plot2');
end

hfig.two_photon_plot2 = zeros(length(imgobj.selectROI),1);
for i = 1:length(imgobj.selectROI)
    hfig.two_photon_plot2(i) = plot(imgobj.FVt, imgobj.dFF(:, imgobj.selectROI(i)), 'k');
    set(hfig.two_photon_plot2(i), 'Parent', hfig.two_photon_axes2);
end

hold off
end