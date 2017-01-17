function Close_subwindow(~, ~, hfig_handle, h_name)
global hfig
hfig = rmfield(hfig, h_name);
set(hfig_handle, 'value', 0);
end
