classdef gui_exportedTest < matlab.uitest.TestCase & matlab.mock.TestCase

    methods (Test)
        %% Select file *.nc with a model 
        function UploadanNCfileButton(testCase)
            import matlab.mock.actions.AssignOutputs;
            fname = '../Data/Model Combined/o3_surface_20180701000000.nc';
            [mockChooser, behavior] = testCase.createMock(?FileChooser);    % create a mock object
            when(behavior.uigetfile('*.nc'), AssignOutputs(fname, pwd, 1))  % assigns the right out with status "1"    
            app = gui_exported(mockChooser);                                % run the app with mock object as an input
            testCase.addTeardown(@close, app.UIFigure);                     % closes the app at the end of function execution
            testCase.press(app.UploadanNCfileButton);                       % imitates pressing the correct button
            testCase.verifyEqual(app.NcFile.Value, fullfile(pwd, fname));   % verifies if defined actions gives the correct output
        end
        
        
       %% Break *.nc file selection (leave empty)
        function UploadanNCfileButton_Cancel(testCase)
            import matlab.mock.actions.AssignOutputs
            fname = '';                                                     % define empty file name 
            [mockChooser, behavior] = testCase.createMock(?FileChooser);    % create a mock object
            when(behavior.uigetfile('*.nc'), AssignOutputs(fname, pwd, 0)); % 0 is the file's status, stands for empty object
            app = gui_exported(mockChooser);                                % run the app with mock object as an input
            testCase.addTeardown(@close, app.UIFigure);                     % closes the app at the end of function execution
            testCase.press(app.UploadanNCfileButton);                       % presses button that is being tested
            testCase.verifyCalled(behavior.uigetfile('*.nc'));
            testCase.verifyEqual(app.NcFile.Value, 'Enter a valid path!');  % verifies if the given output is correct
        end
        %
        
        %% Select folder with CSV models 
        function ChoosefolderwithCSVmodelsButton(testCase)
            import matlab.mock.actions.AssignOutputs;
            pathName = '../Data/24Hour';                                    % select default path with CSV models
            [mockChooser, behavior] = testCase.createMock(?PathFinder);     % create a mock object
            when(withExactInputs(behavior.getdir()), AssignOutputs(pathName)) % when a behavior was called, assging pathName to the output 
            app = gui_exported(mockChooser);                                % run the app
            testCase.addTeardown(@close, app.UIFigure);                     % closes the app at the end of function execution
            testCase.press(app.ChoosefolderwithCSVmodelsButton);            % presses button that is being tested
            testCase.verifyEqual(app.CSVsFolder.Value, pathName);           % verifies if correct output was given

        end
        %
        
        %% Break selecting folder with CSV models (leave empty
        function ChoosefolderwithCSVmodelsButton_Cancel(testCase)
            import matlab.mock.actions.AssignOutputs
            [mockChooser, behavior] = testCase.createMock(?PathFinder);     % create a mock object
            when(withExactInputs(behavior.getdir()), AssignOutputs(''))     % when defined acction happens, handle a behavior 
            app = gui_exported(mockChooser);                                % run the app with a mock object as an input 
            testCase.addTeardown(@close, app.UIFigure);                     % if test executes with no erros, close the fugire
            testCase.press(app.ChoosefolderwithCSVmodelsButton);            % press defined button
            testCase.verifyCalled(withExactInputs(behavior.getdir()));      % chceck if behavior was executed, then 
            testCase.verifyEqual(app.CSVsFolder.Value, 'Enter a valid path!');  % verify the error message
        end
        %
        
        %% Mock exporting video with no input data
        function ExportvideofileButtonPushed_with_no_data(testCase)
            import matlab.mock.actions.AssignOutputs
            saveAsName = 'aVideo123ewsd';                                   % a video's name
            error_message='You need to load the data';                      % an error message
            [mockChooser, behavior] = testCase.createMock(?PathFinder);     % create a mock object
            when(withExactInputs(behavior.getdir()), AssignOutputs(saveAsName)); % assign a name, under which file will be saved
            app = gui_exported(mockChooser);                                % run the app with a mock object as an input 
            testCase.addTeardown(@close, app.UIFigure);                     % closes the app at the end of test execution
            testCase.press(app.ExportvideofileButton);                      % presses the button 
            testCase.verifyEqual(app.SaveasEditField.Value, error_message); % verify the error message
            testCase.verifyEqual(app.SaveDestionation.Value, error_message);
        end
        %
        
        %% Mock saving without saving destination
        function ExportvideofileButtonPushed_without_destination(testCase)
            import matlab.mock.actions.AssignOutputs;
            [mockChooser, behavior] = testCase.createMock(?PathFinder);     % create a mock object
            when(withExactInputs(behavior.getdir()), AssignOutputs(''));    % enter blank saving destination
            app = gui_exported(mockChooser);                                % run the app with a mock object as an input 
            testCase.addTeardown(@close, app.UIFigure);                     % closes the app at the end of test execution
            testCase.press(app.SelectsavedestinationButton);
            testCase.verifyEqual(app.SaveDestionation.Value, 'Enter a valid path!');
        end
        
        
        %% Save video without a name 
        function ExportvideofileButtonPushed_without_SaveAsName(testCase)
            import matlab.mock.actions.AssignOutputs
            pathName = '../Data/24Hour';
            [mockChooser, behavior] = testCase.createMock(?PathFinder);     % create a mock object with a path finder
            when(withExactInputs(behavior.getdir()), AssignOutputs(pathName)); % select the path to save file
            app = gui_exported(mockChooser);                                % run the app
            testCase.addTeardown(@close, app.UIFigure);
            app.SaveasEditField.Value = '';                                 % enter blank name
            app.tableValues = [1, 2, 3];                                    % enter dummy data
            app.theMaps = [1, 2, 3];                                        %
            testCase.press(app.SelectsavedestinationButton);                % select a path
            testCase.press(app.ExportvideofileButton);                      % press export button
            testCase.verifyEqual(app.SaveasEditField.Value, 'Enter a valid name!'); % compare error messages
        end
    %
    end

end
