request = ['https://ows.emodnet-bathymetry.eu/wfs?request=GetFeature', ...
            '&service=WFS&coverageId=emodnet__mean', ...
            '&subset=Lat(51,51.1)&subset=Long(-4,-3.99)&outputFormat=text/csv'];

path_HTTPRequest_py = fullfile(pwd, 'Python\HTTPRequest.py');
% cmd = ['python ' path_HTTPRequest_py ' ' request];
cmd = sprintf('python %s "%s"', path_HTTPRequest_py, request);
[status, cmdout] = system(cmd);





























% import matlab.net.*
% import matlab.net.http.*
% uri = 'https://ows.emodnet-bathymetry.eu';
% 
% % request = RequestMessage;
% % request.RequestLine =  matlab.net.http.RequestLine('POST /wcs HTTP/1.1');
% 
% requestLine = matlab.net.http.RequestLine('POST', '/wcs', 'HTTP/1.1');
% hostField = matlab.net.http.field.HostField('ows.emodnet-bathymetry.eu');
% contentTypeField = matlab.net.http.field.ContentTypeField('text/xml; charset=utf-8');
% 
% header = [hostField, contentTypeField];
% 
% body = [
% '<?xml version="1.0" encoding="UTF-8"?>',...
% '<wcs:GetCoverage xmlns:wcs="http://www.opengis.net/wcs/1.1.1" xmlns:gml="http://www.opengis.net/gml"', ...
%   'xmlns:ogc="http://www.opengis.net/ogc" xmlns:ows="http://www.opengis.net/ows/1.1"', ...
%   'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"', ...
%   'version="1.1.1" service="WCS"', ...
%   'xsi:schemaLocation="http://www.opengis.net/wcs/1.1.1 http://schemas.opengis.net/wcs/1.1.1/wcsAll.xsd">', ...
%    '<ows:Identifier>emodnet:mean</ows:Identifier>', ...
%    '<wcs:DomainSubset>', ...
%    	"<!-- The bounding box you'd like to request -->", ...
%       '<ows:BoundingBox crs="urn:ogc:def:crs:EPSG::4326">', ...
%          '<ows:LowerCorner>43.48729 -2.5319802324929</ows:LowerCorner>', ...
%          '<ows:UpperCorner>44.016457 -1.634064</ows:UpperCorner>', ...
%       '</ows:BoundingBox>', ...
%    '</wcs:DomainSubset>', ...
%    '<wcs:Output store="true" format="image/tiff">', ...
%       '<wcs:GridCRS>', ...
%          '<wcs:GridBaseCRS>urn:ogc:def:crs:EPSG::4326</wcs:GridBaseCRS>', ...
%          '<wcs:GridType>urn:ogc:def:method:WCS:1.1:2dSimpleGrid</wcs:GridType>', ...
%          '<wcs:GridOffsets>0.0020881772848672093 -0.0020833346456692954</wcs:GridOffsets>', ...
%          '<wcs:GridCS>urn:ogc:def:cs:OGC:0.0:Grid2dSquareCS</wcs:GridCS>', ...
%       '</wcs:GridCRS>', ...
%    '</wcs:Output>', ...
% '</wcs:GetCoverage>'
% ];
% 
% body = matlab.net.http.MessageBody(body);
% % method = matlab.net.http.RequestMethod.POST;
% request = matlab.net.http.RequestMessage(requestLine, header,body);
% show(request)
% 
% resp = send(request,uri);