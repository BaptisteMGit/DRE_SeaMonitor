function plotBathy1D(obj, nameProfile)
    cd(obj.rootOutputFiles)
    plotbty(nameProfile)
    % Title
    title('Bathymetry', nameProfile)
    cd(obj.rootApp)
end