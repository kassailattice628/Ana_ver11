function Close_subwindow(~, ~, hfig_handle, h_name)
global hfig
hfig = rmfield(hfig, h_name);

set(hfig_handle, 'value', 0);

if strcmp(h_name,'two_photon')
    if isfield(hfig, 'two_photon_plot1');
        hfig = rmfield(hfig, 'two_photon_plot1');
    end
    if isfield(hfig, 'two_photon_plot2')
        hfig = rmfield(hfig, 'two_photon_plot2');
    end
    
elseif strcmp(h_name, 'eye_position')
    if isfield(hfig, 'plot5')
        hfig = rmfield(hfig, 'plot5');
    end
    
elseif strcmp(h_name, 'peri_saccade')
    if isfield(hfig, 'plot6_1')
        hfig = rmfield(hfig, 'plot6_1');
        hfig = rmfield(hfig, 'plot6_2');
    end
end




end
