function writeDRtoLogFile(obj, theta, DR)
    fileID = fopen(obj.logFile, 'a');
    fprintf(fileID, '\t%3.2f\t%6.0f\n', theta, DR);
    fclose(fileID);
end