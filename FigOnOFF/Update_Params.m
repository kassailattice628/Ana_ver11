function Update_Params(~,  ~, h)
global DataSave
global imgobj
global ParamsSave
global recobj
global sobj

global mainvar


switch nargin
    case {0, 1, 2}
        %suf = '_new';
        suf = [];
    case 3
        suf = get(h, 'string');
end
if ~exist(mainvar.dirname, 'dir')
    mainvar.dirname = uigetdir;
    mainvar.dirname = [mainvar.dirname, '/'];
end
[~, name, ext] = fileparts(mainvar.fname);
save_name = [mainvar.dirname, name, suf, ext];
%update parameters

save(save_name, 'DataSave', 'imgobj', 'mainvar', 'ParamsSave', 'recobj', 'sobj');
%save save_name DataSave imgobj mainvar ParamsSave recobj sobj;

disp(['save as ', save_name]);

end