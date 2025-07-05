function evaporationLoss = solveNomograph(varargin)
%SOLVENOMOGRAPH Compute percent evaporation loss using Frost & Schwalen nomograph.
%   This function accepts name-value pairs for input parameters and returns
%   the estimated evaporation loss.
%
%   Usage:
%     loss = solveNomograph('vpd',0.6,'nozzle',12,'pressure',40,'wind',5);
%
%   Parameters (Name-Value):
%     'vpd'      Vapor-Pressure Deficit (psi) [>=0]
%     'nozzle'   Nozzle diameter (in 64ths of an inch) [positive integer]
%     'pressure' Nozzle pressure (psi) [>0]
%     'wind'     Wind velocity (mph) [>=0]
%
%   Returns:
%     evaporationLoss  Percent evaporation loss (scalar)

    %--- Input Parsing & Validation ---
    p = inputParser;
    addParameter(p,'vpd',0.6,@(x) validateattributes(x,{'numeric'},{'scalar','>=',0}));
    addParameter(p,'nozzle',12,@(x) validateattributes(x,{'numeric'},{'scalar','integer','>=',1}));
    addParameter(p,'pressure',40,@(x) validateattributes(x,{'numeric'},{'scalar','>',0}));
    addParameter(p,'wind',5,@(x) validateattributes(x,{'numeric'},{'scalar','>=',0}));
    parse(p,varargin{:});
    inputs = p.Results;

    % Validate input parameters against physical limitations
    if inputs.vpd < 0.0 || inputs.vpd > 1.0
        error('Vapor-Pressure Deficit must be between 0.0 and 1.0 psi');
    end
    if inputs.nozzle < 8 || inputs.nozzle > 64
        error('Nozzle diameter must be between 8 and 64 (64ths of an inch)');
    end
    if inputs.pressure < 20 || inputs.pressure > 80.1
        error('Nozzle pressure must be between 20 and 80.1 psi');
    end
    if inputs.wind < 0 || inputs.wind > 15
        error('Wind velocity must be between 0 and 15 mph');
    end

    % Define nomograph scale data (exactly as in C++ solver)
    S3 = [0, 0; 0.1, 0.221; 0.2, 0.381; 0.3, 0.508; 0.4, 0.613; 0.5, 0.695; 0.6, 0.762; 0.7, 0.829; 0.8, 0.887; 0.9, 0.949; 1.0, 1.0];
    S5 = [8, 1.002; 10, 0.895; 12, 0.815; 14, 0.742; 16, 0.675; 20, 0.563; 24, 0.483; 32, 0.352; 40, 0.233; 48, 0.152; 64, -0.001];
    S7 = [20, 0.0; 25, 0.159; 30, 0.296; 35, 0.407; 40, 0.499; 45, 0.589; 50, 0.665; 55, 0.735; 60, 0.800; 70, 0.900; 80, 0.996];
    S9 = [0, 0.0; 1, 0.140; 2, 0.246; 3, 0.356; 4, 0.435; 5, 0.508; 6, 0.578; 7, 0.651; 8, 0.706; 9, 0.760; 10, 0.811; 11, 0.854; 12, 0.895; 13, 0.930; 15, 0.994];
    S6 = [0, 0.102; 0.5, 0.252; 1, 0.360; 2, 0.460; 3, 0.521; 4, 0.563; 5, 0.599; 6, 0.633; 8, 0.671; 10, 0.702; 15, 0.758; 20, 0.812; 30, 0.883; 40, 0.917];

    % X coordinates of columns
    x3 = 0.0; x4 = 0.237; x5 = 0.439;
    x6 = 0.490;
    x7 = 0.738; x8 = 0.870; x9 = 1.000;

    % Interpolate Y coordinates
    y3 = safeInterp(S3, inputs.vpd);
    y5 = safeInterp(S5, inputs.nozzle);
    y7 = safeInterp(S7, inputs.pressure);
    y9 = safeInterp(S9, inputs.wind);

    % Compute pivot points A and B
    yA = linearBetween(x4, x3, y3, x5, y5);
    yB = linearBetween(x8, x7, y7, x9, y9);

    % Intersect at column 6
    yL = linearBetween(x6, x4, yA, x8, yB);

    % Reverse interpolation on S6 (flip x/y for reverse lookup)
    S6_flip = [S6(:,2), S6(:,1)];  % Swap columns
    S6_flip = sortrows(S6_flip, 1);  % Sort by y-values
    
    evaporationLoss = safeInterp(S6_flip, yL);

    % Validate output against physical limitations
    if evaporationLoss < 0.0 || evaporationLoss > 40.0
        fprintf('Warning: Calculated evaporation loss (%.1f%%) is outside expected range (0-40%%)\n', evaporationLoss);
    end
end

% Linear interpolation between two points
function y = linearBetween(x, x1, y1, x2, y2)
    slope = (y2 - y1) / (x2 - x1);
    y = y1 + slope * (x - x1);
end

% Safe interpolation helper function
function vq = safeInterp(table, xq)
    % table: [x, y] pairs for interpolation
    xs = table(:,1);
    ys = table(:,2);
    
    % Handle boundary cases
    if xq <= xs(1)
        vq = ys(1);
        return;
    end
    if xq >= xs(end)
        vq = ys(end);
        return;
    end
    
    % Linear interpolation
    vq = interp1(xs, ys, xq, 'linear');
end
