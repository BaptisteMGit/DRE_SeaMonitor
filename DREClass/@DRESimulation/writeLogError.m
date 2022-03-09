function writeLogError(obj)
    fileID = fopen(obj.logFile, 'a');
    fprintf(fileID, '\nExecution has failed.');
    fclose(fileID);
    fprintf('Execution has failed.\n')
end
