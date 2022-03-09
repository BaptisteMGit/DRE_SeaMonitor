function writeEnvironment(obj, nameProfile)
    envfile = fullfile(obj.rootOutputFiles, nameProfile);
    promptMsg = sprintf('Writing %s.env', nameProfile);
    fprintf(promptMsg)

    freq = obj.marineMammal.signal.centroidFrequency;
    varEnv = {'envfil', envfile, 'freq', freq, 'SSP', obj.ssp, 'Pos', obj.receiverPos,...
        'Beam', obj.bellhopEnvironment.beam, 'BOTTOM', obj.bottom, 'SspOption', obj.bellhopEnvironment.SspOption, 'TitleEnv', nameProfile};
    writeEnvDRE(varEnv{:})
    linePts = repelem('.', 53 - numel(promptMsg));
    fprintf(' %s DONE\n', linePts);
end