function mainUI()
%mainUI for Detection Range Estimation 
%   Main window containing buttons to configure Detection Range Estimation

%--------------------------------------------------------------------------
%APP INFOS 
%--------------------------------------------------------------------------
% Name 
AppName = "Detection Range Estimation";
% App release version 
AppVersion = 0.1; 

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------
%% Configure figure 
%Size of the current window (PARENT)
width = 300;
height = 400;
% Offsets for all components 
X_offset = width/10;
Y_offset = height/10;
%Centralize the current window at the center of the screen
screensize = get(0,'Screensize'); %get the screen size
screenWidth = screensize(3);
screenHeight = screensize(4);
%Calculate the x and y positions for centralize the window at the screen
posX = (screenWidth/2)-(width/2);
posY = (screenHeight/2)-(height/2);
%Set the figure position argument
figposition = [posX,posY,width,height];

%% Configure button Group
% Dimensions of the button group 
bg_width = width - 2*X_offset;
bg_height = height * 2/3;
% Position 
x_bg = width / 2;
y_bg = height * 1/3 + X_offset;

%--------------------------------------------------------------------------
% DEFINE PROPERTIES BEFORE INSTANCING COMPONENTS
%--------------------------------------------------------------------------
%% Button properties 
% Number of buttons to display
nbButton = 4;
% Define font style
buttonFontSize = 12;
buttonFontName = 'Arial';
% % Dimensions of buttons 
buttonOffset = Y_offset/5; % Offset between buttons
b_width = bg_width - 2*X_offset;
b_height = 1/nbButton * (bg_height - (nbButton + 1) * buttonOffset);
W_1=b_width; H_1=b_height; %WIDTH AND HEIGHT OF BUTTON 1
W_2=b_width; H_2=b_height; %WIDTH AND HEIGHT OF BUTTON 2
W_3=b_width; H_3=b_height; %WIDTH AND HEIGHT OF BUTTON 3
W_4=b_width; H_4=b_height; %WIDTH AND HEIGHT OF BUTTON 4

% Button positions
xb = bg_width/2 - b_width/2;
Y_topButton = bg_height - buttonOffset - b_height;
X_1=xb; Y_1=Y_topButton; %X AND Y POSITIONS OF BUTTON 1
X_2=xb; Y_2=Y_topButton - 1*(b_height + buttonOffset); %X AND Y POSITIONS OF BUTTON 2
X_3=xb; Y_3=Y_topButton - 2*(b_height + buttonOffset); %X AND Y POSITIONS OF BUTTON 3
X_4=xb; Y_4=Y_topButton - 3*(b_height + buttonOffset); %X AND Y POSITIONS OF BUTTON 4

% Generate arrays of sizes 
W_handles=cat(1,W_1,W_2,W_3,W_4);
H_handles=cat(1,H_1,H_2,H_3,H_4);

%% Label properties
labelHeight = 40;
labelWidth = bg_width;
labelOffset = 1/2 * (height - bg_height - labelHeight);
X_label = X_offset;
Y_label = bg_height + Y_offset + labelOffset/2;


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
    'CloseRequestFcn', @closeFigCallback);

set(fig, 'SizeChangedFcn', {@resizeBehavior, width, height, W_handles, H_handles})

bg = uibuttongroup(fig, ...
    'Position', [x_bg - bg_width/2, y_bg - bg_height/2, bg_width, bg_height],...
    'Units', 'normalized');

%--------------------------------------------------------------------------
% CHILD
%--------------------------------------------------------------------------
% Buttons
uibutton(bg, ...
    'Text','Configure Environment',...
    'Position',[X_1, Y_1, W_1, H_1], ...
    'ButtonPushedFcn', @configEnvironmentButtonPushed);

uibutton(bg, ...
    'Text', 'Run DRE',...
    'Position',[X_2, Y_2, W_2, H_2], ...
    'ButtonPushedFcn', @runDREButtonPushed);

uibutton(bg, ...
    'Text','Plotting Tools',...
    'Position',[X_3, Y_3, W_3, H_3], ...
    'ButtonPushedFcn', @plottingToolsButtonPushed);

uibutton(bg, ...
    'Text','Exit App',...
    'Position',[X_4, Y_4, W_4 H_4], ...
    'ButtonPushedFcn', {@exitAppButtonPushed, fig});

% Main label 
uilabel(fig, ....
    'Position', [X_label, Y_label, labelWidth, labelHeight], ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'center', ...
    'Text', sprintf('Detection Range Estimation \nUser-Interface \nVersion %2.1f', AppVersion));


%--------------------------------------------------------------------------
% APP BEHAVIOR 
%--------------------------------------------------------------------------
    function configEnvironmentButtonPushed(src, event)
        configEnvironmentUI()
    end
    
    function runDREButtonPushed(src, event)
    end
    
    function plottingToolsButtonPushed(src, event)
    end

    function exitAppButtonPushed(src, event, f)
        src = f;
        UIcloseFigCallback(src, event)
    end



end

