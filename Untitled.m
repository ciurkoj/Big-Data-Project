%%Create some data
a = ncinfo('o3_surface_20180701000000.nc');
chimere_ozone = {a.Variables.Name};
table = ncread('o3_surface_20180701000000.nc',chimere_ozone{1});
size(table);
[X] = ncread('o3_surface_20180701000000.nc', 'lat')'; % create X value
[Y] = ncread('o3_surface_20180701000000.nc', 'lon')';% create Y values
% create a mesh of valuesS
[Y] = Y(1:698);
[X] = X(1:398);
X = double(X);
Y = double(Y)';
Z = readtable('24Hour/24HR_Orig_01.csv');
Z = table2array(Z);
Z=Z';
[X,Y] = meshgrid(X, Y);
% Display the raw data
figure(1)
mesh(X,Y,Z)
% The data you will have from the NetCDF files will be X, Y and Z where
% X & Y are the Lat and Lon values in a vector form
% Z represents the ozone in a 2D array
% The data provided here as X, Y, Z is in the corresponding formats.



%% Plot contour map
% [X,Y] = meshgrid(X, Y); % this calculation has been carried out above
% already
figure(1)
fileDirectory = dir('24Hour/24HR_Orig_*.csv');
for k = 1 : length(fileDirectory)
    file = fileDirectory(k).name;
    file
    matrix = readmatrix(['24Hour/',file]);
    %matrix = matrix(398:698)
    matrix = matrix';
    showmap = pcolor(X,Y,matrix);
    showmap.EdgeAlpha = 0;
    load coast;
    hold on;
    s = plot(X,Y, 'k');
    showmap;
    pause(0.3);
end
clf
