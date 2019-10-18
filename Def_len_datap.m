function [prep, postp, p_on, p_off, datap] = Def_len_datap
%%%%%%%%%%
%
%set time point for stimulus average
%pre stimulus time befor 1 sec from stim ON
%
%%%%%%%%%%

global sobj
global imgobj
%%
pret = 1; %sec
prep = ceil(pret/imgobj.FVsampt); %point

% stim duration
if strcmp(sobj.pattern, 'MoveBar')
    duration = max(sobj.moveDuration);
else
    duration = sobj.duration;
end

% to capture off reponse;
if strcmp(sobj.pattern, 'FineMap')
    n = 4;
    %if duration + 4 is longer than recording time, reset n = 2.
elseif strcmp(sobj.pattern, 'Uni')
    n = 1;
else
    n = 5;
end

postp = round( (duration + n) / imgobj.FVsampt);

p_on = prep + 1;
p_off = p_on + postp;

%data points for plot
datap = p_on + p_off;

end