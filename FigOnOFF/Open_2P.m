function  Open_2P(hfig_handle)
global hfig
hfig.two_photon = figure('Position', [10, 20, 1000, 500], 'Name', 'Two-photon Traces',...
    'NumberTitle', 'off', 'Menubar', 'none', 'Resize', 'off',...
    'DeleteFcn', {@Close_subwindow, hfig_handle});



end

%%