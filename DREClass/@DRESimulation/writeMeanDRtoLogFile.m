function writeMeanDRtoLogFile(obj)
    fileID = fopen(obj.logFile, 'a');
    fprintf(fileID, '\nMean detection range = %6.0f m', obj.meanDR);
    fclose(fileID);
end
