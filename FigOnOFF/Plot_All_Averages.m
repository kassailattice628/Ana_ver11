function Plot_All_Averages(~,~, cmin, cmax)
%%%%%%%%%%
% Show Matrix for averaged traces for all ROI
%%%%%%%%%

global imgobj
global sobj
%%%%%%%%%%

%%
if ~isfield(imgobj, 'dFF_s_ave')
    errordlg(' Get Trial Averages!!')
end

%%
c_min = str2double(get(cmin, 'string'));
c_max = str2double(get(cmax, 'string'));

datap = size(imgobj.dFF_s_ave, 1);
%% plot simple average
% transform 3D-mat into 2D-mat

mat = zeros(5 + datap, size(imgobj.dFF_s_ave,2), size(imgobj.dFF_s_ave,3));
mat(1:datap,:,:) =  imgobj.dFF_s_ave;
imgobj.mat2D = reshape(mat, [], imgobj.maxROIs);

%%—ÕŽž
if strcmp(sobj.pattern, 'Size_rand')
    mat = zeros(5 + datap, 5, size(imgobj.dFF_s_ave,3));
    mat(1:datap,:,:) = imgobj.dFF_s_ave(:, 1:5, :) ;
    imgobj.mat2D = reshape(mat, [], imgobj.maxROIs);
end

%%—ÕŽž
if strcmp(sobj.pattern, 'MoveBar')
    %imgobj.mat2D = imgobj.mat2D(:,1:214);
end

show_mat(imgobj.mat2D)


%% subfunctions plot %%
    function show_mat(mat)
        figure
        imagesc(mat')
        caxis([c_min, c_max])
        ylabel('Neuron#')
        xlabel('data point')
    end
end