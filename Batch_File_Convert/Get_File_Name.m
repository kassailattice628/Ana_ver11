function [Dir, File, Ext, Fsuf, Psuf] = Get_File_Name(varargin)

switch nargin
    case 0
        dir = [];
    case 1
        dir = vargin(1);
end
% select file and split file name for convert file type
if ~isempty(dir)
    [f, Dir] = uigetfile(dir, {'*.tif; *.tiff; *.mat', 'DATA files'});
else 
    [f, Dir] = uigetfile({'*.tif; *.tiff; *.mat', 'DATA files'});
end
[~, File, Ext] = fileparts(f);
[i1, i2] = regexp(File, '\d*');
Fsuf = File(1:i1(1)-1);
Psuf = File(i2(1)+1:end);

%Fid_str = dir([Dir, Fsuf, '*', Ext]);
end