function writeMaxDRtoLogFile(obj)
    fileID = fopen(obj.logFile, 'a');
    fprintf(fileID, '\nMax detection range = %6.0f m', obj.maxDR);
    fclose(fileID);
end
