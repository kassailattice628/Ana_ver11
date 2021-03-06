function [R_boot_med, b_GaRot2D, Ci_GaRot2D, b_Ellipse] = Get_Boot_RF(imgobj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Resample data by bootstrap
% Calc bootstrapped mean of the data and median of each conditions
% Fit the bootstrapped data to the 2D Gaussian
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%addpath('/Users/lattice/Dropbox/None_But_Air/Ana_ver11/RF/')
global sobj
global hfig
cb = get(hfig.h_CB, 'Value');

%%%%%%%%%%

%stim_position
if isfield(sobj, 'center_pos_list_FineMap') && strcmp(sobj.pattern, 'FineMap')
    %Fine map mode
    pos =  sqrt(size(sobj.center_pos_list_FineMap, 1));
else
    %Normal uni
    pos = sqrt(size(sobj.center_pos_list,1));
end

[X, Y] = meshgrid(1:pos);
position = zeros(pos, pos, 2);
position(:,:,1) = X;
position(:,:,2) = Y;

%%%%%%%%%%
n_boot = 100;

R_boot_med = zeros(size(imgobj.dFF_s_each,2), imgobj.maxROIs);

b_GaRot2D = zeros(imgobj.maxROIs, 6);
Ci_GaRot2D = zeros(imgobj.maxROIs, size(b_GaRot2D,2)*2);

b_Ellipse = zeros(imgobj.maxROIs, 5);


%%%%%%%%%%
for i = 1:imgobj.maxROIs
    s_each = imgobj.dFF_s_each(:,:,i);
    s_each = s_each(any(s_each,2),:);
    %if isempty(rmmissing(imgobj.dFF_s_each(:,:,i)))
    if isempty(s_each)
        disp(['Data missing in roi#', num2str(i)])
        continue
    end
    
    x_boot = Get_boot(s_each, n_boot);
    data = median(x_boot);
    R_boot_med(:,i) = data;
    
    if max(data) >= 0.15
        data = reshape(data,[pos, pos]);
        [b_fit, ~, ci] = Exec_FitRF(position, data);
        b_GaRot2D(i,:) = b_fit;
        Ci_GaRot2D(i,:) = ci;
        
        b_e = Plot_FitRF(b_fit, data, i, cb);
        b_Ellipse(i, :) =  b_e;
    end
end
end

%%
%%%%%%%%%% %%%%%%%%%% %%%%%%%%%% %%%%%%%%%%
function [b_fit, res, ci] = Exec_FitRF(pos, data)
b0 = [1 5, 5, 5, 1, 0];
bu = [5, 13, 20, 13, 10, pi];
bl = [0.01, -3, 0.5, -3, 0.5, 0];
opts = optimset('Display','off');

[b_fit, res, r, ~,~,~,J] = lsqcurvefit(@GaussianRot2D, b0, pos, data, bl, bu, opts);

ci = nlparci(b_fit, r ,'jacobian',J);
ci = reshape(ci', 1, []);

end

