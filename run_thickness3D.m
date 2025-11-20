% 20-Nov-2025 3D mapping of EHL contact image
% Jort van Wijk, j.vanwijk@student.utwente.nl
%
% Version 1.1, addition of createCalibPlot and image size check
%
% The function thickness 3D returns the thickness along a chosen circle of 
% interest based on a selected central thickness.
% 
% This script makes use of the following funtions:
% thickness3D
    % hueToThickness
        % getCalibrationMatrix
    % assignThickness
    % thickness2D_singleSlice
    % opt: createCalibPlot
%
clc, clear, close all

thicknessMap3D = thickness3D();

% Optionally; create a plot of the calibration matrix
%createCalibPlot()             %-> plots curves only
%createCalibPlot(145)          %-> plots curves and marks the specified hue