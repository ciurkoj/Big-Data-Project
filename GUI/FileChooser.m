classdef FileChooser
    % Interface to choose a file
    methods (Abstract)
        [file, folder, status] = uigetfile(chooser, varargin);

    end

end
