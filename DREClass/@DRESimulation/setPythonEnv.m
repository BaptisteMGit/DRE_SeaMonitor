function setPythonEnv(obj)
%SETPYTHONENV Set required python configuration
%   Check if python is installed
%   Check if pip is installed and install it in case not 
%   Check if motuclient module is installed and install it in case not 

promptMsg = 'Checking python configuration';
fprintf(promptMsg)

%% Assert python is unstalled 
cmd = 'python --version';
[status, cmdout] = system(cmd); 
assert(status==0, 'Python not found. Please check PATH variable or consider installing Python.')

% Assert version is supported 
% Minimum version is 2.7.9 according to Copernicus 
% https://help.marine.copernicus.eu/en/articles/4796533-what-are-the-motu-client-motuclient-and-python-requirements
cmdout = split(cmdout, ' ');
version = cmdout(2);
version = split(version, '.');
if numel(version) <= 2
    v = str2double(sprintf('%s.%s', version{1}, version{2})); 
    versionMsg = [sprintf('This script does not work on Python %s.%s.\n', version{1}, version{2}), ...
            'The minimum supported Python version is 2.7.9']; 
    cond = (v >= 2.79);
else 
    num3 = str2double(version{3});
    v = str2double(sprintf('%s.%s', version{1}, version{2})); 
    if num3 < 10
        v = v + num3 * 0.01; 
        cond = (v >= 2.79);
    else 
        cond = (v >= 2.7);
    end
    versionMsg = [sprintf('This script does not work on Python %s.%s.%s.\n', version{1}, version{2}, version{3}), ...
            'The minimum supported Python version is 2.7.9\n']; 
end 
assert(cond, versionMsg)


%% Assert pip is installed 
cmd = 'pip --version';
[status, cmdout] = system(cmd);

if ~(status==0)
    % Install pip 
    cd(obj.rootPythonModules)

    % Dowload get-pip.py file using bootstrap 
    if (v >= 3.7) % Installed version is greater than 3.7 
        fullURL = 'https://bootstrap.pypa.io/get-pip.py';
    else % User uses previous version of python
        fullURL = sprintf('https://bootstrap.pypa.io/pip/%.0f.%.0f/get-pip.py', str2double(version{1}), str2double(version{2}));
    end
    filename = 'get-pip.py';
    websave(filename, fullURL);

    fprintf('\n-> Installing pip\n');
    cmd_pip = 'python get-pip.py'; 
    [status, cmdout] = system(cmd_pip);
    fprintf(cmdout);
    if status==0
        promptMsg = '';
    end
    cd(obj.rootApp)
end 

%% Install required modules motuclient
cmd = 'motuclient --version';
[status, cmdout] = system(cmd); 

if ~(status==0)
    % Install motuclient (version 1.8.4 approved by Copernicus)  
    fprintf('\n-> Installing motuclient\n');
    cmd_pipinstall = 'python -m pip install motuclient==1.8.4 --no-cache-dir';
    [status, cmdout] = system(cmd_pipinstall);
    fprintf(cmdout);
    if status==0
        promptMsg = '';
    end 
end 

linePts = repelem('.', 53 - numel(promptMsg));
fprintf(' %s DONE\n', linePts);

% %% Assert pipenv is installed
% cmd_pipenv = 'pipenv --version'; 
% [status, cmdout] = system(cmd_pipenv);
% 
% if ~(status==0)
%     % Install pip 
%     cmd_pipenv = 'pip install pipenv'; 
%     [status, cmdout] = system(cmd_pipenv);
% end 

end

