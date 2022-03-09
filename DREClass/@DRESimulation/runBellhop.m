function runBellhop(obj, nameProfile)
    promptMsg = 'Running Bellhop';
    fprintf(promptMsg)

    cd(obj.rootOutputFiles)
    cmd = sprintf('%s %s', obj.rootToBellhop, nameProfile);
    [status, cmdout] = system(cmd);           
    cd(obj.rootApp)
    
    linePts = repelem('.', 53 - numel(promptMsg));
    fprintf(' %s DONE\n', linePts);
end
