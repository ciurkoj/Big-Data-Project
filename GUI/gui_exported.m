classdef gui_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure matlab.ui.Figure
        UIAxes matlab.ui.control.UIAxes
        GenerateaMapButton matlab.ui.control.Button
        ChangetimeLabel matlab.ui.control.Label
        ChangetimeSlider matlab.ui.control.Slider
        UITable matlab.ui.control.Table
        OrextractdatafromcsvmodelsPanel matlab.ui.container.Panel
        ChoosefolderwithCSVmodelsButton matlab.ui.control.Button
        CSVsFolder matlab.ui.control.EditField
        ChooseEnsembleForCombinedModelButtonGroup matlab.ui.container.ButtonGroup
        OriginButton matlab.ui.control.RadioButton
        ClusterBasedEnsembleButton matlab.ui.control.RadioButton
        CSVmodelsnametemplateEditFieldLabel matlab.ui.control.Label
        CSVmodelsnametemplateEditField matlab.ui.control.EditField
        CSVLoadDataButton matlab.ui.control.Button
        ImportdatafromanncfilePanel matlab.ui.container.Panel
        NcFile matlab.ui.control.EditField
        UploadanNCfileButton matlab.ui.control.Button
        NCLoadDataButton matlab.ui.control.Button
        ChooseModelDropDownLabel matlab.ui.control.Label
        ChooseModelDropDown matlab.ui.control.DropDown
        ChangeColourAccessibilityButtonGroup matlab.ui.container.ButtonGroup
        DefaultButton matlab.ui.control.ToggleButton
        DeuteanopiagreenweaknessButton matlab.ui.control.ToggleButton
        ProtanopiaredweaknessButton matlab.ui.control.ToggleButton
        TritanopiablueyellowweaknessButton matlab.ui.control.ToggleButton
        MonochromacyButton matlab.ui.control.ToggleButton
        ExportvideoPanel matlab.ui.container.Panel
        SelectresolutionDropDownLabel matlab.ui.control.Label
        SelectresolutionDropDown matlab.ui.control.DropDown
        SaveasEditFieldLabel matlab.ui.control.Label
        SaveasEditField matlab.ui.control.EditField
        ExportvideofileButton matlab.ui.control.Button
        videoFormat matlab.ui.control.Label
        SelectsavedestinationButton matlab.ui.control.Button
        SaveDestionation matlab.ui.control.EditField
        PlayButton matlab.ui.control.Button
        SwitchpresantationmodeLabel matlab.ui.control.Label
        Switchpresantationmode matlab.ui.control.Switch
    end

    properties (Access = private)
        %tableValues;
        xValues = [];
        yValues = [];
        zValues = [];
        pathToNcFile;
        pathToCBEs;
        csvNameTemplate;
        theNcFile;
        colorAccessibilityOption;
        %theMaps = [];
        SliderPreviousValue;
        ax1;
        fileChooser;
        pathFinder;
        stopPlay = false; % Description
        imgArray = [];
        
    end
    %% Public variables used in unit tests
    properties (Access = public)
        tableValues;
        theMaps = [];

    end

    %% Private functions accessed only by the app
    methods (Access = public)
        
        %% generateMap plots data points into a map. Each map is being saved
        % in an array, as well as image frames taken whilst map generation.
        % By default the application plots data over Europe.
        function generateMap(app)
            cla(app.UIAxes, 'reset');           % before any map generation, the canvas must be cleaned so that maps will not overlay each other
            axis(app.UIAxes, 'off');            % turns off field's axis 
            app.ax1 = worldmap('Europe');       % Create main figure 
            fig1 = app.ax1.Parent;              % assign the figure to a variable
            max_resolution = get(0,'ScreenSize');   % get maximal screen resolution
            set(fig1, 'units', 'pixels', 'position', [0, 0, max_resolution(3), max_resolution(4)]); % set figure's size to possible max
            set(fig1, 'Visible', 'off');        % set the figure invisible for better user experience
            land = shaperead('landareas', 'UseGeoCoords', true);    % next lines plot contours on the map
            geoshow([land.Lat], [land.Lon], 'Color', 'k');
            lakes = shaperead('worldlakes', 'UseGeoCoords', true);
            geoshow(lakes, 'FaceColor', 'blue');
            cities = shaperead('worldcities', 'UseGeoCoords', true);
            geoshow(cities, 'Marker', '.', 'Color', 'red');
            xbar = waitbar(0, 'Loading data');
            app.theMaps = [];
            set(figure(2), 'units', 'pixels', 'position', [0, 0, max_resolution(3), max_resolution(4)]); % sets 2nd figure's size
            set(figure(2), 'Visible', 'off');   %turn off its visibility
            app.imgArray = [];  % clean up images array
            
            % for loop iterates through all zValues and plots them on a map
            for time = 1:length(app.zValues(1, 1, :)) 
                theTitle = sprintf('Europe at %.f:00', time - 1);
                title(theTitle);
                set(0, 'currentfigure', app.ax1.Parent);
                map = surfm(app.xValues, app.yValues, app.zValues(:, :, time), 'EdgeColor', 'none', 'FaceAlpha', 0.7);
                theTitle = sprintf('Europe at %.f:00', app.ChangetimeSlider.Value);
                title(app.ax1, theTitle);
                app.ChangeColourAccessibilityButtonGroupSelectionChanged(); %sets color theme bases on chosen option

                app.theMaps = [app.theMaps, map];   % adds a plot to the array
                app.imgArray = [app.imgArray, getframe(app.ax1.Parent)];     % takes frame and saves it in an array
                app.addColorbar(app.ax1);           % adds colorbar to the main figure
                set(app.theMaps(time), 'Visible', 'off');   %sets all plots to invisible mode

                if isvalid(xbar)
                    waitbar(time / (length(app.zValues(1, 1, :))), xbar, strcat('In progress (', string(time / (length(app.zValues(1, 1, :))) * 100), '%)'));% services progress bar
                        
                else
                    continue
                end

            end
            % when the loop has finished its iteration
            set(0, 'currentfigure', app.ax1.Parent);    % sets focus on main figure
            set(app.theMaps(app.ChangetimeSlider.Value + 1), 'Visible', 'on');  % sets (usually) first figure as visible
            app.SliderPreviousValue = (app.ChangetimeSlider.Value) + 1;     % saves previous iteration value
            theTitle = sprintf('Europe at %.f:00', app.ChangetimeSlider.Value);
            title(app.UIAxes, theTitle);        % adds title to the app's figure
            copyobj(app.ax1.Children, app.UIAxes); % copies an object from main figure to the app
            app.addColorbar(app.UIAxes);        % adds color bar to app's figure
            app.PlayButton.Enable = 'on';       % enables Play buttton to be used
            % if progress bar hasn't been closed
            if isvalid(xbar)
                close(xbar); % close progress bar
            end

            app.GenerateaMapButton.Enable = "on";   % enables the button so that next map could be plotted
                                                    % and prevents app from possible crashes
        end

        %% Function reads nc files and extracts data to variables
        function readNcValuesToTable(app, pathToNcFile)

            if ~isempty(pathToNcFile)       % if path is valid
                app.tableValues = [];               % cleans the variable
                xbar = waitbar(0, 'Loading data');      %start a progress bar
                app.zValues = [];
                app.zValues = ncread(pathToNcFile, app.ChooseModelDropDown.Value);  % read chosen nc model and save it in the variable
                formatSpec = "Table size from hour no. %d:00 : %s";
                typeof = size(app.zValues);
                matrixSize = "%d x %d";
                a = compose(matrixSize, typeof(1, 1), typeof(1, 2)); % composes table's entry to show what is being read

                %for loop creates table's entries 
                for k = 0:(length(app.zValues(1, 1, :)) - 1)
                    value = compose(formatSpec, k, a);
                    app.tableValues = [app.tableValues; value];

                    if isvalid(xbar)
                        waitbar(k / (length(app.zValues(1, 1, :)) - 1), xbar, strcat('In progress (', string(k / (length(app.zValues(1, 1, :)) - 1) * 100), '%)'));
                    else
                        continue
                    end

                end

                variables = {ncinfo(pathToNcFile).Variables.Name};  % gathers all variables save in the model
                % and sets correct names for different models
                for j = 1:length(variables)

                    if strcmp(variables(j), 'lat')
                        latitude = 'lat';
                    elseif strcmp(variables(j), 'latitude')
                        latitude = 'latitude';
                    elseif strcmp(variables(j), 'lon')
                        longitude = 'lon';
                    elseif strcmp(variables(j), 'longitude')
                        longitude = 'longitude';
                    end

                end

                app.xValues = ncread(app.pathToNcFile, latitude)';              % create X value
                app.yValues = ncread(app.pathToNcFile, longitude)';             % create Y values
                [app.xValues, app.yValues] = meshgrid(double(app.xValues), double(app.yValues));
                app.ChangetimeSlider.Limits = [0, ((length(app.zValues(1, 1, :)) - 1))];    % set slider's limit
                app.UITable.Data = [app.tableValues];  % copy values to the app's table
                % if progress bar hasn't been closed
                if isvalid(xbar)
                    delete(xbar);  % delete the figure
                end
            else % do nothing if file isn't found
            end

        end
        
        
        %% Read data from CSV models
        function readCSVValuesToTable(app, pathToFiles)
            app.tableValues = [];   % clear variables
            app.zValues = [];       %

            if app.CSVsFolder.Value == "select a name template for csv files"   % different error messages
                app.CSVsFolder.Value = "Enter a valid path!";
            elseif app.CSVsFolder.Value == "Enter a valid path!"
                app.CSVsFolder.Value = "Enter a valid path!";
            else        % if no erros procced to reading the data
                xbar = waitbar(0, 'Loading data');      % start a progress bar
                % assigns default template names
                if app.ChooseEnsembleForCombinedModelButtonGroup.SelectedObject.Tag == "1"
                    nameTemplate = '24HR_Orig_*.csv';
                    app.CSVmodelsnametemplateEditField.Value = nameTemplate;
                elseif app.ChooseEnsembleForCombinedModelButtonGroup.SelectedObject.Tag == "2"
                    nameTemplate = '24HR_CBE_*.csv';
                    app.CSVmodelsnametemplateEditField.Value = nameTemplate;
                end
                % creates a valid path to csv models 
                dirTemplate = strcat(pathToFiles,filesep, app.CSVmodelsnametemplateEditField.Value); %user may alter template name
                sprintf("selected button: %s", app.ChooseEnsembleForCombinedModelButtonGroup.SelectedObject.Tag);
                fileDirectory = dir(dirTemplate);
                % iterate through all models and collect data
                for k = 1:length(fileDirectory)
                    formatSpec = "Table size from hour no. %d:00 : %s";
                    file = fileDirectory(k).name;
                    Z = [];
                    Z = readtable([strcat(pathToFiles, filesep,file)]);
                    Z = table2array(Z);
                    Z = Z';
                    typeof = size(Z);
                    matrixSize = "%d x %d";
                    a = compose(matrixSize, typeof(1, 1), typeof(1, 2));
                    value = compose(formatSpec, (k - 1), a);
                    app.tableValues = [app.tableValues; value];
                    app.zValues(:, :, k) = Z;
                    if isvalid(xbar) % if progress bar exists, handle is progression
                        waitbar(k / length(fileDirectory), xbar, strcat('In progress (', string(k / length(fileDirectory) * 100), '%)'));
                    else
                        continue
                    end
                end
                app.xValues = 69.95:-0.1:30.05; % create X value
                app.yValues = -24.95:0.1:44.95; %% create Y values
                [app.xValues, app.yValues] = meshgrid(double(app.xValues), double(app.yValues));
                app.ChangetimeSlider.Limits = [0, ((length(fileDirectory))-1 )];   % change slider limit based on amount of read models
                app.UITable.Data = [app.tableValues]; % copy data to UI's table
                if isvalid(xbar)        % close progress bar if any exists
                    delete(xbar);
                end
            end
        end
        
        %% Collect models is used when nc file has been chosen
        function collectModels(app)
            if ~isletter(app.pathToNcFile)  % if nc file exists
            else
                variables = {ncinfo(app.pathToNcFile).Variables.Name};
                app.ChooseModelDropDown.Items = {};  % clean the list every time new file is being loaded
                for i = 1:length(variables)
                    if strcmp(variables(i), 'lat')              % skip unnecessary values 
                        continue;                                
                    elseif strcmp(variables(i), 'latitude')    
                        continue;
                    elseif strcmp(variables(i), 'lon')
                        continue;
                    elseif strcmp(variables(i), 'longitude')
                        continue;
                    elseif strcmp(variables(i), 'hour')
                        continue;
                    elseif strcmp(variables(i), 'time')
                        continue;
                    else            % add to dropdown list only valid variables
                        app.ChooseModelDropDown.Items = [app.ChooseModelDropDown.Items variables(i)];
                    end
                end
            end
        end
        
        %% Adds colorbar to any object passed as argument
        function c = addColorbar(app, toFigure)
            c = colorbar(toFigure);
            c.Label.String = 'Ozone concentration (ppbv )';
            title(c, 'ppbv')
            c.Position(4) = 0.6 * c.Position(4);
            c.Position(1) = 0.95 * c.Position(1);
            c.Position = c.Position + [.05 .2 0 0];
        end
        
        %% Changes map's color theme
        function mapColourAccessibility(app)
            switch app.ChangeColourAccessibilityButtonGroup.SelectedObject.Tag
                case '0'
                    colormap(app.ax1.Parent, 'jet');
                    colormap(app.UIAxes, 'jet');
                case '1'
                    colormap(app.ax1.Parent, 'cool');
                    colormap(app.UIAxes, 'cool');
                case '2'
                    colormap(app.ax1.Parent, 'winter');
                    colormap(app.UIAxes, 'winter');
                case '3'
                    colormap(app.ax1.Parent, 'copper');
                    colormap(app.UIAxes, 'copper');
                case '4'
                    colormap(app.UIAxes, 'bone');
                    colormap(app.ax1.Parent, 'bone');
            end

        end

    end
    
    %% Callbacks that handle component events
    methods (Access = public)
        % Code that executes after component creation
        function startupFcn(app, fileChooser)
            if nargin == 0
                disp("zero")
            elseif nargin == 1          % decides whether app is ran by testing unit 
                app.fileChooser = DefaultFileChooser;   % or by user
                app.pathFinder = PathFinder;
                disp("one")
            else
                app.fileChooser = fileChooser;
                app.pathFinder = fileChooser;
                disp("more")
            end
        end

        % Button pushed function: GenerateaMapButton
        function GenerateaMapButtonPushed(app, event)
            clf;        % clears figure
            app.GenerateaMapButton.Enable = "off"; % when clicked, turn off the button
            if isempty(app.tableValues)             % if data table is empty then 
                app.GenerateaMapButton.Enable = "on";   % leav it active
            else
                generateMap(app);       % if everything's ok, run the command
            end

        end

        % Value changed function: ChangetimeSlider
        function ChangetimeSliderValueChanged(app, event)

            if ~isempty(app.theMaps)        % if any maps have been plotted, change displayed map 
                set(app.ChangetimeSlider, 'Value', round(app.ChangetimeSlider.Value)); % set slider exact number
                cla(app.UIAxes, 'reset');       % clean the figure
                axis(app.UIAxes, 'off');
                set(app.theMaps(:), 'Visible', 'off');
                set(app.theMaps(app.ChangetimeSlider.Value + 1), 'Visible', 'on');
                copyobj(app.ax1.Children, app.UIAxes);
                theTitle = sprintf('Europe at %.f:00', app.ChangetimeSlider.Value);
                title(app.UIAxes, theTitle);
                app.mapColourAccessibility();       % check which color theme is selected
                app.addColorbar(app.UIAxes);        % add proper colorbar
                app.SliderPreviousValue = app.ChangetimeSlider.Value + 1;  % remeber previous value
            else
            end

        end

        % Button pushed function: UploadanNCfileButton
        function UploadanNCfileButtonPushed(app, fileChooser)
            [file, folder, status] = fileChooser.uigetfile('*.nc');   % selects file with external file chooser
            [app.NcFile.Value, app.pathToNcFile] = deal(fullfile(folder, file));    % creates the path and assigns it to 2 variables
            if status
                collectModels(app);     % triggers function to collect model names
            else
                app.NcFile.Value = "Enter a valid path!";   % if closed, displays error message
            end
        end

        % Button pushed function: ChoosefolderwithCSVmodelsButton
        function ChoosefolderwithCSVmodelsButtonPushed(app, pathFinder)
            path = pathFinder.getdir();
            if ~isempty(app.CSVsFolder.Value)
                if path ~= 0    % if path is valid save in text field
                    app.CSVsFolder.Value = '';
                    app.CSVsFolder.Value = path;
                else    % if not, display error message
                    app.CSVsFolder.Value = "Enter a valid path!";
                end
            else
                app.CSVsFolder.Value = 'Enter a valid path!';
            end

        end

        % Button pushed function: NCLoadDataButton
        % when pressed cleans all variables and calls right function
        function NCLoadDataButtonPushed(app, event)
            cla(app.UIAxes, 'reset');
            axis(app.UIAxes, 'off');
            app.tableValues = [];
            app.theMaps = [];
            app.UITable.Data = [];
            if isempty(app.NcFile.Value)  % triggers error message when nc file wasn't selected
                app.NcFile.Value = "Enter a valid path!";
            elseif ~isletter(app.NcFile.Value)
                app.NcFile.Value = "Enter a valid path!";
            else
                readNcValuesToTable(app, app.NcFile.Value);
            end

        end

        % Button pushed function: CSVLoadDataButton
        % when pressed cleans all variables and calls right function
        function CSVLoadDataButtonPushed(app, event)
            cla(app.UIAxes, 'reset');       
            axis(app.UIAxes, 'off');
            app.tableValues = [];
            app.theMaps = [];
            app.UITable.Data = [];
            if isempty(app.CSVsFolder.Value) % triggers error message when nc file wasn't selected
                app.CSVsFolder.Value = "Enter a valid path!";
            elseif ~isletter(app.CSVsFolder.Value)
                app.CSVsFolder.Value = "Enter a valid path!";
            else
                readCSVValuesToTable(app, app.CSVsFolder.Value);
            end
        end

        % Selection changed function:
        % ChangeColourAccessibilityButtonGroup
        function ChangeColourAccessibilityButtonGroupSelectionChanged(app, event)
            if ~isempty(app.theMaps)    % if there's no generated maps,
                app.mapColourAccessibility();
            else                        % sets values back to default
                app.DefaultButton.Value = true;
            end

        end

        % Button pushed function: PlayButton
        % Play button allows user to play a presentation in app's figure
        % window. User may switch between simple images/frames show and real figures show
        % !!! Real figures, require more computation power !!! but it is
        % better quality
        function PlayButtonPushed(app, event)
            app.PlayButton.Enable = "off";      % at the start, function resets and cleans
            cla(app.UIAxes, 'reset');           % previous app's figure
            axis(app.UIAxes, 'off');
            set(app.theMaps(app.ChangetimeSlider.Value + 1), 'Visible', 'off');
            if isempty(app.theMaps) || isempty(app.tableValues)     % if no maps have been read, do nothing
            elseif strcmp(app.Switchpresantationmode.Value, 'Images')   % checks switch position
                for time = 1:25  % should be updated to more dynamic values, but requires more work than expected
                    cla(app.UIAxes, 'reset');
                    axis(app.UIAxes, 'off');
                    set(app.theMaps(time), 'Visible', 'off');           % switches images and slider's position
                    set(app.ChangetimeSlider, 'Value', time - 1);
                    theTitle = sprintf('Europe at %.f:00', time - 1);
                    title(app.UIAxes, theTitle);        % add title to each frame
                    if time == 25                       % if loop hits last element, repeat last item
                        imshow(app.imgArray(time).cdata, 'parent', app.UIAxes)
                    else                                % else iterate through all saved frames
                        imshow(app.imgArray(time).cdata, 'parent', app.UIAxes)
                        app.mapColourAccessibility();
                    end
                    pause(1);   % pause for a sec at the end 
                end
            elseif strcmp(app.Switchpresantationmode.Value, 'Figures')
                for time = 1:25             % the same functionality as above
                    disp(app.stopPlay)
                    cla(app.UIAxes, 'reset');
                    axis(app.UIAxes, 'off');
                    set(app.theMaps(time), 'Visible', 'off');
                    set(app.ChangetimeSlider, 'Value', time - 1);
                    theTitle = sprintf('Europe at %.f:00', time - 1);
                    title(app.UIAxes, theTitle);

                    if time == 25       % if loop reaches last figure repeat last figure
                        set(app.theMaps(time), 'Visible', 'on');
                        theTitle = sprintf('Europe at %.f:00', 0);
                        title(app.UIAxes, theTitle);
                        copyobj(app.ax1.Children, app.UIAxes);
                        app.mapColourAccessibility();
                        app.addColorbar(app.UIAxes);
                    else                % else iterate through all figures
                        if time == 1
                            set(app.theMaps(:), 'Visible', 'off');
                        end
                        app.mapColourAccessibility();
                        set(app.theMaps(time), 'Visible', 'on');
                        theTitle = sprintf('Europe at %.f:00', time - 1);
                        title(app.UIAxes, theTitle);
                        copyobj(app.ax1.Children, app.UIAxes);
                        app.mapColourAccessibility();
                        app.addColorbar(app.UIAxes);
                        set(app.theMaps(time), 'Visible', 'off');
                    end
                    pause(1);           % pauses for one sec at the end
                end

            end
            % at the end, functions resets app's window figure and displays
            % default, first figure- sets app to default state just like after
            % map generation.
            cla(app.UIAxes, 'reset');
            axis(app.UIAxes, 'off');
            set(app.theMaps(25), 'Visible', 'off');
            set(app.ChangetimeSlider, 'Value', 0);
            set(app.theMaps(1), 'Visible', 'on');
            theTitle = sprintf('Europe at %.f:00', 0);
            title(app.UIAxes, theTitle);
            copyobj(app.ax1.Children, app.UIAxes);
            app.mapColourAccessibility();
            app.addColorbar(app.UIAxes);
            app.PlayButton.Enable = "on";
        end

        % Button pushed function: ExportvideofileButton
        % This function exports video of given name to chosen destination
        % with a given resolution. The higher resolution, the longer it
        % takes to export a video.
        function ExportvideofileButtonPushed(app, event)
            if isempty(app.theMaps) || isempty(app.tableValues)
                [app.SaveasEditField.Value, app.SaveDestionation.Value] = deal("You need to load the data")
            elseif isempty(app.SaveDestionation.Value)
                app.SaveDestionation.Value = "Enter a valid path!";
            elseif isempty(app.SaveasEditField.Value)
                app.SaveasEditField.Value = "Enter a valid name!";
            else
                v = VideoWriter(strcat(app.SaveDestionation.Value, app.SaveasEditField.Value, '.avi'));
                v.FrameRate = 4;
                open(v);                % start video composing
                switch app.SelectresolutionDropDown.Value
                    case "Max"
                        resolution = get(0, "ScreenSize");
                    case "640x480"
                        resolution = [0, 0, 640, 480];
                    case "1024x576"
                        resolution = [0, 0, 1024, 576];
                    case "1280x720"
                        resolution = [0, 0, 1280, 720];
                end             % set 2nd figure to selected resolution, figure's resolution == video's resolution
                set(gcf, 'units', 'pixels', 'position', [0, 0, resolution(3), resolution(4)]);
                xbar = waitbar(0, 'Exporting the video');   % initiates progress bar
                for time = 1:length(app.zValues(1, 1, :))   % for loop switches what map needs to be displayed
                    set(0, 'currentfigure', app.ax1.Parent);    % and then takes the frames, composing a video 
                    theTitle = sprintf('Europe at %.f:00', time - 1);
                    title(app.ax1, theTitle);
                    if time == 1
                        set(app.theMaps(:), 'Visible', 'off');
                    end
                    set(app.theMaps(time), 'Visible', 'on')
                    frame = getframe(gcf);
                    writeVideo(v, frame);
                    set(app.theMaps(time), 'Visible', 'off');
                    if isvalid(xbar)        % if progress bar hasn't been closed continue displaying it
                        waitbar(time / (length(app.zValues(1, 1, :))), xbar, strcat('In progress (', string(time / (length(app.zValues(1, 1, :))) * 100), '%)'));
                    else                    % do nothing if it's closed
                        continue
                    end
                end
                if isvalid(xbar)    
                    close(xbar);    % close progress bar if it hasn't been closed
                end
                close(v)            % close video composition
                set(app.theMaps(1), 'Visible', 'on'); % set first map visible
            end
        end

        % Button pushed function: SelectsavedestinationButton
        function SelectsavedestinationButtonPushed(app, pathFinder)
            path = pathFinder.getdir();         % handles finding save destination
            if path ~= 0                        % if not empty
                app.SaveDestionation.Value = '';    % clear the field
                app.SaveDestionation.Value = strcat(path, "/"); % enter selected directory
            else        % in case of any error display an error message
                app.SaveDestionation.Value = "Enter a valid path!"; 
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1368 720];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Ozone levels over Europe')
            xlabel(app.UIAxes, '')
            ylabel(app.UIAxes, '')
            app.UIAxes.XLim = [0 1];
            app.UIAxes.YLim = [0 1];
            app.UIAxes.ZLim = [0 1];
            app.UIAxes.XTick = [];
            app.UIAxes.YColor = 'none';
            app.UIAxes.YTick = [];
            app.UIAxes.Position = [510 187 850 522];

            % Create GenerateaMapButton
            app.GenerateaMapButton = uibutton(app.UIFigure, 'push');
            app.GenerateaMapButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateaMapButtonPushed, true);
            app.GenerateaMapButton.BackgroundColor = [0.6588 0.9608 0.498];
            app.GenerateaMapButton.FontSize = 18;
            app.GenerateaMapButton.Position = [290 244 210 60];
            app.GenerateaMapButton.Text = 'Generate a Map';

            % Create ChangetimeLabel
            app.ChangetimeLabel = uilabel(app.UIFigure);
            app.ChangetimeLabel.HorizontalAlignment = 'right';
            app.ChangetimeLabel.Position = [755 153 77 22];
            app.ChangetimeLabel.Text = {'Change time:'; ''};

            % Create ChangetimeSlider
            app.ChangetimeSlider = uislider(app.UIFigure);
            app.ChangetimeSlider.Limits = [0 24];
            app.ChangetimeSlider.MajorTicks = [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24];
            app.ChangetimeSlider.MajorTickLabels = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', ''};
            app.ChangetimeSlider.ValueChangedFcn = createCallbackFcn(app, @ChangetimeSliderValueChanged, true);
            app.ChangetimeSlider.MinorTicks = [1 5 10 15 20];
            app.ChangetimeSlider.Position = [853 162 499 3];

            % Create UITable
            app.UITable = uitable(app.UIFigure);
            app.UITable.ColumnName = {'Read Values:'};
            app.UITable.RowName = {};
            app.UITable.Position = [10 24 269 290];

            % Create OrextractdatafromcsvmodelsPanel
            app.OrextractdatafromcsvmodelsPanel = uipanel(app.UIFigure);
            app.OrextractdatafromcsvmodelsPanel.TitlePosition = 'centertop';
            app.OrextractdatafromcsvmodelsPanel.Title = 'Or extract data from csv models';
            app.OrextractdatafromcsvmodelsPanel.FontSize = 16;
            app.OrextractdatafromcsvmodelsPanel.Position = [10 325 490 247];

            % Create ChoosefolderwithCSVmodelsButton
            app.ChoosefolderwithCSVmodelsButton = uibutton(app.OrextractdatafromcsvmodelsPanel, 'push');
            app.ChoosefolderwithCSVmodelsButton.ButtonPushedFcn = @(src, evt)ChoosefolderwithCSVmodelsButtonPushed(app, app.pathFinder); %createCallbackFcn(app, @ChoosefolderwithCSVmodelsButtonPushed, true);
            app.ChoosefolderwithCSVmodelsButton.Position = [10 178 120 36];
            app.ChoosefolderwithCSVmodelsButton.Text = {'Choose folder with '; 'CSV models'};

            % Create CSVsFolder
            app.CSVsFolder = uieditfield(app.OrextractdatafromcsvmodelsPanel, 'text');
            app.CSVsFolder.Position = [140 185 340 22];
            app.CSVsFolder.Value = 'select a name template for csv files';

            % Create ChooseEnsembleForCombinedModelButtonGroup
            app.ChooseEnsembleForCombinedModelButtonGroup = uibuttongroup(app.OrextractdatafromcsvmodelsPanel);
            %app.ChooseEnsembleForCombinedModelButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ChooseEnsembleForCombinedModelButtonGroupSelectionChanged, true);
            app.ChooseEnsembleForCombinedModelButtonGroup.Title = 'Choose Ensemble For Combined Model';
            app.ChooseEnsembleForCombinedModelButtonGroup.Position = [10 90 470 68];

            % Create OriginButton
            app.OriginButton = uiradiobutton(app.ChooseEnsembleForCombinedModelButtonGroup);
            app.OriginButton.Tag = '1';
            app.OriginButton.Text = 'Origin';
            app.OriginButton.Position = [11 22 58 22];
            app.OriginButton.Value = true;

            % Create ClusterBasedEnsembleButton
            app.ClusterBasedEnsembleButton = uiradiobutton(app.ChooseEnsembleForCombinedModelButtonGroup);
            app.ClusterBasedEnsembleButton.Tag = '2';
            app.ClusterBasedEnsembleButton.Text = 'Cluster Based Ensemble';
            app.ClusterBasedEnsembleButton.Position = [11 0 154 22];

            % Create CSVmodelsnametemplateEditFieldLabel
            app.CSVmodelsnametemplateEditFieldLabel = uilabel(app.OrextractdatafromcsvmodelsPanel);
            app.CSVmodelsnametemplateEditFieldLabel.Position = [10 51 160 23];
            app.CSVmodelsnametemplateEditFieldLabel.Text = 'CSV model''s name template:';

            % Create CSVmodelsnametemplateEditField
            app.CSVmodelsnametemplateEditField = uieditfield(app.OrextractdatafromcsvmodelsPanel, 'text');
            app.CSVmodelsnametemplateEditField.Position = [174 51 305 22];

            % Create CSVLoadDataButton
            app.CSVLoadDataButton = uibutton(app.OrextractdatafromcsvmodelsPanel, 'push');
            app.CSVLoadDataButton.ButtonPushedFcn = createCallbackFcn(app, @CSVLoadDataButtonPushed, true);
            app.CSVLoadDataButton.Position = [380 12 100 24];
            app.CSVLoadDataButton.Text = {'Load Data'; ''};

            % Create ImportdatafromanncfilePanel
            app.ImportdatafromanncfilePanel = uipanel(app.UIFigure);
            app.ImportdatafromanncfilePanel.TitlePosition = 'centertop';
            app.ImportdatafromanncfilePanel.Title = 'Import data from an nc file';
            app.ImportdatafromanncfilePanel.FontSize = 16;
            app.ImportdatafromanncfilePanel.Position = [10 587 490 113];

            % Create NcFile
            app.NcFile = uieditfield(app.ImportdatafromanncfilePanel, 'text');
            app.NcFile.Position = [130 55 350 22];

            % Create UploadanNCfileButton
            app.UploadanNCfileButton = uibutton(app.ImportdatafromanncfilePanel, 'push');
            app.UploadanNCfileButton.ButtonPushedFcn = @(src, evt)UploadanNCfileButtonPushed(app, app.fileChooser); %createCallbackFcn(app, @UploadanNCfileButtonPushed, true);
            app.UploadanNCfileButton.Position = [10 54 110 25];
            app.UploadanNCfileButton.Text = 'Upload an NC file :';

            % Create NCLoadDataButton
            app.NCLoadDataButton = uibutton(app.ImportdatafromanncfilePanel, 'push');
            app.NCLoadDataButton.ButtonPushedFcn = createCallbackFcn(app, @NCLoadDataButtonPushed, true);
            app.NCLoadDataButton.Position = [380 11 100 24];
            app.NCLoadDataButton.Text = {'Load Data'; ''};

            % Create ChooseModelDropDownLabel
            app.ChooseModelDropDownLabel = uilabel(app.ImportdatafromanncfilePanel);
            app.ChooseModelDropDownLabel.HorizontalAlignment = 'center';
            app.ChooseModelDropDownLabel.Position = [10 12 110 22];
            app.ChooseModelDropDownLabel.Text = {'Choose  Model'; ''};

            % Create ChooseModelDropDown
            app.ChooseModelDropDown = uidropdown(app.ImportdatafromanncfilePanel);
            app.ChooseModelDropDown.Items = {};
            app.ChooseModelDropDown.ValueChangedFcn = createCallbackFcn(app, @ChooseModelDropDownValueChanged, true);
            app.ChooseModelDropDown.Position = [130 12 177 22];
            app.ChooseModelDropDown.Value = {};

            % Create ChangeColourAccessibilityButtonGroup
            app.ChangeColourAccessibilityButtonGroup = uibuttongroup(app.UIFigure);
            app.ChangeColourAccessibilityButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ChangeColourAccessibilityButtonGroupSelectionChanged, true);
            app.ChangeColourAccessibilityButtonGroup.TitlePosition = 'centertop';
            app.ChangeColourAccessibilityButtonGroup.Title = 'Change Colour Accessibility:';
            app.ChangeColourAccessibilityButtonGroup.FontSize = 14;
            app.ChangeColourAccessibilityButtonGroup.Position = [290 24 210 210];

            % Create DefaultButton
            app.DefaultButton = uitogglebutton(app.ChangeColourAccessibilityButtonGroup);
            app.DefaultButton.Tag = '0';
            app.DefaultButton.Text = 'Default';
            app.DefaultButton.BackgroundColor = [0.9412 0.9412 0.9412];
            app.DefaultButton.Position = [10 148 190 25];
            app.DefaultButton.Value = true;

            % Create DeuteanopiagreenweaknessButton
            app.DeuteanopiagreenweaknessButton = uitogglebutton(app.ChangeColourAccessibilityButtonGroup);
            app.DeuteanopiagreenweaknessButton.Tag = '1';
            app.DeuteanopiagreenweaknessButton.Text = 'Deuteanopia (green weakness)';
            app.DeuteanopiagreenweaknessButton.Position = [10 113 190 25];

            % Create ProtanopiaredweaknessButton
            app.ProtanopiaredweaknessButton = uitogglebutton(app.ChangeColourAccessibilityButtonGroup);
            app.ProtanopiaredweaknessButton.Tag = '2';
            app.ProtanopiaredweaknessButton.Text = 'Protanopia (red weakness)';
            app.ProtanopiaredweaknessButton.Position = [10 78 190 25];

            % Create TritanopiablueyellowweaknessButton
            app.TritanopiablueyellowweaknessButton = uitogglebutton(app.ChangeColourAccessibilityButtonGroup);
            app.TritanopiablueyellowweaknessButton.Tag = '3';
            app.TritanopiablueyellowweaknessButton.Text = 'Tritanopia (blue/yellow weakness)';
            app.TritanopiablueyellowweaknessButton.Position = [10 43 190 25];

            % Create MonochromacyButton
            app.MonochromacyButton = uitogglebutton(app.ChangeColourAccessibilityButtonGroup);
            app.MonochromacyButton.Tag = '4';
            app.MonochromacyButton.Text = 'Monochromacy';
            app.MonochromacyButton.Position = [10 8 190 25];

            % Create ExportvideoPanel
            app.ExportvideoPanel = uipanel(app.UIFigure);
            app.ExportvideoPanel.Title = 'Export video';
            app.ExportvideoPanel.Position = [530 24 829 90];

            % Create SelectresolutionDropDownLabel
            app.SelectresolutionDropDownLabel = uilabel(app.ExportvideoPanel);
            app.SelectresolutionDropDownLabel.HorizontalAlignment = 'right';
            app.SelectresolutionDropDownLabel.Position = [592 41 94 22];
            app.SelectresolutionDropDownLabel.Text = 'Select resolution';

            % Create SelectresolutionDropDown
            app.SelectresolutionDropDown = uidropdown(app.ExportvideoPanel);
            app.SelectresolutionDropDown.Items = {'640x480', '1024x576', '1280x720', 'Max'};
            app.SelectresolutionDropDown.Position = [701 41 102 22];
            app.SelectresolutionDropDown.Value = '640x480';

            % Create SaveasEditFieldLabel
            app.SaveasEditFieldLabel = uilabel(app.ExportvideoPanel);
            app.SaveasEditFieldLabel.HorizontalAlignment = 'right';
            app.SaveasEditFieldLabel.Position = [19 41 56 22];
            app.SaveasEditFieldLabel.Text = 'Save as: ';

            % Create SaveasEditField
            app.SaveasEditField = uieditfield(app.ExportvideoPanel, 'text');
            app.SaveasEditField.Position = [81 41 165 22];

            % Create ExportvideofileButton
            app.ExportvideofileButton = uibutton(app.ExportvideoPanel, 'push');
            app.ExportvideofileButton.ButtonPushedFcn = createCallbackFcn(app, @ExportvideofileButtonPushed, true);
            app.ExportvideofileButton.Position = [702 11 101 22];
            app.ExportvideofileButton.Text = 'Export video file';

            % Create videoFormat
            app.videoFormat = uilabel(app.ExportvideoPanel);
            app.videoFormat.HorizontalAlignment = 'right';
            app.videoFormat.Position = [245 41 25 22];
            app.videoFormat.Text = '.avi';

            % Create SelectsavedestinationButton
            app.SelectsavedestinationButton = uibutton(app.ExportvideoPanel, 'push');
            app.SelectsavedestinationButton.ButtonPushedFcn = @(src, evt)SelectsavedestinationButtonPushed(app, app.pathFinder); %createCallbackFcn(app, @SelectsavedestinationButtonPushed, true);
            app.SelectsavedestinationButton.Position = [286.5 41 139 22];
            app.SelectsavedestinationButton.Text = 'Select save destination';

            % Create SaveDestionation
            app.SaveDestionation = uieditfield(app.ExportvideoPanel, 'text');
            app.SaveDestionation.Position = [430 41 156 22];

            % Create PlayButton
            app.PlayButton = uibutton(app.UIFigure, 'push');
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);
            app.PlayButton.Enable = 'off';
            app.PlayButton.Position = [522 130 61 46];
            app.PlayButton.Text = 'Play';

            % Create SwitchpresantationmodeLabel
            app.SwitchpresantationmodeLabel = uilabel(app.UIFigure);
            app.SwitchpresantationmodeLabel.HorizontalAlignment = 'center';
            app.SwitchpresantationmodeLabel.Position = [604 123 144 22];
            app.SwitchpresantationmodeLabel.Text = 'Switch presantation mode';

            % Create Switchpresantationmode
            app.Switchpresantationmode = uiswitch(app.UIFigure, 'slider');
            app.Switchpresantationmode.Items = {'Images', 'Figures'};
            app.Switchpresantationmode.ValueChangedFcn = createCallbackFcn(app, @SwitchpresantationmodeValueChanged, true);
            app.Switchpresantationmode.Position = [652 155 47 21];
            app.Switchpresantationmode.Value = 'Images';
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)
        % Construct app
        function app = gui_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))
            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)
            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end

    end

end
