function [positionDataDeg, rotVel] = DecodeRot(CTRin, n, p, r)
% Transform DAQ counter data 
% from rotary encoder into angular position (deg).

signedThreshold = 2^(32-1); %resolution 32 bit

CTRin(CTRin > signedThreshold) = CTRin(CTRin > signedThreshold) - 2^32;
positionDataDeg = CTRin * 360 / 1000 / 4;

rotMove = positionDataDeg / 360 * 8; %8 cm cylinder <- %12 cm Disk
rotMove = rotMove - rotMove(1); 

%filte data
d_filt = designfilt('lowpassfir', 'FilterOrder', 8,...
    'CutoffFrequency', 10, 'SampleRate', r.sampf);

rotMove_filt = filtfilt(d_filt, rotMove);
rotVel = abs(diff(rotMove_filt)/p{1,n}.AIstep);

%rotVel = movmean(rotVel, 3);
rotVel = smooth(rotVel, 10, 'moving');
end