classdef BellhopEnvironment < handle
    properties
        drSimu      % Range step (km) between receivers: more receivers increase accuracy but also increase CPU time 
        dzSimu      % Depth step (m) between receivers: more receivers increase accuracy but also increase CPU time
        SspOption 
        interpMethodBTY 
        beam

        % Explicit labels
        SspInterpMethodLabel
        SurfaceTypeLabel
        AttenuationUnitLabel
        runTypeLabel
        beamTypeLabel
    end


    properties (Hidden)
        % Resolution
        drSimuDefault = 0.01;
        dzSimuDefault = 0.5;
        % Surface
        SspOptionDefault = 'SVM'; % M for attenuation in dB/m
        % Bathy 
        interpMethodBTYDefault = 'C';  % 'L' Linear piecewise, 'C' Curvilinear  
        % Beam
        runType1Default = 'S'; % 'C': Coherent, 'I': Incoherent, 'S': Semi-coherent, 'R': ray, 'E': Eigenray, 'A': Amplitudes and travel times 
        runType2Default = 'B'; % 'G': Geometric beams (default), 'C': Cartesian beams, 'R': Ray-centered beams, 'B': Gaussian beam bundles.
        NbeamsDefault = 5001; % Number of launching angles
        alphaDefault = [-80, 80]; % Launching angles in degrees
        deltasDefault = 0; % Ray-step (m) used in the integration of the ray and dynamic equations, 0 let bellhop choose 
    end

    methods
        function obj = BellhopEnvironment(dr, dz, SspOpt, interpMethodBty, beam)
            
            obj.setDefault()
            
            if nargin >= 1; obj.drSimu = dr; end
            if nargin >= 2; obj.dzSimu = dz; end
            if nargin >= 1; obj.SspOption = SspOpt; end
            if nargin >= 1; obj.interpMethodBTY = interpMethodBty; end
            if nargin >= 1; obj.beam = beam; end

        end
    end
    
    methods 

        function setDefault(obj)
            obj.setBeamDefault()
            obj.drSimu = obj.drSimuDefault;
            obj.dzSimu = obj.dzSimuDefault;
            obj.SspOption = obj.SspOptionDefault;
            obj.interpMethodBTY = obj.interpMethodBTYDefault;
        end
        

        function setBeamDefault(obj)
            % Beam 
            obj.beam.RunType(1) = obj.runType1Default;
            obj.beam.RunType(2) = obj.runType2Default;
            obj.beam.Nbeams = obj.NbeamsDefault;
            obj.beam.alpha = obj.alphaDefault;
            obj.beam.deltas = obj.deltasDefault;
        end

        function [bool, msg] = checkParametersValidity(obj)
            bool = 1;
            msg = {};
        end
    end 

    methods 
       function runTypeName = get.runTypeLabel(obj)
            switch obj.beam.RunType(1) 
                case 'C'
                    runTypeName = 'Coherent';
                case 'S'
                    runTypeName = 'Semi coherent';
                case 'I'
                    runTypeName = 'Incoherent';
            end
        end

        function beamTypeName = get.beamTypeLabel(obj)
            switch obj.beam.RunType(2) 
                case 'G'
                    beamTypeName = 'Geometric rays';
                case 'B'
                    beamTypeName = 'Gaussian beams';
            end
        end

        function intMethod = get.SspInterpMethodLabel(obj)
            switch obj.SspOption(1)
                case 'S'
                    intMethod = 'Cubic spline';
                case 'C' 
                    intMethod = 'C-linear';
                case 'N' 
                    intMethod = 'N-2-linear';
                case 'Q'
                    intMethod = 'Quadratic';
            end
        end

        function sType = get.SurfaceTypeLabel(obj)
            switch obj.SspOption(2)
                case 'V'
                    sType = 'Vacuum above surface';
                case 'R' 
                    sType = 'Perfectly rigid media above surface';
                case 'A' 
                    sType = 'Acoustic half-space';
            end
        end

        function attUnit = get.AttenuationUnitLabel(obj)
            switch obj.SspOption(3)
                case 'M'
                    attUnit = 'db/m';
            end
        end
    end 

end


