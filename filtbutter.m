function [y b a]  = filtbutter(N, Fs,Type, SampF,Data)
%
% Apply Butterworth Fitler to recorded data
%
if isempty(Type)
    [b,a] = butter(N,Fs/SampF/2);
else
    [b,a] = butter(N, Fs/(SampF/2), Type);
end
y = filtfilt(b, a, Data);

