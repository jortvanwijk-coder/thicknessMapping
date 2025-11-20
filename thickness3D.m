function thicknessMap3D = thickness3D()

% Load image
[filename, pathname] = uigetfile({'*.bmp;*.png;*.jpg;*.tif','Image Files'}, 'Select an image file');
img = imread(fullfile(pathname, filename));
hsvImg = rgb2hsv(img);
imgSize = size(img);
rows = imgSize(1);
cols = imgSize(2);

% Check image size
imCrit = 500;
if any(imgSize(1:2) < imCrit)
    warning('One or more image dimensions are smaller than %d pixels. The image may be too small for reliable processing.', imCrit);
end

% Select the central point
figure(1); imshow(img); hold on;
figPos = get(gcf,'Position'); figPos(1) = 50; figPos(2) = 300;                   
set(gcf,'Position', figPos); 
title('Select the central (known) thickness point');
[xc, yc] = ginput(1);
xc = round(xc); yc = round(yc);
plot(xc, yc, 'ro', 'MarkerFaceColor','r','MarkerEdgeColor','w','MarkerSize', 10, 'LineWidth', 2);

% Select and plot three points for the circle
title('Select three points to create circle boundary'); hold on;
[x1,y1] = ginput(1);plot(x1, y1, 'go', 'MarkerFaceColor','g','MarkerEdgeColor','w','MarkerSize', 8, 'LineWidth', 2);
[x2,y2] = ginput(1);plot(x2, y2, 'go', 'MarkerFaceColor','g','MarkerEdgeColor','w','MarkerSize', 8, 'LineWidth', 2);
[x3,y3] = ginput(1);plot(x3, y3, 'go', 'MarkerFaceColor','g','MarkerEdgeColor','w','MarkerSize', 8, 'LineWidth', 2);

% Fit and plot the circle
A = [x1 y1 1; x2 y2 1; x3 y3 1];
D = -[x1^2 + y1^2; x2^2 + y2^2; x3^2 + y3^2];
params = A\D;
x_center = -params(1)/2;
y_center = -params(2)/2;
radius = sqrt((params(1)^2 + params(2)^2)/4 - params(3));
theta = linspace(0, 2*pi, 200);
circX = x_center + radius*cos(theta);
circY = y_center + radius*sin(theta);
plot(circX, circY, 'g-', 'LineWidth', 2);
hold off;

% Thickness selection buttons
hue_angle = hsvImg(yc, xc, 1) * 360; tic;
[t1, t2, t3] = hueToThickness(hue_angle);
thicknessOptions = [t1; t2; t3];

bg = uibuttongroup('Parent', gcf, 'Title','Select central thickness','Position',[0.05 0.01 0.9 0.08], 'FontWeight', 'bold');
numOptions = length(thicknessOptions);
for k = 1:numOptions
    xNorm = (k-1)/numOptions;
    uicontrol('Parent', bg, 'Style','pushbutton','String',sprintf('%.1f nm', thicknessOptions(k)), ...
        'Units','normalized','Position',[xNorm 0 1/numOptions 1], 'FontWeight', 'bold', 'FontSize', 10, 'Callback', @(src,event) assignThickness(src));
end
uiwait(gcf);
centralThickness = evalin('base','hAnchors');

% Prepare thickness map
thicknessMap3D = NaN(rows, cols);

% Slices inside the circle
[yGrid, xGrid] = ndgrid(1:rows, 1:cols);
insideMask = ((xGrid - x_center).^2 + (yGrid - y_center).^2) <= radius^2;

% Central slice (y = yc)
[leftTh_central, ~, selectedCentral] = thickness2D_singleSlice(img, yc, xc, centralThickness);
thicknessMap3D(yc, :) = leftTh_central;

% Process slices above and below
prevThickness = selectedCentral;
for y = yc-1:-1:1
    if ~any(insideMask(y,:)), break; end
    [thRow, ~, newPick] = thickness2D_singleSlice(img, y, xc, prevThickness);
    thicknessMap3D(y,:) = thRow;
    prevThickness = newPick;
end
prevThickness = selectedCentral;
for y = yc+1:rows
    if ~any(insideMask(y,:)), break; end
    [thRow, ~, newPick] = thickness2D_singleSlice(img, y, xc, prevThickness);
    thicknessMap3D(y,:) = thRow;
    prevThickness = newPick;
end

% Cap inside-circle values
capValue = centralThickness + 100;
thicknessMap3D(insideMask) = min(thicknessMap3D(insideMask), capValue);

% Outside-circle values
thicknessMap3D(~insideMask) = NaN;

%% Plot 3D map
figure; hold on; 
figPos = get(gcf,'Position'); figPos(1) = 1000; figPos(2) = 300;                    
set(gcf,'Position', figPos);
surf(thicknessMap3D, 'EdgeColor','none'); colormap(flipud(turbo)); colorbar;
xlabel('X'); ylabel('Y'); zlabel('Thickness (nm)'); 
set(gca,'ZDir','reverse'); set(gca,'XDir','reverse');set(colorbar, 'YDir', 'reverse');  
%contour3(thicknessMap3D,10, '-k', 'LineWidth',1.5)   
view(135,25);
axis equal; % keep x and y pixel scales identical
title('3D map of the contact');

% Timer
elapsedTime = toc;  % time in seconds
fprintf('Elapsed time from thickness selection to plot was: %.2f seconds.\n', elapsedTime);
end




