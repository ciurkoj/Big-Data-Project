classdef DefaultFileChooser < FileChooser

    methods

        function [file, folder, status] = uigetfile(chooser, varargin)
            [file, folder, status] = uigetfile(varargin{:});
        end

    end

end
