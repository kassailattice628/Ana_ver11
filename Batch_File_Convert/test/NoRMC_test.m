%NoRMCorre work

clear
addpath(genpath('~/Dropbox/TwoPhoton_Analysis/NoRMCorre/'));

gcp; %start parallel workes

%% open file(s)

if exist('dirname', 'var')
    [fname, dirname] = uigetfile(dirname);
else 
    [fname, dirname] = uigetfile;
end
[~, ~, ext] = fileparts(fname);
 
%file list, name of each file is accessed by files(n).name
files = subdir(fullfile(dirname, ['*',ext])); 

% if


