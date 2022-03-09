function deleteBathyFiles(obj)
    cd(obj.rootSaveInput)
    rmdir('2DProfile', 's')
%   delete('Bathymetry.csv')
    cd(obj.rootApp)
end