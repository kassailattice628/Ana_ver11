function numF0 = GetF0(~,~)
global ParamsSave
global recobj
global imgobj


if isfield(ParamsSave{1,recobj.prestim + 1}.stim1, 'corON')
    numF0 = floor(ParamsSave{1,recobj.prestim + 1}.stim1.corON / imgobj.FVsampt) - 1;
    
    if nargin == 2
        msgbox(['The number of frames for prestimulus is :: ', num2str(numF0)] );
    end
    imgobj.f0 = numF0;
    Update_Params;
else
    warndlg('Onset of the first stimulus timing is not defined !!!')
end

end