% Single test case
try
    loss = solveNomograph('vpd',0.406,'nozzle',8,'pressure',30.02,'wind',2.91);
    fprintf('Single test result: %.3f%%\n', loss);
catch ME
    fprintf('Error: %s\n', ME.message);
end
