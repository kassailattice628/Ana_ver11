function params = Get_metadata(fpath, keylist)
%check input
if isempty(fpath)
    [f, d] = uigetfile({'*.oif;*.oib;*bfmeta.txt'},"Select MetaData");
    fpath = [d, f];
end

%% load data
Add_PyPath;
[d, f, e] = fileparts(fpath);

if strcmp(e, '.txt')
    params = py.bfloadpy.extract_any(fpath, keylist);
else
    % oif or oib
    py.bfloadpy.bioform_2_txt(fpath ,fpath);
    txt_path = fullfile(d, [f, '_bfmeta.txt']);
    params = py.bfloadpy.extract_any(txt_path, keylist);
end

params = cellfun(@double, cell(params));
end


%{

%set output
varargout = cell(1,length(keylist));
%bfmatlab ‚Ì bfopen ‚Í‰æ‘œ‚Ì“Ç‚İ‚İ + ‚³‚ç‚É‚»‚ÌƒRƒs[‚Å’x‚·‚¬‚é‚Ì‚Å
metadata = load_bf(fpath);
%allKeys = arrayfun(@char, metadata.keySet.toArray, 'UniformOutput', false);

%check keylist
keylist = Check_keylist(metadata, keylist);
for i = 1:length(keylist)
    varargout{i} = metadata.get(keylist{i});
end

disp('OK')

%end

%%

function metadata = load_bf(fpath)
data =  bfopen(fpath);
metadata =  data{1,2};
end

%%
function key = Check_keylist(mdata, key)
if isempty(mdata.get(key{1}))
    for i = 1:length(key)
        key{i} = ['Global ', key{i}];
    end
end
end
%}