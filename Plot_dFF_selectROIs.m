function Plot_dFF_selectROIs(~, ~)
%%
global hfig
global imgobj
%%
% Selected
selectedROI = str2num(get(hfig.two_photon_select_roi_n,'String'));
if isempty(get(hfig.two_photon_select_roi_n,'String'))
    selectedROI = 1:imgobj.maxROIs;
end

deselectROI = str2num(get(hfig.two_photon_deselect_roi_n,'String'));
if isempty(get(hfig.two_photon_deselect_roi_n,'String'))
    deselectROI =[];
end

imgobj.selectROI = setdiff(selectedROI, deselectROI);

%set(hfig.two_photon_plot2, 'XData',imgobj.FVt, 'YData', imgobj.dFF(:, imgobj.selectROI));
hfig.two_photon_plot2 = plot(imgobj.FVt, imgobj.dFF(:, imgobj.selectROI));

set(hfig.two_photon_axes2, 'XLimMode', 'manual', 'XLim', [0, imgobj.FVt(end)], 'xticklabel', [],...
    'YLimMode', 'Auto');
end