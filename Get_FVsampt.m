function tpf = Get_FVsampt(~, ~)
% Read Time Per Frame from
% OIF or OIB data
%

global imgobj
global hfig

[f, d] = uigetfile(...
    {'*.oif; *.oib', 'Olympus'},...
    'SELECT files');

data = bfopen([d,f]);
metadata =  data{1,2};

%Time Per Frame (us)
tpf = metadata.get('Global Time Per Frame');
tpf = str2double(tpf) * 10^-6;
if exist('imgobj', 'var')
    imgobj.FVsampt =tpf;
    imgobj.imgsz = size(data{1,1}{1,1});
end

%Update GUI
if exist('hfig', 'var')
    set(hfig.FVsampt, 'String', num2str(tpf));
    
    %save mat
    Update_Params
end

end

