%% Run test case 1 (1a and 1b) 

% Testcase 1b 
app = AppDRE(SpermWhaleDemo);
app.Simulation.runSimulation()

% Testcase 1a
app = AppDRE(TestCase1_ArtificialPorpoise);
app.Simulation.runSimulation()

