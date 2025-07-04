% MATLAB script to calculate sprinkler evaporation loss based on the
% Frost and Schwalen nomograph geometry, with added visualization.

% --- Define Input Parameters ---
% These can be changed to solve for different conditions.
inputs.vpd = 0.6;      % Vapor-Pressure Deficit (psi)
inputs.nozzle = 12;    % Nozzle Diameter (in 64ths of an inch)
inputs.pressure = 40;  % Nozzle Pressure (psi)
inputs.wind = 5;       % Wind Velocity (mph)

% --- Define Nomograph Geometry and Scales ---
% This data is derived from the interactive HTML nomograph's structure.
% Each scale has an x-position and a set of [value, y_coordinate] ticks.

scales = struct();
scales.S3.label = 'VAPOR-PRESS. DEFICIT'; 
scales.S3.x = 0;
scales.S3.ticks = [0, 0; 0.1, 0.221; 0.2, 0.381; 0.3, 0.508; 0.4, 0.613; 0.5, 0.695; 0.6, 0.762; 0.7, 0.829; 0.8, 0.887; 0.9, 0.949; 1.0, 1.000];

scales.S4.label = 'PIVOT A'; 
scales.S4.x = 0.237;

scales.S5.label = 'NOZZLE DIA. (64th IN)'; 
scales.S5.x = 0.439;
scales.S5.ticks = [8, 1.002; 10, 0.895; 12, 0.815; 14, 0.742; 16, 0.675; 20, 0.563; 24, 0.483; 32, 0.352; 40, 0.233; 48, 0.152; 64, -0.001];

scales.S6.label = '% EVAPORATION LOSS'; 
scales.S6.x = 0.490;
scales.S6.ticks = [0, 0.102; 0.5, 0.252; 1, 0.360; 2, 0.460; 3, 0.521; 4, 0.563; 5, 0.599; 6, 0.633; 8, 0.671; 10, 0.702; 15, 0.758; 20, 0.812; 30, 0.883; 40, 0.917];

scales.S7.label = 'NOZZLE PRESS. PSI'; 
scales.S7.x = 0.738;
scales.S7.ticks = [20, 0.000; 25, 0.159; 30, 0.296; 35, 0.407; 40, 0.499; 45, 0.589; 50, 0.665; 55, 0.735; 60, 0.800; 70, 0.900; 80, 0.996];

scales.S8.label = 'PIVOT B'; 
scales.S8.x = 0.870;

scales.S9.label = 'WIND VELOCITY, MPH'; 
scales.S9.x = 1.000;
scales.S9.ticks = [0, 0.000; 1, 0.140; 2, 0.246; 3, 0.356; 4, 0.435; 5, 0.508; 6, 0.578; 7, 0.651; 8, 0.706; 9, 0.760; 10, 0.811; 11, 0.854; 12, 0.895; 13, 0.930; 15, 0.994];

% --- Step 1: Get Y-coordinates for input values ---
y_vpd = interp1(scales.S3.ticks(:,1), scales.S3.ticks(:,2), inputs.vpd, 'linear', 'extrap');
y_nozzle = interp1(scales.S5.ticks(:,1), scales.S5.ticks(:,2), inputs.nozzle, 'linear', 'extrap');
y_pressure = interp1(scales.S7.ticks(:,1), scales.S7.ticks(:,2), inputs.pressure, 'linear', 'extrap');
y_wind = interp1(scales.S9.ticks(:,1), scales.S9.ticks(:,2), inputs.wind, 'linear', 'extrap');

P3 = [scales.S3.x, y_vpd];
P5 = [scales.S5.x, y_nozzle];
P7 = [scales.S7.x, y_pressure];
P9 = [scales.S9.x, y_wind];

% --- Step 2: Calculate Pivot Point A on Column 4 ---
m_A = (P5(2) - P3(2)) / (P5(1) - P3(1));
y_A = m_A * (scales.S4.x - P3(1)) + P3(2);
PA = [scales.S4.x, y_A];

% --- Step 3: Calculate Pivot Point B on Column 8 ---
m_B = (P9(2) - P7(2)) / (P9(1) - P7(1));
y_B = m_B * (scales.S8.x - P7(1)) + P7(2);
PB = [scales.S8.x, y_B];

% --- Step 4: Calculate Intersection on Loss Column 6 ---
m_Loss = (PB(2) - PA(2)) / (PB(1) - PA(1));
y_Loss = m_Loss * (scales.S6.x - PA(1)) + PA(2);
P_Loss = [scales.S6.x, y_Loss];

% --- Step 5: Convert Y-coordinate back to a value ---
evaporationLoss = interp1(scales.S6.ticks(:,2), scales.S6.ticks(:,1), y_Loss, 'linear', 'extrap');

% --- Step 6: Display the results in the Console ---
fprintf('--- Nomograph Calculation ---\n');
fprintf('Input VPD: %.2f psi\n', inputs.vpd);
fprintf('Input Nozzle Diameter: %d/64 in\n', inputs.nozzle);
fprintf('Input Pressure: %d psi\n', inputs.pressure);
fprintf('Input Wind: %d mph\n\n', inputs.wind);
fprintf('Calculated Y on Pivot A (Col 4): %.3f\n', y_A);
fprintf('Calculated Y on Pivot B (Col 8): %.3f\n', y_B);
fprintf('Calculated Y on Loss (Col 6):   %.3f\n\n', y_Loss);
fprintf('>>> Final Result <<<\n');
fprintf('Percent Evaporation Loss: %.1f%%\n', evaporationLoss);

% --- Step 7: Visualization and Validation ---
figure('Name', 'Nomograph Visualization', 'Position', [100, 100, 1000, 600]);
hold on;
grid on;

% Plot all scales and their ticks
all_scales = fieldnames(scales);
for i = 1:length(all_scales)
    s = scales.(all_scales{i});
    plot([s.x, s.x], [0, 1], 'k-', 'LineWidth', 1.5);
    if isfield(s, 'ticks')
        for j = 1:size(s.ticks, 1)
            plot(s.x, s.ticks(j,2), 'k+');
            text(s.x + 0.01, s.ticks(j,2), num2str(s.ticks(j,1)));
        end
    end
    text(s.x, 1.05, s.label, 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
end

% Plot the construction lines
plot([P3(1), P5(1)], [P3(2), P5(2)], 'r--');
plot([P7(1), P9(1)], [P7(2), P9(2)], 'b--');
plot([PA(1), PB(1)], [PA(2), PB(2)], 'g-', 'LineWidth', 2);

% Plot the points
plot(P3(1), P3(2), 'ro', 'MarkerFaceColor', 'r');
plot(P5(1), P5(2), 'ro', 'MarkerFaceColor', 'r');
plot(P7(1), P7(2), 'bo', 'MarkerFaceColor', 'b');
plot(P9(1), P9(2), 'bo', 'MarkerFaceColor', 'b');
plot(PA(1), PA(2), 'rs', 'MarkerFaceColor', 'r', 'MarkerSize', 10);
plot(PB(1), PB(2), 'bs', 'MarkerFaceColor', 'b', 'MarkerSize', 10);
plot(P_Loss(1), P_Loss(2), 'gd', 'MarkerFaceColor', 'g', 'MarkerSize', 12);

hold off;
axis([-0.1, 1.1, -0.1, 1.2]);
title('Visual Validation of Nomograph Calculation');
xlabel('Normalized X-Position');
ylabel('Normalized Y-Position');

% Save the figure as a PNG
saveas(gcf, 'nomograph_visualization.png');
