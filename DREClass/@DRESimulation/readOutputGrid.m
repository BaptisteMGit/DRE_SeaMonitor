function readOutputGrid(obj, nameProfile)
    filename = sprintf('%s.shd', nameProfile);
    cd(obj.rootOutputFiles)
    [ ~, ~, ~, ~, ~, Pos, ~] = read_shd( filename );
    obj.zt = Pos.r.z;
    obj.rt = Pos.r.r;
    cd(obj.rootApp)
end