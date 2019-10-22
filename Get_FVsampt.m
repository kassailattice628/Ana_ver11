function [tpf, imgsz]  = Get_FVsampt(~, ~)
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
    imgsz = size(data{1,1}{1,1});
    imgobj.imgsz = imgsz;
else
    imgsz = [];
end

%Update GUI
if exist('hfig', 'var')
    set(hfig.FVsampt, 'String', num2str(tpf));
    
    %save mat
    Update_Params
end

end

