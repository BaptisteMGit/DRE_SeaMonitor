function [data, outputFile] = convertBathyFile(varargin)
%% Function convertBathyFile
% Convert bathymetric file from SRC_source to SRC_dest
% Input file must be a table
bathyFile = getVararginValue(varargin, 'bathyFile', ''); % Name of bathymetry file 
rootBathy = getVararginValue(varargin, 'rootBathy', ''); % Root to bathymetry file 
SRC_source = getVararginValue(varargin, 'SRC_source', 'WGS84');
SRC_dest = getVararginValue(varargin, 'SRC_dest', 'ENU');

switch SRC_source
    case 'WGS84'
        switch SRC_dest
            case 'UTM'
                nUTM = getVararginValue(varargin, 'nUTM', 29);
                [data, outputFile] = convertBathyFile_WGS84_UTM(rootBathy, bathyFile, nUTM);
            case 'ENU'    
                mooringPos = getVararginValue(varargin, 'mooringPos', []);
                lon0 = mooringPos(1);
                lat0 = mooringPos(2);
                hgt0 = mooringPos(3);
                [data, outputFile] = convertBathyFile_WGS84_ENU(rootBathy, bathyFile, lon0, lat0, hgt0);
        end 
end 
end
