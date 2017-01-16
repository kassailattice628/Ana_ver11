function Close_subwindow(~, ~, hfig_handle)
%global hfig
%hfig = rmfield(hfig, 'params_table');
set(hfig_handle, 'value', 0);
end
