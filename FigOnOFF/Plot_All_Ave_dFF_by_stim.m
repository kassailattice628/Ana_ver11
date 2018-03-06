function Plot_All_Ave_dFF_by_stim(~,~, cmin, cmax)
%%%%%%%%%%
% Show Matrix for averaged traces for all ROI
%%%%%%%%%

global imgobj
%%%%%%%%%%
mag_os = 200; %oversampling x200
c_min = str2double(get(cmin, 'string'));
c_max = str2double(get(cmax, 'string'));

%% Get_dFF, Averaged by Stim Types
%[ ~, datap, datap_os, ~] = Get_dFF_Ave(mag_os);
%
if ~isfield(imgobj, 'dFF_s_ave')
    [~, datap, datap_os, ~] =  Get_dFF_Ave(mag_os);
else
     datap = size(imgobj.dFF_s_ave, 1);
     datap_os = size(imgobj.dFF_s_ave_os, 1);
end
%}
%% %%%%%%%%%% Plot %%%%%%%%%% %%
%% plot simple average
% transform 3D-mat into 2D-mat

mat = zeros(5 + datap, size(imgobj.dFF_s_ave,2), size(imgobj.dFF_s_ave,3));
mat(1:datap,:,:) =  imgobj.dFF_s_ave;
imgobj.mat2D = reshape(mat, [], imgobj.maxROIs);

show_mat(imgobj.mat2D)

%% plot oversamped average
mat = zeros(5 + datap_os, size(imgobj.dFF_s_ave_os,2), size(imgobj.dFF_s_ave_os,3));
mat(1:datap_os,:,:) =  imgobj.dFF_s_ave_os;
mat2D_os = reshape(mat, [], imgobj.maxROIs);

show_mat(mat2D_os)

%% subfunctions plot %%
    function show_mat(mat)
        figure
        imagesc(mat')
        caxis([c_min, c_max])
        ylabel('Neuron#')
        xlabel('data point')
    end
end