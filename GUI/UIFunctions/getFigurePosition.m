function fPosition = getFigurePosition(app)
    %Centralize the current window at the center of the screen
    screensize = get(0,'Screensize'); %get the screen size
    screenWidth = screensize(3);
    screenHeight = screensize(4);
    %Calculate the x and y positions for centralize the window at the screen
    posX = (screenWidth/2)-(app.width/2);
    posY = (screenHeight/2)-(app.height/2);
    %Set the figure position argument
    fPosition = [posX, posY, app.width, app.height];
end