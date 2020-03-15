%%Create some data
a = ncinfo('o3_surface_20180701000000.nc');
chimere_ozone = {a.Variables.Name};
table = ncread('o3_surface_20180701000000.nc',chimere_ozone{1});
size(table);
[X] = ncread('o3_surface_20180701000000.nc', 'lon')'; % create X value
[Y] = ncread('o3_surface_20180701000000.nc', 'lat')';% create Y values
% create a mesh of values
[Y] = Y(1:398);
[X] = X(1:698);
X = double(X);
Y = double(Y);
Z = readtable('24Hour/24HR_CBE_01.csv');
Z = table2array(Z)
% Display the raw data
figure(1)
mesh(X,Y,Z)
% The data you will have from the NetCDF files will be X, Y and Z where
% X & Y are the Lat and Lon values in a vector form
% Z represents the ozone in a 2D array
% The data provided here as X, Y, Z is in the corresponding formats.


%% Create a display of the data from the NetCDF files like this
[X,Y] = meshgrid(X, Y);

size(X)
size(Y)
size(Z)
figure(2);
clf
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

% Plot the data
surfm(X,Y,Z, 'none',...
    'FaceAlpha', 0.5)  % edge colour outlines the edges, 'FaceAlpha', sets the transparency

%% Plot contour map
% [X,Y] = meshgrid(X, Y); % this calculation has been carried out above
% already

figure(3);
clf

% create the map
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

% display the data
NumContours = 10;
contourfm(X, Y, Z, NumContours)

% This is a bit advanced, sets the visibility of the various parts of the
% plot so the land, cities etc shows through.
Plots = findobj(gca,'Type','Axes');
Plots.SortMethod = 'depth';
