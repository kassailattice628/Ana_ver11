function [fitresult, gof] = Get_Fit_for_PredInt(x_boot, direction, pref, type)

dir = repmat(direction, 5000, 1);

[xData, yData] = prepareCurveData( dir, x_boot );

[f_vM, opts] = SelectFitOpt(type, pref);

[fitresult, gof] = fit( xData, yData, f_vM, opts );
end

%%
function [func, opts] = SelectFitOpt(type, pref)

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
if type == 1
    func = fittype( 'a * exp(b * cos(x - c)) + d', 'independent', 'x', 'dependent', 'y' );
    
    opts.StartPoint = [1, 1, pref, 0];
    opts.Lower = [0.001, 0.01, 0, 0];
    opts.Upper = [5, 5, 2*pi, 5];
    
elseif type == 2
    func =  fittype( 'a * exp(b * cos(x - e)) * exp(c * cos(2*x - 2*(e+f))) + d', 'independent', 'x', 'dependent', 'y' );
    
    opts.StartPoint = [1, 1, 0, 0, pref, wrapTo2Pi(pref+pi)];
    opts.Lower = [0.001, 0.01, 0.01, 0, 0, -pi];
    opts.Upper = [5, 5, 5, 5, 2*pi, pi];
end


opts.Display = 'Off';
opts.Robust = 'Bisquare';

end
