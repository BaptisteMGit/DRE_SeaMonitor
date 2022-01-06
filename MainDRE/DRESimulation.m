classdef DRESimulation 
    properties
        % Bathymetry
        bathyEnvironment
        % Mooring 
        mooring 
        % Receiver 
        drSimu = 0.01;                      % Range step (km) between receivers: more receivers increase accuracy but also increase CPU time 
        dzSimu = 0.5;                       % Depth step (m) between receivers: more receivers increase accuracy but also increase CPU time
        dPropagation                        % Propagation distance to simulate (according to the parameters of the mammal) 

        % Marine mammal to simulate 
        marineMammal 

    end

    methods
    %% Constructor 
        function obj = DRESimulation(bathyEnv, moor, mammal, dr, dz, dPropa)
            % Bathy env 
            if nargin >= 1
                if isa(bathyEnv, 'BathyEnvironment')
                    obj.bathyEnvironment = bathyEnv;
                else
                    error('Bathymetry environment should be an object from class BathyEnvironment !')
                end
                
                % Mooring
                if nargin >= 2
                    if isa(moor, 'Mooring')
                        obj.mooring = moor;
                    else
                        error('Mooring should be an object from class Mooring !')
                    end
                    
                    % Mammal
                    if nargin >= 3
                        if isa(mammal, 'MarineMammal')
                            obj.marineMammal = mammal;
                        else
                            error('MarineMammal should be an object from class MarineMammal !')
                        end
                        
                        % drSimu
                        if nargin >= 4 
                            obj.drSimu = dr;

                            % dzSimu
                            if nargin >= 5
                                obj.dzSimu = dz;
                            end
                        end
                    end
                end
            end 
        end

        function 
            r = round([obj.Value],2);
        end
    
   end
end








 