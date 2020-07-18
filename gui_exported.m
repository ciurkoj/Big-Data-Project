classdef gui_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        UIAxes                          matlab.ui.control.UIAxes
        GenerateaMapButton              matlab.ui.control.Button
        ChangetimeLabel                 matlab.ui.control.Label
        ChangetimeSlider                matlab.ui.control.Slider
        UITable                         matlab.ui.control.Table
        OrextractdatafromcsvmodelsPanel  matlab.ui.container.Panel
        ChoosefolderwithCSVmodelsButton  matlab.ui.control.Button
        CSVsFolder                      matlab.ui.control.EditField
        ChooseEnsembleForCombinedModelButtonGroup  matlab.ui.container.ButtonGroup
        OriginButton                    matlab.ui.control.RadioButton
        ClusterBasedEnsembleButton      matlab.ui.control.RadioButton
        CSVmodelsnametemplateEditFieldLabel  matlab.ui.control.Label
        CSVmodelsnametemplateEditField  matlab.ui.control.EditField
        CSVLoadDataButton               matlab.ui.control.Button
        ImportdatafromanncfilePanel     matlab.ui.container.Panel
        NcFile                          matlab.ui.control.EditField
        UploadanNCfileButton            matlab.ui.control.Button
        NCLoadDataButton                matlab.ui.control.Button
        ChooseModelDropDownLabel        matlab.ui.control.Label
        ChooseModelDropDown             matlab.ui.control.DropDown
        ChangeColourAccessibilityButtonGroup  matlab.ui.container.ButtonGroup
        DefaultButton                   matlab.ui.control.ToggleButton
        DeuteanopiagreenweaknessButton  matlab.ui.control.ToggleButton
        ProtanopiaredweaknessButton     matlab.ui.control.ToggleButton
        TritanopiablueyellowweaknessButton  matlab.ui.control.ToggleButton
        MonochromacyButton              matlab.ui.control.ToggleButton
        ExportvideoPanel                matlab.ui.container.Panel
        SelectresolutionDropDownLabel   matlab.ui.control.Label
        SelectresolutionDropDown        matlab.ui.control.DropDown
        SaveasEditFieldLabel            matlab.ui.control.Label
        SaveasEditField                 matlab.ui.control.EditField
        ExportvideofileButton           matlab.ui.control.Button
        videoFormat                     matlab.ui.control.Label
        SelectsavedestinationButton     matlab.ui.control.Button
        SaveDestionation                matlab.ui.control.EditField
        PlayButton                      matlab.ui.control.Button
    end

    
    properties (Access = private)
        tableValues;
        xValues=[];
        yValues=[];
        zValues=[];
        pathToNcFile;
        pathToCBEs;
        csvNameTemplate;
        theNcFile;
        colorAccessibilityOption;
        theMaps=[];
        SliderPreviousValue;
        ax1;
    end
    
    methods (Access = private)
        
        function generateMap(app)
            cla(app.UIAxes,'reset');
            axis(app.UIAxes,'off');
            app.ax1 = worldmap('Europe');
            fig1 = app.ax1.Parent;
            set(fig1,'Visible','off')
            land = shaperead('landareas', 'UseGeoCoords', true);
            geoshow([land.Lat],[land.Lon],'Color','k');
            lakes = shaperead('worldlakes', 'UseGeoCoords', true);
            geoshow(lakes, 'FaceColor', 'blue');
            cities = shaperead('worldcities', 'UseGeoCoords', true);
            geoshow(cities, 'Marker', '.', 'Color', 'red');            
            
            
            xbar=waitbar(0,'Loading data');
            app.theMaps=[];
            for time = 1 : length(app.zValues(1,1,:))
                theTitle = sprintf('Europe at %.f:00', time-1);
                title(theTitle);
                set(0, 'currentfigure',app.ax1.Parent);
                app.theMaps= [app.theMaps, surfm(app.xValues,app.yValues,app.zValues(:,:,time), 'EdgeColor','none','FaceAlpha', 0.7)];
                set(app.theMaps(time),'Visible', 'off');
                if isvalid(xbar)
                    waitbar(time/(length(app.zValues(1,1,:))),xbar,strcat('In progress (',string(time/(length(app.zValues(1,1,:)))*100),'%)'));
                else
                    continue
                end
            end
            
            theTitle = sprintf('Europe at %.f:00', app.ChangetimeSlider.Value);
            title(app.UIAxes,theTitle);
            set(app.theMaps(app.ChangetimeSlider.Value+1),'Visible','on');
            app.SliderPreviousValue = (app.ChangetimeSlider.Value)+1;

            app.ChangeColourAccessibilityButtonGroupSelectionChanged();
            app.addColorbar();
            copyobj(app.ax1.Children, app.UIAxes);
            if isvalid(xbar)
                close(xbar);
            end
            fig1 = app.ax1.Parent;
            set(fig1,'Visible','off');
            
        end
        
        function readNcValuesToTable(app, pathToNcFile)
            if ~isempty(pathToNcFile)
                app.tableValues= [];
                xbar=waitbar(0,'Loading data');
                app.zValues= ncread(pathToNcFile, app.ChooseModelDropDown.Value);
                formatSpec = "Table size from hour no. %d:00 : %s";
                typeof = size(app.zValues);
                matrixSize= "%d x %d";
                a = compose(matrixSize, typeof(1,1),typeof(1,2));
                for k=0 : (length(app.zValues(1,1,:))-1)
                    value=compose(formatSpec,k,a);
                    app.tableValues=[app.tableValues; value];
                    if isvalid(xbar)
                        waitbar(k/(length(app.zValues(1,1,:))-1),xbar,strcat('In progress (',string(k/(length(app.zValues(1,1,:))-1)*100),'%)'));
                    else
                        continue
                    end
                end
    
                variables = {ncinfo(pathToNcFile).Variables.Name};
    
                for j=1 : length(variables)
                    if strcmp(variables(j),'lat')
                        latitude = 'lat';
                    elseif strcmp(variables(j),'latitude')
                        latitude = 'latitude';
                    elseif strcmp(variables(j), 'lon')
                        longitude = 'lon';
                    elseif strcmp(variables(j), 'longitude')
                        longitude = 'longitude';
                    end
                end
                app.xValues = ncread(app.pathToNcFile, latitude)' ; % create X value
    
                app.yValues = ncread(app.pathToNcFile, longitude)';% create Y values
                [app.xValues,app.yValues] = meshgrid(double(app.xValues), double(app.yValues));
                app.ChangetimeSlider.Limits = [0 ((length(app.zValues(1,1,:))-1))];
                if isvalid(xbar)
                    delete(xbar);
                end
                app.UITable.Data = [app.tableValues];
            else
            end
        end
        
        function readCSVValuesToTable(app, pathToFiles)
            app.tableValues= [];
            app.zValues= [];
            if app.CSVsFolder.Value == "select a name template for csv files"
                app.CSVsFolder.Value = "Enter a valid path!";
            elseif app.CSVsFolder.Value == "Enter a valid path!"
                app.CSVsFolder.Value = "Enter a valid path!";
            
            else
                xbar=waitbar(0,'Loading data');
                if app.ChooseEnsembleForCombinedModelButtonGroup.SelectedObject.Tag == "1" 
                    nameTemplate = '24HR_Orig_*.csv';
                    app.CSVmodelsnametemplateEditField.Value = nameTemplate;
                elseif app.ChooseEnsembleForCombinedModelButtonGroup.SelectedObject.Tag == "2"
                    nameTemplate = '24HR_CBE_*.csv';
                    app.CSVmodelsnametemplateEditField.Value = nameTemplate;
                end
            
                dirTemplate = strcat(pathToFiles,app.CSVmodelsnametemplateEditField.Value);
      
                sprintf("selected button: %s",app.ChooseEnsembleForCombinedModelButtonGroup.SelectedObject.Tag);
                fileDirectory = dir(dirTemplate);
                for k = 1 : length(fileDirectory)
                    formatSpec = "Table size from hour no. %d:00 : %s";
                    file = fileDirectory(k).name;
                    Z=[];
                    Z = readtable([pathToFiles,file]);
                    Z = table2array(Z);
                    Z=Z';
                    typeof = size(Z);
                    matrixSize= "%d x %d";
                    a = compose(matrixSize, typeof(1,1),typeof(1,2));
                    value=compose(formatSpec,(k-1),a);
                    app.tableValues=[app.tableValues; value];
                    app.zValues (:,:,k)=Z;
                    if isvalid(xbar)
                        waitbar(k/length(fileDirectory),xbar,strcat('In progress (',string(k/length(fileDirectory)*100),'%)'));
                    else
                        continue
                    end
                end
                app.xValues = 69.95:-0.1:30.05; % create X value
                app.yValues = -24.95:0.1:44.95;%% create Y values
                [app.xValues,app.yValues] = meshgrid(double(app.xValues), double(app.yValues));
                disp(((length(fileDirectory))-1));
                app.ChangetimeSlider.Limits = [0 ((length(fileDirectory))-1)];
                if isvalid(xbar)
                    delete(xbar);
                end
                
                app.UITable.Data = [app.tableValues];
            end
           
        end

        function collectModels(app)
            if ~isletter(app.pathToNcFile)
                
            else
                variables = {ncinfo(app.pathToNcFile).Variables.Name};
                app.ChooseModelDropDown.Items ={};
                for i=1 : length(variables)
                    if strcmp(variables(i),'lat')
                        continue;
                    elseif strcmp(variables(i),'latitude')
                        continue;
                    elseif strcmp(variables(i), 'lon')
                        continue;
                    elseif strcmp(variables(i), 'longitude')
                        continue;
                    elseif strcmp(variables(i), 'hour')
                        continue;
                    elseif strcmp(variables(i), 'time')
                        continue;
                    else
                        app.ChooseModelDropDown.Items = [app.ChooseModelDropDown.Items variables(i)];
                    end
                end
            end
        end

        
        
        function addColorbar(app)
            c=colorbar(app.UIAxes);
            c.Label.String = 'Ozone concentration (ppbv )';
            title(c, 'ppbv')
            c.Position(4) = 0.6*c.Position(4);
            c.Position(1) = 0.95*c.Position(1);
            c.Position = c.Position + [.05 .2 0 0];
            c=colorbar(app.ax1);
            c.Label.String = 'Ozone concentration (ppbv )';
            title(c, 'ppbv')
            c.Position(4) = 0.6*c.Position(4);
            c.Position(1) = 0.95*c.Position(1);
            c.Position = c.Position + [.05 .25 0 0];
        end
    
    
        function mapColourAccessibility(app)
            switch app.ChangeColourAccessibilityButtonGroup.SelectedObject.Tag
                case '0'
                    colormap (app.ax1.Parent,'jet');
                    colormap (app.UIAxes,'jet');
                case '1'
                    colormap (app.ax1.Parent,'cool');
                    colormap (app.UIAxes,'cool');
                case '2'
                    colormap (app.ax1.Parent,'winter');
                    colormap (app.UIAxes,'winter');
                case '3'
                    colormap (app.ax1.Parent,'copper');
                    colormap (app.UIAxes,'copper');
                case '4'
                    colormap (app.UIAxes, 'bone');
                    colormap (app.ax1.Parent,'bone'); 
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: GenerateaMapButton
        function GenerateaMapButtonPushed(app, event)
            clf; 
            if isempty(app.tableValues)
            else
                generateMap(app); 
            end
        end

        % Value changed function: ChangetimeSlider
        function ChangetimeSliderValueChanged(app, event)
            if ~isempty(app.theMaps)
                set(app.ChangetimeSlider, 'Value', round(app.ChangetimeSlider.Value)); 
                cla(app.UIAxes,'reset');
                axis(app.UIAxes,'off');
                set(app.theMaps(app.SliderPreviousValue),'Visible','off');
                set(app.theMaps(app.ChangetimeSlider.Value+1),'Visible','on');
                
                copyobj(app.ax1.Children, app.UIAxes);
                theTitle = sprintf('Europe at %.f:00', app.ChangetimeSlider.Value);
                title(app.UIAxes,theTitle);
                
                app.mapColourAccessibility();
                app.addColorbar();
                app.SliderPreviousValue = app.ChangetimeSlider.Value+1;
            else
            end
        end

        % Button pushed function: UploadanNCfileButton
        function UploadanNCfileButtonPushed(app, event)
            
            [file, path] = uigetfile('*.nc');
            [app.NcFile.Value, app.pathToNcFile] = deal(fullfile(path, file));
            if ~isempty(app.pathToNcFile)
                collectModels(app);
            else
                app.NcFile.Value ="Enter a valid path!";
            end
        end

        % Button pushed function: ChoosefolderwithCSVmodelsButton
        function ChoosefolderwithCSVmodelsButtonPushed(app, event)
            path = uigetdir();
            if ~isempty(app.CSVsFolder.Value)
                if path ~= 0 
                    app.CSVsFolder.Value = strcat(path,"/");
                else
                    app.CSVsFolder.Value = "select a name template for csv files";
                end    
            else
                app.CSVsFolder.Value = "select a name template for csv files";
            end
        end

        % Selection changed function: 
        % ChooseEnsembleForCombinedModelButtonGroup
        function ChooseEnsembleForCombinedModelButtonGroupSelectionChanged(app, event)

        end

        % Value changed function: ChooseModelDropDown
        function ChooseModelDropDownValueChanged(app, event)
            %app.generateMap(app.ChangetimeSlider.Value);
            
        end

        % Button pushed function: NCLoadDataButton
        function NCLoadDataButtonPushed(app, event)
            cla(app.UIAxes,'reset');
            axis(app.UIAxes,'off');
            app.tableValues = [];
            app.theMaps =[];
            app.UITable.Data =[];
            if isempty(app.NcFile.Value)
                app.NcFile.Value ="Enter a valid path!";

            elseif ~isletter(app.NcFile.Value)
                app.NcFile.Value ="Enter a valid path!";
               
            else
                 readNcValuesToTable(app, app.NcFile.Value);
            end
        end

        % Button pushed function: CSVLoadDataButton
        function CSVLoadDataButtonPushed(app, event)
            cla(app.UIAxes,'reset');
            axis(app.UIAxes,'off');
            app.tableValues = [];
            app.theMaps =[];
            app.UITable.Data =[];
            readCSVValuesToTable(app, app.CSVsFolder.Value);
        end

        % Selection changed function: 
        % ChangeColourAccessibilityButtonGroup
        function ChangeColourAccessibilityButtonGroupSelectionChanged(app, event)
            if ~isempty(app.theMaps)
                app.mapColourAccessibility();
            else  
                app.DefaultButton.Value = true;
            end
        end

        % Button pushed function: PlayButton
        function PlayButtonPushed(app, event)
            if isempty(app.theMaps) || isempty(app.tableValues)
            else
                for time = 1 : 25
                    cla(app.UIAxes,'reset');
                    axis(app.UIAxes,'off');
                    set(app.theMaps(time),'Visible','off');
                    set(app.ChangetimeSlider, 'Value', time-1); 
                    theTitle = sprintf('Europe at %.f:00', time-1);
                    title(app.UIAxes,theTitle);
                    if time == 25
                        set(app.theMaps(time),'Visible','on');
                    else 
                        set(app.theMaps(time+1),'Visible','on');
                    end
                    copyobj(app.ax1.Children, app.UIAxes);
                    app.mapColourAccessibility();
                    app.addColorbar();
                    pause(1);
                end
            end
        end

        % Button pushed function: ExportvideofileButton
        function ExportvideofileButtonPushed(app, event)
            if isempty(app.theMaps) || isempty(app.tableValues) || isempty(app.SaveDestionation.Value)
                app.SaveDestionation.Value = "Enter a valid path!";
            else
                
                v = VideoWriter(strcat(app.SaveDestionation.Value,app.SaveasEditField.Value, '.avi'));
                v.FrameRate = 4;
                open(v);
                switch app.SelectresolutionDropDown.Value
                    case "Max"
                        resolution= get(0,"ScreenSize");
                    case "640x480"
                        resolution = [0,0,640,480];
                    case "1024x576"
                        resolution = [0,0,1024,576];
                    case "1280x720"
                        resolution = [0,0,1280,720];
                end
                set(gcf,'units','pixels','position',[0,0,resolution(3),resolution(4)]);
                xbar=waitbar(0,'Exporting the video');
                for time = 1 : length(app.zValues(1,1,:))
                    set(0, 'currentfigure',app.ax1.Parent);
                    theTitle = sprintf('Europe at %.f:00', time-1);
                    title(app.ax1,theTitle);
                    if time == 1
                        set(app.theMaps(:),'Visible','off');
                    end
                    set(app.theMaps(time), 'Visible', 'on')
                    frame = getframe(gcf);
                    writeVideo(v,frame);
                    set(app.theMaps(time),'Visible','off');
                    if isvalid(xbar)
                        waitbar(time/(length(app.zValues(1,1,:))),xbar,strcat('In progress (',string(time/(length(app.zValues(1,1,:)))*100),'%)'));
                    else
                        continue
                    end
                end
                if isvalid(xbar)
                    close(xbar);
                end
                close(v)
                set(app.theMaps(1),'Visible','on');
            end
        end

        % Button pushed function: SelectsavedestinationButton
        function SelectsavedestinationButtonPushed(app, event)
            path = uigetdir();
            app.SaveDestionation.Value = strcat(path,"/");

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
            app.ChangetimeLabel.Position = [582 154 77 22];
            app.ChangetimeLabel.Text = {'Change time:'; ''};

            % Create ChangetimeSlider
            app.ChangetimeSlider = uislider(app.UIFigure);
            app.ChangetimeSlider.Limits = [0 24];
            app.ChangetimeSlider.MajorTicks = [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24];
            app.ChangetimeSlider.MajorTickLabels = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', ''};
            app.ChangetimeSlider.ValueChangedFcn = createCallbackFcn(app, @ChangetimeSliderValueChanged, true);
            app.ChangetimeSlider.MinorTicks = [1 5 10 15 20];
            app.ChangetimeSlider.Position = [680 163 615 3];

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
            app.ChoosefolderwithCSVmodelsButton.ButtonPushedFcn = createCallbackFcn(app, @ChoosefolderwithCSVmodelsButtonPushed, true);
            app.ChoosefolderwithCSVmodelsButton.Position = [10 178 120 36];
            app.ChoosefolderwithCSVmodelsButton.Text = {'Choose folder with '; 'CSV models'};

            % Create CSVsFolder
            app.CSVsFolder = uieditfield(app.OrextractdatafromcsvmodelsPanel, 'text');
            app.CSVsFolder.Position = [140 185 270 22];
            app.CSVsFolder.Value = 'select a name template for csv files';

            % Create ChooseEnsembleForCombinedModelButtonGroup
            app.ChooseEnsembleForCombinedModelButtonGroup = uibuttongroup(app.OrextractdatafromcsvmodelsPanel);
            app.ChooseEnsembleForCombinedModelButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ChooseEnsembleForCombinedModelButtonGroupSelectionChanged, true);
            app.ChooseEnsembleForCombinedModelButtonGroup.Title = 'Choose Ensemble For Combined Model';
            app.ChooseEnsembleForCombinedModelButtonGroup.Position = [10 90 400 68];

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
            app.CSVmodelsnametemplateEditField.Position = [174 51 236 22];

            % Create CSVLoadDataButton
            app.CSVLoadDataButton = uibutton(app.OrextractdatafromcsvmodelsPanel, 'push');
            app.CSVLoadDataButton.ButtonPushedFcn = createCallbackFcn(app, @CSVLoadDataButtonPushed, true);
            app.CSVLoadDataButton.Position = [310 10 100 24];
            app.CSVLoadDataButton.Text = {'Load Data'; ''};

            % Create ImportdatafromanncfilePanel
            app.ImportdatafromanncfilePanel = uipanel(app.UIFigure);
            app.ImportdatafromanncfilePanel.TitlePosition = 'centertop';
            app.ImportdatafromanncfilePanel.Title = 'Import data from an nc file';
            app.ImportdatafromanncfilePanel.FontSize = 16;
            app.ImportdatafromanncfilePanel.Position = [10 587 490 113];

            % Create NcFile
            app.NcFile = uieditfield(app.ImportdatafromanncfilePanel, 'text');
            app.NcFile.Position = [130 55 280 22];

            % Create UploadanNCfileButton
            app.UploadanNCfileButton = uibutton(app.ImportdatafromanncfilePanel, 'push');
            app.UploadanNCfileButton.ButtonPushedFcn = createCallbackFcn(app, @UploadanNCfileButtonPushed, true);
            app.UploadanNCfileButton.Position = [10 54 110 25];
            app.UploadanNCfileButton.Text = 'Upload an NC file :';

            % Create NCLoadDataButton
            app.NCLoadDataButton = uibutton(app.ImportdatafromanncfilePanel, 'push');
            app.NCLoadDataButton.ButtonPushedFcn = createCallbackFcn(app, @NCLoadDataButtonPushed, true);
            app.NCLoadDataButton.Position = [310 12 100 24];
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
            app.ChooseModelDropDown.Position = [130 12 150 22];
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
            app.SelectsavedestinationButton.ButtonPushedFcn = createCallbackFcn(app, @SelectsavedestinationButtonPushed, true);
            app.SelectsavedestinationButton.Position = [286.5 41 139 22];
            app.SelectsavedestinationButton.Text = 'Select save destination';

            % Create SaveDestionation
            app.SaveDestionation = uieditfield(app.ExportvideoPanel, 'text');
            app.SaveDestionation.Position = [430 41 156 22];

            % Create PlayButton
            app.PlayButton = uibutton(app.UIFigure, 'push');
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);
            app.PlayButton.Position = [522 130 61 46];
            app.PlayButton.Text = 'Play';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = gui_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

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