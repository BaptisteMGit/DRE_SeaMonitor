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
%         SspOptionDefault = 'SVM'; % M for attenuation in dB/m
        SspOptionDefault = 'SVW'; % W for attenuation in dB/lambda
        % Bathy 
        interpMethodBTYDefault = 'C';  % 'L' Linear piecewise, 'C' Curvilinear  
        % Beam
        runType1Default = 'S'; % 'C': Coherent, 'I': Incoherent, 'S': Semi-coherent, 'R': ray, 'E': Eigenray, 'A': Amplitudes and travel times 
        runType2Default = 'B'; % 'G': Geometric beams (default), 'C': Cartesian beams, 'R': Ray-centered beams, 'B': Gaussian beam bundles.
        NbeamsDefault = 1001; % Number of launching angles
        alphaDefault = [-89, 89]; % Launching angles in degrees
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
            obj.beam.RunType(1) = obj.runType1Default; % Run type 
            obj.beam.RunType(2) = obj.runType2Default; % Beam type 
            obj.beam.Nbeams = obj.NbeamsDefault; % Number of beams used 
            obj.beam.alpha = obj.alphaDefault;
            obj.beam.deltas = obj.deltasDefault;
        end

        function [bool, msg] = checkParametersValidity(obj)
            bool = 1;
            msg = {};
            
            if abs(obj.beam.alpha(1)) > 89
                bool = 0;
                msg{end+1} = 'Angle aperture must be smaller than 89°. Value has been set to default 89°.';
                obj.beam.alpha = obj.alphaDefault;
            end

            if obj.beam.Nbeams < 100
                bool = 0;
                msg{end+1} = 'Number of beams must be greater than 100. Value has been set to minimum 100.';
                obj.beam.Nbeams = 100;
            end
            
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
                    attUnit = 'dB/m';
                case 'W'
                    attUnit = 'dB/lambda';
            end
        end
    end 

end


