%% Launch DRE app 
context = 'dev'; % 'dev', 'prod' : use 'prod' context when deploying app 

switch context
    case 'dev'
        cd ('C:\Users\33686\MATLAB\Projects\SeaMonitor\DRE_SeaMonitor\GUI\App') % To be removed for standalone app 
        app = AppDRE(TestCase1);
    case 'prod'
        app = AppDRE;
end


