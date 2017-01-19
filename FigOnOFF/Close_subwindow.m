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
end

end
