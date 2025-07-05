% runTest.m - Simple test runner
fprintf('=== MATLAB/Octave Sprinkler Evaporation Loss Test Report ===\n');
fprintf('Date: %s\n', datestr(now));
fprintf('Environment: Octave %s\n', version);
fprintf('\n');

try
    % Run the test script
    testNomograph;
    fprintf('\n=== Test Execution Completed ===\n');
catch e
    fprintf('ERROR: %s\n', e.message);
    if isfield(e, 'stack') && ~isempty(e.stack)
        fprintf('At line: %d in file: %s\n', e.stack(1).line, e.stack(1).file);
    end
end
