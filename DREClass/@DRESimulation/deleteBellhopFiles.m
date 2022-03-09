function deleteBellhopFiles(obj)
    cd(obj.rootOutputFiles)

    listPrt = dir('*.prt');
    listPrt = listPrt(~cellfun('isempty', {listPrt.date}));
    listEnv = dir('*.env');
    listEnv = listEnv(~cellfun('isempty', {listEnv.date}));

    sz = size(listPrt);
    for i=1:sz(1)
        file = listPrt(i).name;
        delete(file)
    end

    sz = size(listEnv);
    for i=1:sz(1)
        file = listEnv(i).name;
        delete(file)
    end

    cd(obj.rootApp)
end
