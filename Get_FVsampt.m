function [tpf, imgsz]  = Get_FVsampt(~, ~)
% Read Time Per Frame from
% OIF or OIB data
%
global imgobj
global hfig

key = {'Time Per Frame', '[Axis 0 Parameters Common] MaxSize',...
    '[Axis 1 Parameters Common] MaxSize'};
params = Get_metadata([], key);

tpf = params(1) * 10^-6;
imgsz = [params(2), params(3)];

if exist('imgobj', 'var')
    imgobj.FVsampt =tpf;
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

