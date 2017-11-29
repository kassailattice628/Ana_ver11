function [Dir, File, Ext, Fsuf, Psuf] = Get_File_Name(varargin)
%ファイル名のサフィックスなどを抽出, mat と tif を選択させる
switch nargin
    case 0
        dir_name = [];
    case 1
        dir_name = char(varargin{1});
end
% select file and split file name for convert file type

if ~isempty(dir_name)
    %     [f, Dir] = uigetfile({[dir,'*.tif'], 'TIF files';...
    %         [dir,'*.tiff'], 'TIFF files';...
    %         [dir,'*.mat'], 'MAT files'},...
    %         'select Data files');
    %[f, Dir] = uigetfile({'*.tif', 'TIF files'; '*.mat', 'MAT files'}, 'SELECT files', '/Volumes/MyBook2017/2PData/');
    [f, Dir] = uigetfile({'*.tif', 'TIF files'; '*.mat', 'MAT files'}, 'SELECT files', dir_name);
else
    [f, Dir] = uigetfile({'*.tif'; '*.mat'}, 'SELECT files');
end
[~, File, Ext] = fileparts(f);
[i1, i2] = regexp(File, '\d*');
Fsuf = File(1:i1(1)-1);
Psuf = File(i2(1)+1:end);

%Fid_str = dir([Dir, Fsuf, '*', Ext]);
end