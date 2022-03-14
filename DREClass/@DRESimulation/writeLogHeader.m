function writeLogHeader(obj)
    fileID = fopen(obj.logFile,'w');
    % Configuration 
    fprintf(fileID,'MMDPM report for simulation started on %s/%s/%s %s:%s\n\n', ...
        obj.launchDate(1:4), obj.launchDate(5:6), obj.launchDate(7:8), obj.launchDate(10:11), obj.launchDate(11:12));

    fprintf(fileID, 'Equipment\n\n');
    fprintf(fileID,'\tName: %s\n', obj.mooring.mooringName);
    fprintf(fileID,'\tDeployment: %s to %s\n', obj.mooring.deploymentDate.startDate, obj.mooring.deploymentDate.stopDate);
    fprintf(fileID,'\tPosition: lon %4.4f°, lat %4.4f°, hgt %4.4fm\n', obj.mooring.mooringPos.lon, obj.mooring.mooringPos.lat, obj.mooring.mooringPos.hgt);
    fprintf(fileID,'\tHydrophone: %s\n', obj.detector.name);
    fprintf(fileID, '\tDetection threshold: %3.2f dB\n', obj.detector.detectionThreshold);
    fprintf(fileID, '__________________________________________________________________________\n\n');

    fprintf(fileID, 'Animal\n\n');
    fprintf(fileID, '\t%s emitting %s\n', obj.marineMammal.name, obj.marineMammal.signal.name);
    fprintf(fileID,'\tCentroid frequency: %d Hz\n', obj.marineMammal.signal.centroidFrequency);
    fprintf(fileID,'\tSource level: %d dB\n', obj.marineMammal.signal.sourceLevel);
    fprintf(fileID,'\tStd source level: %d dB\n', obj.marineMammal.signal.sigmaSourceLevel);
    fprintf(fileID,'\tDirectivity index: %d dB\n', obj.marineMammal.signal.directivityIndex);
    fprintf(fileID, '__________________________________________________________________________\n\n');

    fprintf(fileID, 'Simulation parameters\n\n');
    fprintf(fileID, '\tNumber of beams: %d\n', obj.bellhopEnvironment.beam.Nbeams);
    fprintf(fileID, '\tTL: %s\n', obj.bellhopEnvironment.runTypeLabel);
    fprintf(fileID, '\tBeam type: %s\n', obj.bellhopEnvironment.beamTypeLabel);
    fprintf(fileID, '\tSsp option: %s\n', obj.bellhopEnvironment.SspOption);
    fprintf(fileID, '\tBearing resolution: %.1f°\n', abs(obj.listAz(2)-obj.listAz(1)));
    fprintf(fileID, '__________________________________________________________________________\n\n');

    fprintf(fileID, 'Environment\n\n');
    fprintf(fileID, '\tOcean properties ');
    if obj.oceanEnvironment.connectionFailed
        fprintf(fileID, 'set to default after connection failed:\n\n');
    else
        fprintf(fileID, 'successfully downloaded from CMES (https://resources.marine.copernicus.eu/products):\n\n');
    end
    fprintf(fileID, '\tz(m)   T(C°)   S(ppt)   pH   c(m.s-1)\n');
    for i=1:numel(obj.oceanEnvironment.depth)
        fprintf(fileID, '\t%4.1f   %5.1f   %6.1f   %2.1f   %7.1f\n', ...
            obj.oceanEnvironment.depth(i), obj.oceanEnvironment.temperatureC(i), ...
            obj.oceanEnvironment.salinity(i), obj.oceanEnvironment.pH(i), obj.SoundCelerity(i));
    end

    fprintf(fileID, '\n\tAmbient noise level: %3.2f dB\n', obj.noiseEnvironment.noiseLevel);
    switch obj.bellhopEnvironment.SspOption(3)
        case 'M'
            unit = 'dB/m';
        case 'W'
            unit = 'dB/lambda';
    end
    fprintf(fileID, '\tCompression wave attenuation in the water column: %3.4f 1e-3 %s\n', obj.cwa*1000, unit);
    fprintf(fileID, '\tSediment: %s with the following properties\n', obj.seabedEnvironment.sedimentType);
    fprintf(fileID, '\t\tCompression wave celerity: %4.1f m.s-1\n', obj.seabedEnvironment.bottom.c); 
    fprintf(fileID, '\t\tCompression wave attenuation: %3.4f 1e-3 %s\n', obj.seabedEnvironment.bottom.cwa*1000, unit); 
    fprintf(fileID, '\t\tDensity: %2.2f g.cm-3\n', obj.seabedEnvironment.bottom.rho); 
    fprintf(fileID, '__________________________________________________________________________\n\n');

    fprintf(fileID, 'Estimating detection range\n\n');
    switch obj.offAxisAttenuation
        case 'Broadband'
            fprintf(fileID, 'Directional loss approximation:\nDLbb = C1 * (C2*sin(theta)).^2 ./ (1 + abs(C2*sin(theta)) + (C2*sin(theta)).^2)\n');
            fprintf(fileID, 'with C1 = 47, C2 = 0.218*ka, ka = 10^(DI/20)\n\n');
        case 'Narrowband'
            fprintf(fileID, 'Directional loss approximation:\nDLnb = (2*J1(ka*sin(theta)) ./ (ka*sin(theta)) ).^2\n');
            fprintf(fileID, 'with J1 the first-order Bessel function of the first kind and ka = 10^(DI/20)\n');
            fprintf(fileID, 'Please note that this piston model is modified to reduced to mainly first lobe.\n');
            fprintf(fileID, 'For more information on the exact model read the attach documentation.\n\n');
    end
    fprintf(fileID, 'Off-axis distribution: %s\n', obj.offAxisDistribution);
    switch obj.offAxisDistribution
        case 'Uniformly distributed on a sphere (random off-axis)'
            fprintf(fileID, 'Woa = 1/2 * sin(theta)\n\n');
        case 'Near on-axis'
            fprintf(fileID, 'Woa_h = (theta / sigmaH^2) .* exp(-1/2 * ( (theta / sigmaH).^2) )\n');
            fprintf(fileID, 'with sigmaH = %d° (standard deviation of head angle with on-axis direction)\n\n', obj.sigmaH);
    end
    fprintf(fileID, 'Probability threshold used to derive detection range: %s\n\n', obj.detectionRangeThreshold);
    fprintf(fileID, '\tBearing (°)\tDetection range (m)\n\n');
    fclose(fileID);   
end
        