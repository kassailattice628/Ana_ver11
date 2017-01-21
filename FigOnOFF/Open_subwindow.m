function Open_subwindow(hObject, ~, params, recobj, sobj, name)
global hfig

if get(hObject, 'value')
    if strcmp(name,'two_photon')
        Open_2P(hObject, params, recobj);
    elseif strcmp(name, 'params_table')
        Open_Params_Table(hObject, params, recobj, sobj);
    end
else
    if isfield(hfig, name)
        close(getfield(hfig, name))
        %hfig = rmfield(hfig, 'params_table');
    end
end

end