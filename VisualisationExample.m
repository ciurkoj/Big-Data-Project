%%Create some data
<<<<<<< HEAD
a = ncinfo('Data/Model Combined/o3_surface_20180701000000.nc');
=======
figure('Position',[1 0 1920 1200],'MenuBar','none','ToolBar','none','resize','off') % fullscreen
a = ncinfo('o3_surface_20180701000000.nc');
>>>>>>> Added a prototype of colorbar
chimere_ozone = {a.Variables.Name};
table = ncread('Data/Model Combined/o3_surface_20180701000000.nc',chimere_ozone{1});
size(table);
[X] = ncread('Data/Model Combined/o3_surface_20180701000000.nc', 'lat')'; % create X value
[Y] = ncread('Data/Model Combined/o3_surface_20180701000000.nc', 'lon')';% create Y values
% create a mesh of valuesS
[Y] = Y(1:698);
[X] = X(1:398);
X = double(X);
Y = double(Y)';
Z = readtable('Data/24Hour/24HR_Orig_01.csv');
Z = table2array(Z);
Z=Z';
[X,Y] = meshgrid(X, Y);
% Display the raw data
% Create the map
worldmap('Europe'); % set the part of the earth to show
load coastlines
plotm(coastlat,coastlon)
land = shaperead('landareas', 'UseGeoCoords', true);
geoshow(gca, land, 'FaceColor', [0.5 0.7 0.5])
lakes = shaperead('worldlakes', 'UseGeoCoords', true);
geoshow(lakes, 'FaceColor', 'blue')
rivers = shaperead('worldrivers', 'UseGeoCoords', true);
geoshow(rivers, 'Color', 'blue')
cities = shaperead('worldcities', 'UseGeoCoords', true);
geoshow(cities, 'Marker', '.', 'Color', 'red')

v = VideoWriter('plot.avi');
v.FrameRate = 4;
open(v);
<<<<<<< HEAD
fileDirectory = dir('Data/24Hour/24HR_CBE_*.csv');
=======
fileDirectory = dir('24Hour/24HR_CBE_*.csv');

>>>>>>> Added a prototype of colorbar
for k = 1 : length(fileDirectory)
    worldmap('Europe'); % set the part of the earth to show
    load coastlines
    plotm(coastlat,coastlon)
    land = shaperead('landareas', 'UseGeoCoords', true);
    geoshow(gca, land, 'FaceColor', [0.5 0.7 0.5])
    lakes = shaperead('worldlakes', 'UseGeoCoords', true);
    geoshow(lakes, 'FaceColor', 'blue')
    rivers = shaperead('worldrivers', 'UseGeoCoords', true);
    geoshow(rivers, 'Color', 'blue')
    cities = shaperead('worldcities', 'UseGeoCoords', true);
    geoshow(cities, 'Marker', '.', 'Color', 'red')
    file = fileDirectory(k).name;
    Z = readtable(['Data/24Hour/',file]);
    Z = table2array(Z);
    Z=Z';
    caxis([0 1.3])
    colorbar('Ticks', [0, 0.1, 0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3]);
    theTitle = sprintf('Europe at %.f hours', k*100);
    title(theTitle);
    surfm(X,Y,Z, 'EdgeColor','none','FaceAlpha', 0.8)
    frame = getframe(gcf);
    writeVideo(v,frame);
    cla
    pause(0.05);    
end
<<<<<<< HEAD
close all;
=======

close(v);

% create the map
worldmap('Europe'); % set the part of the earth to show
load coastlines
plotm(coastlat,coastlon)
>>>>>>> Added a prototype of colorbar

close(v);




