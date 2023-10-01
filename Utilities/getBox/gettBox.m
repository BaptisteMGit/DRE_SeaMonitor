function tBox = gettBox(startDate, stopDate)
    full_startDate = sprintf('%s 00:00:00', startDate); 
    tBox.startDate = datetime(full_startDate, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
    full_stopDate = sprintf('%s 23:59:59', stopDate); 
    tBox.stopDate = datetime(full_stopDate, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
end