classdef DefaultFileChooser < FileChooser

    methods

        function [file, folder, status] = uigetfile(chooser, varargin)
            [file, folder, status] = uigetfile(varargin{:});
            %disp(file);
            %disp(folder);
            %disp(status);
            %disp(chooser);
            %disp(varargin);
            %disp(class(status));
        end

    end

end
