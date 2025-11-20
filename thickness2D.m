function [leftThickness, midAnchorX, midAnchorThickness] = thickness2D()

% Select and load image
[filename, pathname] = uigetfile({'*.bmp;*.png;*.jpg;*.tif','Image Files (*.bmp, *.png, *.jpg, *.tif)'}, 'Select an image file');
img = imread(fullfile(pathname, filename));
imgSize = size(img);

% Check image size
imCrit = 500;
if any(imgSize(1:2) < imCrit)
    warning('One or more image dimensions are smaller than %d pixels. The image may be too small for reliable processing.', imCrit);
end

% Select horizontal line and anchor point
figure(1); imshow(img); hold on;
figPos = get(gcf,'Position'); figPos(1) = 50; figPos(2) = 300;                   
set(gcf,'Position', figPos);       
title('Select center line and center of contact');
[x_click, y_click] = ginput(1);  
midAnchorX = round(x_click);
midAnchorY = round(y_click);  
plot([1 imgSize(2)], [midAnchorY midAnchorY], 'w:', 'LineWidth', 4);
plot(midAnchorX, midAnchorY, 'ro', 'MarkerFaceColor','r','MarkerEdgeColor','w','MarkerSize', 10, 'LineWidth', 2);
hold off;

% Extract colors and thickness
R = double(img(midAnchorY, :, 1));
G = double(img(midAnchorY, :, 2));
B = double(img(midAnchorY, :, 3));              
RGB_row = cat(3, R/255, G/255, B/255); 
HSV_row = rgb2hsv(RGB_row);
hsvImg = rgb2hsv(img);
hue_angle = hsvImg(midAnchorY, midAnchorX, 1) * 360;
[thickness_N1, thickness_N2, thickness_N3] = hueToThickness(hue_angle);
thicknessValues = [thickness_N1; thickness_N2; thickness_N3]; 

% buttons for thickness selection
thicknessOptions = thicknessValues(:,1);
numOptions = length(thicknessOptions);
bg = uibuttongroup('Parent', gcf, 'Title','Select thickness for center of contact', 'Position',[0.05 0.01 0.9 0.08], 'FontWeight', 'bold'); 

btnHandles = gobjects(numOptions,1);
for k = 1:numOptions
    xNorm = (k-1)/numOptions;  
    btnHandles(k) = uicontrol('Parent', bg, 'Style','pushbutton', 'String', sprintf('%.1f nm', thicknessOptions(k)), ...
        'Units','normalized', 'Position',[xNorm 0 1/numOptions 1], 'FontWeight', 'bold', 'FontSize', 10, 'Callback', @(src,event) assignThickness(src));
end

uiwait(gcf); % wait until thickness selected
midAnchorThickness = evalin('base','hAnchors'); % retrieve user selection

% hue-to-thickness for line
numPixels = size(img,2);
thicknessMatrix = zeros(3, numPixels);
for x = 1:numPixels
    hue_angle = HSV_row(1, x, 1) * 360;
    [th1, th2, th3] = hueToThickness(hue_angle);
    thicknessMatrix(:, x) = [th1; th2; th3];
end

%% Thickness determination from middle anchor
windowSize = 5; 
hsp = 150; 
hspLine = hsp * ones(1, numPixels);

selectedThickness = zeros(1, numPixels);
selectedThickness(1:midAnchorX-1) = NaN;
selectedThickness(midAnchorX) = midAnchorThickness;
maxThickness = midAnchorThickness + 100; 

% Right side
for x = midAnchorX+1:numPixels
    prevIdx = max(midAnchorX, x-windowSize);
    expectedValue = mean(selectedThickness(prevIdx:x-1));
    candidateValues = thicknessMatrix(:, x);
    [~, idx] = min(abs(candidateValues - expectedValue));
    selectedThickness(x) = candidateValues(idx);
    if selectedThickness(x) > maxThickness
        selectedThickness(x:end) = maxThickness;
        break;
    end
end

% Left side
leftThickness = selectedThickness;
for x = midAnchorX-1:-1:1
    nextIdx = min(midAnchorX, x+windowSize);
    expectedValue = mean(leftThickness(x+1:nextIdx));
    candidateValues = thicknessMatrix(:, x);
    [~, idx] = min(abs(candidateValues - expectedValue));
    leftThickness(x) = candidateValues(idx);
    if leftThickness(x) > maxThickness
        leftThickness(1:x) = maxThickness;
        break;
    end
end

% Plot thickness
figure(2); hold on;
figPos = get(gcf,'Position'); figPos(1) = 1000; figPos(2) = 300;                    
set(gcf,'Position', figPos);

%p1 = plot(1:numPixels, hspLine, '--','Color', '#808080', 'LineWidth', 2); 
p2 = plot(1:numPixels, leftThickness, 'Color','#0072BD', 'LineWidth', 2);
%p3 = plot(midAnchorX, midAnchorThickness, 'ro', 'MarkerFaceColor','r','MarkerSize', 8);

xlabel('Pixel location (x)');
ylabel('Thickness (nm)');
title('Pixel thickness from image');
set(gca,'YDir','reverse'); 
axis([1 numPixels midAnchorThickness-100 maxThickness])

% Legend (unchanged)
legHandles = [];
legText = {};

if exist('p1','var') && isgraphics(p1)
    legHandles(end+1) = p1;
    legText{end+1} = 'h_{sp}';
end

if exist('p2','var') && isgraphics(p2)
    legHandles(end+1) = p2;
    legText{end+1} = 'h_{contact}';
end

if exist('p3','var') && isgraphics(p3)
    legHandles(end+1) = p3;
    legText{end+1} = 'anchor point';
end

legend(legHandles, legText);

end
