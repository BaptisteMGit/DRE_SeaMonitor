% Construct a WebMapServer object
serverURL = 'https://ows.emodnet-bathymetry.eu/wms';
server = WebMapServer(serverURL);
capabilities = getCapabilities(server);
layers = capabilities.Layer;

% Find the appropriate layer 
layername = 'emodnet:mean';
% layername = 'emodnet:mean_multicolour';


mean_depth = refine(layers, layername, 'SearchFields', 'LayerName', 'MatchType', 'exact');
mean_depth.Latlim = [52, 53];
mean_depth.Lonlim = [-5.5, -4.5];

% Obtain data from the servers
request = WMSMapRequest(mean_depth, server);
A = getMap(server,request.RequestURL);
R = request.RasterReference;

figure
worldmap(A,R)
geoshow(A,R)
