%% Launch DRE app 
% context = 'dev'; % 'dev', 'prod' : use 'prod' context when deploying app 

% if ~isdeployed
% %         app = AppDRE(TestCase1_RecordedPorpoise);
%         app = AppDRE(TestCase1_ArtificialPorpoise);
% else
%         app = AppDRE;
% end

app = AppDRE(TestCase1_ArtificialPorpoise);

