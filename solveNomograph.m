function evaporationLoss = solveNomograph(varargin)
%SOLVENOMOGRAPH Compute percent evaporation loss using Frost & Schwalen nomograph.
%   This function accepts name-value pairs for input parameters and returns
the estimated evaporation loss.
%
%   Usage:
%     loss = solveNomograph('vpd',0.6,'nozzle',12,'pressure',40,'wind',5);
%
%   Parameters (Name-Value):
%     'vpd'      Vapor-Pressure Deficit (psi) [>=0]
%     'nozzle'   Nozzle diameter (in 64ths of an inch) [positive integer]
%     'pressure' Nozzle pressure (psi) [>0]
%     'wind'     Wind velocity (mph) a[>=0]
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

    %--- Define Nomograph Scales (persistent) ---
    persistent scales
    if isempty(scales)
        scales = struct();
        scales.S3.x = 0;  scales.S3.ticks = [0,0;0.1,0.221;0.2,0.381;0.3,0.508;0.4,0.613;0.5,0.695;0.6,0.762;0.7,0.829;0.8,0.887;0.9,0.949;1,1.000];
        scales.S4.x = 0.237;
        scales.S5.x = 0.439; scales.S5.ticks = [8,1.002;10,0.895;12,0.815;14,0.742;16,0.675;20,0.563;24,0.483;32,0.352;40,0.233;48,0.152;64,-0.001];
        scales.S6.x = 0.490; scales.S6.ticks = [0,0.102;0.5,0.252;1,0.360;2,0.460;3,0.521;4,0.563;5,0.599;6,0.633;8,0.671;10,0.702;15,0.758;20,0.812;30,0.883;40,0.917];
        scales.S7.x = 0.738; scales.S7.ticks = [20,0;25,0.159;30,0.296;35,0.407;40,0.499;45,0.589;50,0.665;55,0.735;60,0.800;70,0.900;80,0.996];
        scales.S8.x = 0.870;
        scales.S9.x = 1.000; scales.S9.ticks = [0,0;1,0.140;2,0.246;3,0.356;4,0.435;5,0.508;6,0.578;7,0.651;8,0.706;9,0.760;10,0.811;11,0.854;12,0.895;13,0.930;15,0.994];
    end

    %--- Interpolate y-coordinates in a safe manner ---
    y3 = safeInterp(scales.S3.ticks, inputs.vpd);
    y5 = safeInterp(scales.S5.ticks, inputs.nozzle);
    y7 = safeInterp(scales.S7.ticks, inputs.pressure);
    y9 = safeInterp(scales.S9.ticks, inputs.wind);

    P3 = [scales.S3.x, y3];
    P5 = [scales.S5.x, y5];
    P7 = [scales.S7.x, y7];
    P9 = [scales.S9.x, y9];

    %--- Compute pivot points ---
    yA = linInterp(P3, P5, scales.S4.x);
    yB = linInterp(P7, P9, scales.S8.x);

    %--- Intersection on loss scale ---
    mLine = (yB - yA) / (scales.S8.x - scales.S4.x);
    yL    = yA + mLine * (scales.S6.x - scales.S4.x);

    %--- Map back to percent loss ---
    evaporationLoss = safeInterp(flipud(scales.S6.ticks), yL);

    %--- Optional: display ---
    fprintf('%% Evaporation Loss: %.1f%%\n', evaporationLoss);
end

%--- Helper: linear interpolation along nomograph ---
function y = linInterp(P1, P2, xq)
    m = (P2(2) - P1(2)) / (P2(1) - P1(1));
    y = P1(2) + m * (xq - P1(1));
end

%--- Helper: safe interp with sorted data ---
function vq = safeInterp(table, xq)
    % table: [x, y] or [y, x] depending on context
    xs = table(:,1);
    ys = table(:,2);
    % ensure monotonic xs
    [xs, idx] = sort(xs);
    ys = ys(idx);
    vq = interp1(xs, ys, xq, 'linear', 'extrap');
end
