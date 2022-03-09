function writeLogCancel(obj)
    fileID = fopen(obj.logFile, 'a');
    fprintf(fileID, '\nExecution has been canceled by user.');
    fclose(fileID);
    fprintf('Execution has been canceled by user.\n')
end