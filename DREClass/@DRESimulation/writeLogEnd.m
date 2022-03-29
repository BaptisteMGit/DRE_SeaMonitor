function writeLogEnd(obj)
    fileID = fopen(obj.logFile, 'a');
    fprintf(fileID, '\nCPU Time = %6.2f s', obj.CPUtime);
    fclose(fileID);
    fprintf('CPU Time = %6.2f s', obj.CPUtime)
end
