function plotSSP(obj, varargin)
%PLOTSSP plot sound celerity profile derived for mooring position
    if nargin > 1 && strcmp(varargin(1), 'app')
        figure('visible','off');
    end

    plot(obj.ssp.c, obj.ssp.z)
    xlabel('Celerity (m.s-1)')
    ylabel('Depth (m)')
    title({['Celerity profile at the ' ...
        'mooring position'], 'Derived with Mackenzie equation'})
    set(gca, 'YDir', 'reverse')

    if nargin > 1 && strcmp(varargin(1), 'app')
        saveas(gcf, fullfile(obj.rootSaveInput, 'CelerityProfile.png'))
        close(gcf)
    end

end

