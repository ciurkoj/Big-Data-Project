classdef gui_exportedTest < matlab.uitest.TestCase & matlab.mock.TestCase

    methods (Test)

        function UploadanNCfileButton(testCase)
            import matlab.mock.actions.AssignOutputs
            fname = '../Data/Model Combined/o3_surface_20180701000000.nc';

            [mockChooser, behavior] = testCase.createMock(?FileChooser);

            when(behavior.uigetfile('*.nc'), AssignOutputs(fname, pwd, 1))
            %disp("ASdAFSD");
            app = gui_exported(mockChooser);
            testCase.addTeardown(@close, app.UIFigure);
            %disp(app.UploadanNCfileButton)
            testCase.press(app.UploadanNCfileButton);
            %disp(pwd);
            %tc.verifyEqual(1, 1)
            testCase.verifyEqual(app.NcFile.Value, fullfile(pwd, fname));

        end

        function UploadanNCfileButton_Cancel(testCase)
            import matlab.mock.actions.AssignOutputs
            fname = '/o3_surface_20180701000000.nc';

            [mockChooser, behavior] = testCase.createMock(?FileChooser);
            when(behavior.uigetfile('*.nc'), AssignOutputs(fname, pwd, 0))

            app = gui_exported(mockChooser);
            testCase.addTeardown(@close, app.UIFigure);

            testCase.press(app.UploadanNCfileButton);

            testCase.verifyCalled(behavior.uigetfile('*.nc'));
            testCase.verifyEqual(app.NcFile.Value, 'Enter a valid path!');
        end

        function ChoosefolderwithCSVmodelsButton(testCase)
            import matlab.mock.actions.AssignOutputs
            pathName = '../Data/24Hour';

            [mockChooser, behavior] = testCase.createMock(?PathFinder);
            disp(mockChooser)
            when(withExactInputs(behavior.getdir()), AssignOutputs(pathName))
            %disp("ASdAFSD");
            app = gui_exported(mockChooser);
            testCase.addTeardown(@close, app.UIFigure);
            %disp(app.UploadanNCfileButton)
            testCase.press(app.ChoosefolderwithCSVmodelsButton);
            %disp(pwd);
            %tc.verifyEqual(1, 1)

            testCase.verifyEqual(app.CSVsFolder.Value, pathName);

        end

    end

end
