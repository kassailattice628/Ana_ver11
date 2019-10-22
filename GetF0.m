function numF0 = GetF0(~,~)
global ParamsSave
global recobj
global imgobj

switch nargin
    case 0
        if isfield(ParamsSave{1,recobj.prestim + 1}.stim1, 'corON')
            numF0 = floor(ParamsSave{1,recobj.prestim + 1}.stim1.corON / imgobj.FVsampt) - 1;
        else
            warndlg('Onset of the first stimulus timing is not defined !!!')
        end
        
        
    case 2    
        if isfield(ParamsSave{1,recobj.prestim + 1}.stim1, 'corON')
            numF0 = floor(ParamsSave{1,recobj.prestim + 1}.stim1.corON / imgobj.FVsampt) - 1;
            
            msgbox(['The number of frames for prestimulus is :: ', num2str(numF0)] );
        else
            warndlg('Onset of the first stimulus timing is not defined !!!')
        end
end
end