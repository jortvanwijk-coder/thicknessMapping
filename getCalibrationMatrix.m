function calMatrix = getCalibrationMatrix()
% Output:
%   calMatrix - Calibration matrix with columns: 
%               [wavelength, R, G, B, thickness_N1, thickness_N2, thickness_N3]

    calMatrix = [... 
                640, 1, 0, 0, 216, 437, 658;  % Red
                570, 1, 1, 0, 193, 389, 586;   % Yellow
                510, 0, 1, 0, 172, 348, 524;   % Green
                490, 0, 1, 1, 166, 335, 504;   % Cyan
                440, 0, 0, 1, 149, 300, 452];  % Blue   
end 