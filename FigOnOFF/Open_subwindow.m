function Open_subwindow(hObject, ~, p, r, s, name)
global hfig

if get(hObject, 'Value')
    if strcmp(name,'two_photon')
        Open_2P(hObject, p, r, s);
        
    elseif strcmp(name, 'params_table')
        Open_Params_Table(hObject, r, s);
        
    elseif strcmp(name, 'eye_position')
        Open_EyePos(hObject, p, r);
        
    elseif strcmp(name, 'peri_saccade')
        Open_PeriSac(hObject, p, r)
    end
    
else
    if isfield(hfig, name)
        close(getfield(hfig, name))
    end
end

end