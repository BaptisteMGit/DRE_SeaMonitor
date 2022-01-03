function data = convertBathyFile(varargin)
%% Function convertBathyFile
% Convert bathymetric file from SRC_source to SRC_dest
bathyFile = getVararginValue(varargin, 'bathyFile', ''); % Bathymetric file in WGS84
SRC_source = getVararginValue(varargin, 'SRC_source', 'WGS84');
SRC_dest = getVararginValue(varargin, 'SRC_dest', 'ENU');

switch SRC_source
    case 'WGS84'
        switch SRC_dest
            case 'UTM'
                nUTM = getVararginValue(varargin, 'nUTM', 29);
                data = convertBathyFile_WGS84_UTM(bathyFile, nUTM);
            case 'ENU'    
                mooringPos = getVararginValue(varargin, 'mooringPos', []);
                lon0 = mooringPos(1);
                lat0 = mooringPos(2);
                hgt0 = mooringPos(3);
%                 lon0 = getVararginValue(varargin, 'lon0', 0);
%                 lat0 = getVararginValue(varargin, 'lat0', 0);
%                 hgt0 = getVararginValue(varargin, 'hgt0', 0);
                data = convertBathyFile_WGS84_ENU(bathyFile, lon0, lat0, hgt0);
        end 
end 
end
