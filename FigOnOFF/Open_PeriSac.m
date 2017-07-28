function Open_PeriSac(hfig_handle, p, r)
%Extract peri saccade in the trial and show superimposed traces.
global hfig
global DataSave
data = DataSave;

%%
h_name = 'peri_saccade';

hfig.peri_saccade = figure('Position', [1010, 320, 300, 500], 'Name', 'Peri Saccade Traces',...
    'NumberTitle', 'off', 'Menubar', 'none', 'Resize', 'off', 'DeleteFcn', {@Close_subwindow, hfig_handle, h_name});

%%
hfig.axes6_1 = subplot(2,1,1);
set(hfig.axes6_1, 'YLim', [-4, 4])
%hfig.plot6_1 = plot(NaN, NaN);
hfig.axes6_2 = subplot(2,1,2);
set(hfig.axes6_2, 'YLim', [-4, 4])
%title('Vertical')

Plot_next([], [], data, 0, p, r)

end