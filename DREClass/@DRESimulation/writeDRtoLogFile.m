function writeDRtoLogFile(obj, theta, DT)
    fileID = fopen(obj.logFile, 'a');
    fprintf(fileID, '\t%3.2f\t%6.2f\n', theta, DT);
    fclose(fileID);
    fprintf('Bearing(°), Detection range (m): %3.2f, %6.2f\n', theta, DT);
end