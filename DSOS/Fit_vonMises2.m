function [b_fit, ci, f_select, R_boot_med] = Fit_vonMises2(data_boot, dir, pref, type, roin)
% d := direction vector,
% ex) d = dir = 0:pi/6:23*pi/12;

R_boot_med = median(data_boot);

data = reshape(data_boot, 1, []);
opts = optimset('Display','off');

dir_ = repmat(dir, [size(data_boot,1), 1]);
dir_ = reshape(dir_, 1, []);

switch type
    case 1
        %DS �̏ꍇ
        [f_vM1, b0, bl, bu] = Set_FitFc(1);
        [b_fit1, res1, ci1] = Exec_Fit(f_vM1, b0, bl, bu);
        
        
        [f_vM2, b0, bl, bu] = Set_FitFc(2);
        [b_fit2, res2, ci2] = Exec_Fit(f_vM2, b0, bl, bu);
        
        
        if abs(b_fit2(5) - b_fit2(6)) > pi/4
            b_fit = b_fit1;
            ci = ci1;
            f_vM = f_vM1;
            f_select = 1;
        else
            
            if res1 <= res2
                b_fit = b_fit1;
                ci = ci1;
                f_vM = f_vM1;
                f_select = 1;
                
            else
                b_fit = b_fit2;
                ci = ci2;
                f_vM = f_vM2;
                f_select = 2;
            end
        end
        
    case 2
        %OS �̏ꍇ
        [f_vM, b0, bl, bu] = Set_FitFc(2);
        [b_fit, ~, ci] = Exec_Fit(f_vM, b0, bl, bu);
        f_select = 2;
        
        
        
    case 3
        %{
        %not use now
        %Two peaks which are separated wit Pi degree.
        b0 = [1, 1, 0, 0, pref];
        bl = [0.001, 0.01, 0.01, 0, 0];
        bu = [5, 5, 5, 5, 2*pi];
        
        f_vM = @(b, x) b(1) * exp(b(2) * cos(x - b(5))) .*...
            exp(b(3) * cos(2* (x - (b5)))) + b(4);
        %}
end

Plot_DSOS(f_vM, b_fit, dir, R_boot_med, roin, type)

%%%%%%%%%% %%%%%%%%%% %%%%%%%%%% %%%%%%%%%% %%%%%%%%%% %%%%%%%%%%

    function [f_vM, b0, bl, bu] = Set_FitFc(select)
        if select == 1
            %Single peak
            
            %parameters
            %1: Amplitude Adujusting
            %2: Amp DS component
            %3: Prefered Direction
            %4: Base line
            b0 = [1, 1, pref, 0];
            
            bl = [0.001, 0.01, 0, 0];
            bu = [5, 5, 2*pi, 5];
            
            %f_vM = @(b, x) b(1) * exp(b(2) * cos(x - b(3))) + b(4);
            f_vM = Select_vonMises(select);
            
        elseif select == 2
            %mainly 1 peak but has second peaks
            
            %parameters
            %1: Amplitude Adujusting
            %2: Amp DS component
            %3: Amp OS component
            %4: Base line
            %5: Prefered Direction
            %6: Second peak adjustiment
            b0 = [1, 1, 0, 0, pref, wrapTo2Pi(pref+pi)];
            
            bl = [0.001, 0.01, 0.01, 0, 0, -pi];
            bu = [5, 5, 5, 5, 2*pi, pi];
            
%             f_vM = @(b, x) b(1) * exp(b(2) * cos(x - b(5))) .*...
%                 exp(b(3) * cos(2*x - 2*(b(5)+b(6)))) + b(4);
            f_vM = Select_vonMises(select);
            
        end
    end

%%%%%%%%%% %%%%%%%%%%



    function [b_fit, res, ci] = Exec_Fit(f_vM, b0, bl, bu)
        [b_fit, res, r, ~,~,~,J] = lsqcurvefit(f_vM, b0, dir_, data, bl, bu, opts);
        ci = nlparci(b_fit,r,'jacobian',J);
        ci = reshape(ci', 1, []);
        disp(['ROI# = ', num2str(roin)])
        disp(res)
    end

end

