classdef gui_exportedTest < matlab.uitest.TestCase & matlab.mock.TestCase

    methods (Test)

        function testInputButton(tc)
            import matlab.mock.actions.AssignOutputs
            fname = '/Data/Model Combined/o3_surface_20180701000000.nc';

            [mockChooser, behavior] = tc.createMock(?FileChooser);

            when(behavior.uigetfile('*.nc'), AssignOutputs(fname, pwd, 1))
            %disp("ASdAFSD");
            app = gui_exported(mockChooser);
            tc.addTeardown(@close, app.UIFigure);
            %disp(app.UploadanNCfileButton)
            tc.press(app.UploadanNCfileButton);
            %disp(pwd);
            %tc.verifyEqual(1, 1)
            tc.verifyEqual(app.NcFile.Value, fullfile(pwd, fname));

        end

        function testInputButton_Cancel(tc)
            import matlab.mock.actions.AssignOutputs
            fname = '/o3_surface_20180701000000.nc';

            [mockChooser, behavior] = tc.createMock(?FileChooser);
            when(behavior.uigetfile('*.nc'), AssignOutputs(fname, pwd, 0))

            app = gui_exported(mockChooser);
            tc.addTeardown(@close, app.UIFigure);

            tc.press(app.UploadanNCfileButton);

            tc.verifyCalled(behavior.uigetfile('*.nc'));
            tc.verifyEqual(app.NcFile.Value, 'Enter a valid path!');
        end

    end

end
