function writeBtyFile(obj, nameProfile, bathyProfile)
    BTYfilename = sprintf('%s.bty', nameProfile);
    promptMsg = sprintf('Writing %s', BTYfilename);
    fprintf(promptMsg)
    
    writebdry(fullfile(obj.rootOutputFiles, BTYfilename), obj.bellhopEnvironment.interpMethodBTY, bathyProfile)
    linePts = repelem('.', 53 - numel(promptMsg));
    fprintf(' %s DONE\n', linePts);
end
