%% Launch DRE app 
context = 'dev'; % 'dev', 'prod' : use 'prod' context when deploying app 

switch context
    case 'dev'
%         app = AppDRE(TestCase1_RecordedPorpoise);
        app = AppDRE(TestCase1_ArtificialPorpoise);
    case 'prod'
        app = AppDRE;
end


