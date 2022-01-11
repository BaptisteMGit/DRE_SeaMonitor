function configEnvironmentUI()
%configEnvironmentUI 
%   Sub-window usefull to configure simulation environment 
%   

%% Configure figure 
%Centralize the current window at the center of the screen
screensize = get(0,'Screensize'); %get the screen size
screenWidth = screensize(3);
screenHeight = screensize(4);
%Calculate the x and y positions for centralize the window at the screen
posX = (screenWidth/2)-(width/2);
posY = (screenHeight/2)-(height/2);
%Set the figure position argument
figposition = [posX, posY, screenWidth, screenHeight];

%--------------------------------------------------------------------------
% PARENT
%--------------------------------------------------------------------------
% Figure
fig = uifigure('Name', AppName, ...
    'Visible', 'on', ...
    'NumberTitle', 'off', ...
    'Position', figposition, ...
    'Toolbar', 'none', ...
    'MenuBar', 'none', ...
    'Resize', 'on', ...
    'AutoResizeChildren', 'off', ...
    'WindowStyle', 'normal', ...
    'CloseRequestFcn', UIcloseFigCallback);

end 
