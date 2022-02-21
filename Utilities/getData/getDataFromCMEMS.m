function getDataFromCMEMS(varargin)
% GETDATAFROMCMEMS fetch data from CMEMS. 
% Connection parameters 
username = 'bmenetrier';
password = 'Copernicus753!';

motuPath = getVararginValue(varargin, 'motuPath', '');
dbName = getVararginValue(varargin, 'dbName', '');
productName = getVararginValue(varargin, 'productName', '');
bBox = getVararginValue(varargin, 'bBox', []); % Boundary box -> struct with fields lon, lat (strucs with fields min, max)
tBox = getVararginValue(varargin, 'tBox', []); % Time box for the query struct with fields startDate, stopdate with format 'yyyy-mm-dd hh:mm:ss'
dBox = getVararginValue(varargin, 'dBox', []); % Depth box -> struct with field min, max
variables = getVararginValue(varargin, 'variables', {}); % variables to get 
outputDir = getVararginValue(varargin, 'outputDir', '');
outputFile = getVararginValue(varargin, 'outputFile', '');

% % Test 
% dbName = 'INSITU_GLO_TS_OA_NRT_OBSERVATIONS_013_002_a-TDS';
% productName = 'CORIOLIS-GLOBAL-NRTOA-OBS_TIME_SERIE';
% bBox = getbBox(-4.45, -4.3, 52.2, 52.3);
% tBox = gettBox('2021-01-21 12:00:00', '2021-02-21 12:00:00');
% dBox = getdBox(0, 100);
% variables = {'PSAL', 'TEMP'};
% outputDir = 'C:\Users\33686\Desktop\testCopernicus';
% outputFile = 'testCase1';

part1 = sprintf('python -m motuclient --motu %s ', motuPath); % Basic routine to query data from Copernicus 
part2 = sprintf('--service-id %s --product-id %s ', dbName, productName); % Setting name of the database and of the product to query 
part3 = sprintf('--longitude-min %.4f --longitude-max %.4f --latitude-min %.4f --latitude-max %.4f ', ...
            bBox.lon.min, bBox.lon.max, bBox.lat.min, bBox.lat.max); % Setting geographical boundaries 
part4 = sprintf('--date-min "%s" --date-max "%s" ', datestr(tBox.startDate, 'yyyy-mm-dd HH:MM:ss'), datestr(tBox.stopDate, 'yyyy-mm-dd HH:MM:ss')); % Setting time limits 
if ~isempty(dBox)
    part5 = sprintf('--depth-min %.4f --depth-max %.4f ', dBox.min, dBox.max); % Setting depth limits
else 
    part5 = '';
end 
part6 = sprintf('--variable %s ', variables{1:end});
part7 = sprintf('--out-dir %s --out-name %s ', outputDir, outputFile);
part8 = sprintf('--user %s --pwd %s', username, password);

cmd_str = [part1 part2 part3 part4 part5 part6 part7 part8];

[status, cmdout] = system(cmd_str)

if status ~= 0
    error(cmdout)
end

end 
