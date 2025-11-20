function [leftThickness, midAnchorX, midAnchorThickness] = thickness2D_singleSlice(img, ySlice, xMid, prevThickness)
% The function thickness2D_singleSlice is a adaption from thickness2D. The
% same thickness calculation is used per pixel row in thickness3D.

% Extract RGV to HSV
R = double(img(ySlice, :, 1));
G = double(img(ySlice, :, 2));
B = double(img(ySlice, :, 3));
RGB_row = cat(3, R/255, G/255, B/255);
HSV_row = rgb2hsv(RGB_row);
hue_angle = HSV_row(1, xMid, 1) * 360;
[t1, t2, t3] = hueToThickness(hue_angle);
thicknessValues = [t1; t2; t3; 500];

% Get thickness from previous row
if nargin == 4
    [~, idx] = min(abs(thicknessValues - prevThickness));
    midAnchorThickness = thicknessValues(idx);
else
    midAnchorThickness = thicknessValues(1);
end

% Thickness calculation per pixel
numPixels = size(img,2);
thicknessMatrix = zeros(3, numPixels);
for x = 1:numPixels
    hue_angle = HSV_row(1, x, 1) * 360;
    [th1, th2, th3] = hueToThickness(hue_angle);
    thicknessMatrix(:, x) = [th1; th2; th3];
end

% Thickness with moving window
windowSize = 5;
leftThickness = NaN(1, numPixels);
leftThickness(xMid) = midAnchorThickness;

% Right side of slice
for x = xMid+1:numPixels
    prevIdx = max(xMid, x-windowSize);
    expectedValue = mean(leftThickness(prevIdx:x-1));
    candidateValues = thicknessMatrix(:, x);
    [~, idx] = min(abs(candidateValues - expectedValue));
    leftThickness(x) = candidateValues(idx);
    if leftThickness(x) > 500
        leftThickness(x:end) = 500;
        break;
    end
end

% Left side of slice
for x = xMid-1:-1:1
    nextIdx = min(xMid, x+windowSize);
    expectedValue = mean(leftThickness(x+1:nextIdx));
    candidateValues = thicknessMatrix(:, x);
    [~, idx] = min(abs(candidateValues - expectedValue));
    leftThickness(x) = candidateValues(idx);
    if leftThickness(x) > 500
        leftThickness(1:x) = 500;
        break;
    end
end

midAnchorX = xMid;

end