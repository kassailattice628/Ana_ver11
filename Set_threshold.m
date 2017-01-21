function Set_threshold(hGui,~, h, data, params)

threshold =  str2double(get(hGui, 'string'));

if threshold < get(h.slider4, 'Min') || threshold > get(h.slider4, 'Max')
    errordlg('Out of Range!')
    threshold = 0.0025;
    set(hGui, 'string', threshold);
end

set(h.slider4, 'value', threshold);

Plot_next([], [], data, 0, params);
end