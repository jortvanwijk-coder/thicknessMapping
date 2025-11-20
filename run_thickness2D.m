% 20-Nov-2025 2D mapping of EHL contact image
% Jort van Wijk, j.vanwijk@student.utwente.nl
%
% Version 1.2, addition of createCalibPlot and image size check
%
% The function thickness 2D returns the thickness along a centerline chosen
% by the user. Based on an anchor point the user selects and the
% calibration value form the calibration matrix. 
% 
% This script makes use of the following funtions:
% thickness2D
    % hueToThickness
        % getCalibrationMatrix
    % assignThickness
    % opt: createCalibPlot
%
% Figure 2 can also include the spacer layer thickness (p1) and the selected
% reference point (p3) as a check. 
clc, clear, close all

[leftThickness, midAnchorX, midAnchorThickness] = thickness2D();

% Optionally; create a plot of the calibration matrix
%createCalibPlot()             %-> plots curves only
%createCalibPlot(145)          %-> plots curves and marks the specified hue