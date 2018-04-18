function Get_Stim_Tuning(roi)
%%%%%%%%%%
%
% Get stimulus specific tuning properties
%
%%%%%%%%%%

global imgobj
global sobj

s_ave = imgobj.dFF_s_ave;
s_each = imgobj.dFF_s_each;

if nargin == 0
    roi = 1:imgobj.maxROIs;
end

[ ~, ~, p_on, p_off, ~] = Def_len_datap;

nstim = size(s_each, 2);
%%%%%%%%%%
%%
switch sobj.pattern
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    case 'Size_rand'
        % Best Size (for ON and OFF)
        imgobj.R_size = zeros(nstim, imgobj.maxROIs, 3);
        for i = roi
            base = mean(s_ave(1:2, :, i));
            
            %ON reponse
            imgobj.R_size(:, i, 1) = max(s_ave(p_on:p_off, :, i) - base)';
            %OFF response
            imgobj.R_size(:, i, 2) = max(s_ave(p_off:end, :, i) - base)';
            %All
            imgobj.R_size(:, i, 3) = max(s_ave(:, :, i) - base)';
        end
        
    case {'Sin', 'Rect', 'Gabor', 'MoveBar'}
        % Distribution of direction selectivity
        if length(roi) == imgobj.maxROIs
            imgobj.Ang_ori0 = zeros(1, imgobj.maxROIs);
            imgobj.L_ori = zeros(1, imgobj.maxROIs);
            imgobj.L_dir = zeros(1, imgobj.maxROIs);
        end
        
        dir = linspace(0, (2*pi - 2*pi/nstim), nstim);
        for i = roi
            R_all_dir = nanmean(s_each(:, :, i));
            R_all_dir(R_all_dir < 0) = 0;
            %%%%%%%%%%
            % vector average for orientation
            %%%%%%%%%%
            Z = sum(R_all_dir .* exp(2*1i*dir))/sum(R_all_dir);
            imgobj.L_ori(i) = abs(Z);
            
            a = angle(Z)/2 + pi/2;
            imgobj.Ang_ori0(i) = a;
            
            if a > pi/2 && 3*pi/2 > a
                a = a - pi;
            end
            imgobj.Ang_ori(i) = a;
            
            %%%%%%%%%%
            % vector average for direction
            %%%%%%%%%%
            Z = sum(R_all_dir .* exp(1i*dir))/sum(R_all_dir);
            imgobj.L_dir(i) = abs(Z);
            imgobj.Ang_dir(i) = wrapTo2Pi(angle(Z));
        end
end

%%
end