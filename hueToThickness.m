function [thickness_N1, thickness_N2, thickness_N3] = hueToThickness(hue_angle)
% Input:
%   hue_angle - Hue angle in degrees (0 to 360)
%
% Output:
%   thickness_N1 - Film thickness for 1st interference order
%   thickness_N2 - Film thickness for 2nd interference order  
%   thickness_N3 - Film thickness for 3rd interference order

    % Validate input
    if hue_angle < 0 || hue_angle > 360
        error('Hue angle must be between 0 and 360 degrees');
    end

    % Calibration matrix
    calMatrix = getCalibrationMatrix();

    % Extract hue from extended matrix
    RGB_values = calMatrix(:,2:4);
    HSV_values = rgb2hsv(RGB_values);
    hue_values = HSV_values(:,1) * 360; 
    hue = [hue_values', 360]; % Add angle of 360 for extrapolation
    
    % Extract thickness data
    N1 = calMatrix(:, 5)';  % 1st interference order
    N2 = calMatrix(:, 6)';  % 2nd interference order
    N3 = calMatrix(:, 7)';  % 3rd interference order

    % Extrapolate to 360deg
    exN1 = interp1([0 240], [calMatrix(1,5) calMatrix(5,5)], 360, 'linear', 'extrap');
    exN2 = calMatrix(1,5);
    exN3 = calMatrix(1,6);

    % Extended thickness arrays with extrapolated values
    N1_extended = [N1, exN1];  % 1st interference order
    N2_extended = [N2, exN2];  % 2nd interference order  
    N3_extended = [N3, exN3];  % 3rd interference order

    % Interpolate to get thickness at requested hue angle
    thickness_N1 = interp1(hue, N1_extended, hue_angle, 'linear');
    thickness_N2 = interp1(hue, N2_extended, hue_angle, 'linear');
    thickness_N3 = interp1(hue, N3_extended, hue_angle, 'linear');
    
    % Optional: Plot can be created of the calibration values
    % createCalibPlot(hue, N1_extended, N2_extended, N3_extended, hue_angle);
     
    % Optional: Export variables
    % exportVars()
end

