function Apply_threshold_to_all(hGui,~, hthreshold, data)
global ParamsSave
global recobj

threshold = str2double(get(hthreshold, 'string'));
if get(hGui, 'value')
    for i = 1:size(data,3)
        if isfield(ParamsSave{1,i}, 'stim1')
            ind_on = find(data(:, 3, i) > threshold, 1);
            ind_off = find(data(:, 3, i) > threshold, 1, 'last');
            recTime = ParamsSave{1,i}.AIStartTime:1/recobj.sampf:ParamsSave{1,i}.AIEndTime+1/recobj.sampf;

            corON= recTime(ind_on) - (ParamsSave{1,i}.stim1.centerY_pix - 40)/1024/75;
            ParamsSave{1,i}.stim1.corON =  corON;
            
            corOFF= recTime(ind_off) - (ParamsSave{1,i}.stim1.centerY_pix - 40)/1024/75;
            ParamsSave{1,i}.stim1.corOFF =  corOFF;
        end
    end
end
