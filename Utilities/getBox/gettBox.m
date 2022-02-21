function tBox = gettBox(startDate, stopDate)
%     tBox.startDate = startDate;
%     tBox.stopDate = stopDate;
    
    % Fix 21/02/2022 
    % Switch to datetime objects for more features (comparing dates) 
    % Drop hh-mm-ss details which leads to downloading issues and don't
    % bring anything to the model as the physical propreties studied are
    % assumed to be variying slowly (T, S, pH° 
    tBox.startDate = datetime(startDate, 'InputFormat','yyyy-MM-dd');
    tBox.stopDate = datetime(stopDate, 'InputFormat','yyyy-MM-dd');
end