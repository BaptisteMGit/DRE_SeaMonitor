function writeLogCancelAfterConnectionFailed(obj)
    fileID = fopen(obj.logFile, 'a');
    fprintf(fileID, 'Execution canceled after connection to CMEMS failed.');
    fclose(fileID);
    fprintf('\nExecution canceled by user after connection to CMEMS failed.\n')
end

