function createCalibPlot(hue_angle)
    % Function to create the calibration plot
    %   createCalibPlot()             -> plots curves only
    %   createCalibPlot(hue_angle)    -> plots curves and marks the specified hue
    
    % Optionality to request with and without hue
    if nargin < 1
        hue_angle = [];  
    end

    figure;
    hold on;
    grid on;

    calMatrix = getCalibrationMatrix();

    % Extract thickness data
    N1 = calMatrix(:, 5)';  % 1st interference order
    N2 = calMatrix(:, 6)';  % 2nd interference order
    N3 = calMatrix(:, 7)';  % 3rd interference order

    % Extract hue from RGB in calMatrix
    RGB_values = calMatrix(:, 2:4);
    HSV_values = rgb2hsv(RGB_values);
    hue_values = HSV_values(:,1) * 360; 
    hue = [hue_values', 360]; % Add angle 360 for extrapolation

    % Extrapolate thickness values to 360°
    exN1 = interp1([0 240], [calMatrix(1,5) calMatrix(5,5)], 360, 'linear', 'extrap');
    exN2 = calMatrix(1,5);  % corrected from original N2
    exN3 = calMatrix(1,6);  % corrected from original N3

    % Extended thickness arrays
    N1_extended = [N1, exN1];
    N2_extended = [N2, exN2];
    N3_extended = [N3, exN3];

    % Horizontal hue color bar (0–360°)
    transparency = 0.2; % 0 = fully transparent, 1 = opaque
    hueVals = linspace(0, 360, 1000);
    rgbVals = hsv2rgb([hueVals'/360, ones(numel(hueVals),1), ones(numel(hueVals),1)]);
    img = repmat(permute(rgbVals, [3 1 2]), 20, 1, 1);
    yPos = [0 100]; % height for color bar (nm)
    hImg = image([0 360], yPos, img);
    alpha(hImg, transparency); 
    uistack(hImg, 'bottom'); 

    % Plot calibration curves
    p1 = plot(hue, N1_extended, 'b-o', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', '1st Order');
    p2 = plot(hue, N2_extended, 'r-s', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', '2nd Order'); 
    p3 = plot(hue, N3_extended, 'g-^', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', '3rd Order');

    % Optional plots for time hue angle is specified
    if ~isempty(hue_angle)
        curr_N1 = interp1(hue, N1_extended, hue_angle, 'linear');
        curr_N2 = interp1(hue, N2_extended, hue_angle, 'linear');
        curr_N3 = interp1(hue, N3_extended, hue_angle, 'linear');
        
        plot(hue_angle, curr_N1, 'ko', 'MarkerFaceColor','b', 'MarkerEdgeColor','k','MarkerSize', 8, 'LineWidth', 2);
        plot(hue_angle, curr_N2, 'ko', 'MarkerFaceColor','r', 'MarkerEdgeColor','k','MarkerSize', 8, 'LineWidth', 2);
        plot(hue_angle, curr_N3, 'ko', 'MarkerFaceColor','g', 'MarkerEdgeColor','k','MarkerSize', 8, 'LineWidth', 2);

        % Add text labels
        text(hue_angle, curr_N1, sprintf('  %.1f nm', curr_N1), 'VerticalAlignment','bottom', 'Color','k', 'FontWeight','bold', 'FontSize',12);
        text(hue_angle, curr_N2, sprintf('  %.1f nm', curr_N2), 'VerticalAlignment','bottom', 'Color','k', 'FontWeight','bold', 'FontSize',12);
        text(hue_angle, curr_N3, sprintf('  %.1f nm', curr_N3), 'VerticalAlignment','bottom', 'Color','k', 'FontWeight','bold', 'FontSize',12);

        % Plot x-line
        xline(hue_angle, 'k:','LineWidth', 2, 'DisplayName', 'Hue angle')
        text(hue_angle, 20, sprintf('  Hue = %.1f^o', hue_angle), 'VerticalAlignment','bottom', 'Color','k', 'FontWeight','bold', 'FontSize',10);
    end

    % Configure axes
    i = 7;  % number of x ticks
    j = 10; % number of y ticks
    set(gca, ...
        'XTick', linspace(0, 360, i), ...
        'XTickLabel', round(linspace(0, 360, i)), ...
        'YTick', linspace(0, 900, j), ...
        'YTickLabel', round(linspace(0, 900, j)) );

    xlabel('Hue (deg)', 'FontSize', 12);
    ylabel('Film Thickness (nm)', 'FontSize', 12);
    title('Film thickness per hue angle (n=1,2,3)', 'FontSize', 14);
    legend([p1 p2 p3],'1st order','2nd order', '3rd order') 

    xlim([min(hue) 360]);
    ylim([0 ceil(max(N3_extended)/100)*100]);

    % Optional: plot mapper calibration.txt. Make sure file is in the same
    % folder.
    %     data = readmatrix('mapper_calibration.txt');
    %     RGB = data(:, 2:4)/255;
    %     HSV = rgb2hsv(RGB);
    %     hue = HSV(:, 1) * 360;
    %     c = linspace(1,10,length(hue));
    %     scatter(hue, data(:, 1), [],c)

    hold off;
end
