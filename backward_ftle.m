%Code to calculate and plot backward FTLE (Figure 2)

clear all; close all; clc

%Created by: Ana Lucia de Santos Medina (https://github.com/luciadesanmed)

%All data files required to run this script are in the data folder, you
%should add the corresponding paths 

casos={'mean','cyclone','rossby','eddy'};
titles1={'Mean circulation','Tropical cyclone',...
    'Large Ro', 'Anticyclonic eddy'};
figures1={'mean_ftleback.png','cyclone_ftleback.png',...
    'rossby_ftleback.png','eddy_ftleback.png'}

%Create uniform grid for seeding:
ARCHIVO1=strcat('OD_1km_',casos{CASO},'.nc');
load('batimetria1km.mat');
bat_Z=h1';
bat_Z(bat_Z==1) = 0;

bat_lat=ncread(ARCHIVO1,'latitude');
bat_lon=ncread(ARCHIVO1,'longitude');

%Defining particle grid resolution:
res_factor = 0.5;
lon_part = linspace(min(bat_lon), max(bat_lon), round(length(bat_lon)*res_factor));
lat_part = linspace(min(bat_lat), max(bat_lat), round(length(bat_lat)*res_factor));
[X0, Y0] = meshgrid(lon_part, lat_part);

%To identify land cells
Z_interp = interp2(bat_lon, bat_lat, bat_Z, X0, Y0);

%ocean mask:
mask_agua = Z_interp > 0; 

%only get ocean data:
x_agua = X0(mask_agua);
y_agua = Y0(mask_agua);

pos_iniciales_agua = [x_agua, y_agua]; 

%writematrix(pos_iniciales_agua,'seed1km_rejillauniforme_55579_339_226.csv')

%%  Load opendrift output:

for ii=1:length(casos)
CASO=ii;
ARCHIVO5km=strcat(casos{CASO},'_5km_300s_ftles_back_55579.nc');
ARCHIVO1km=strcat(casos{CASO},'_1km_300s_ftles_back_55579.nc');

ARCHIVO = ARCHIVO5km;
lon_all = ncread(ARCHIVO, 'lon');
lat_all = ncread(ARCHIVO, 'lat');

%Start positions:
lon_start = lon_all(1, :); 
lat_start = lat_all(1, :);

%Final positions:
lon_end = lon_all(end, :);
lat_end = lat_all(end, :);

XT = nan(size(X0));
YT = nan(size(Y0));


for k = 1:length(lon_start)
    [~, col] = min(abs(lon_part - lon_start(k)));
    [~, row] = min(abs(lat_part - lat_start(k)));
    
    XT(row, col) = lon_end(k);
    YT(row, col) = lat_end(k);
end


XT = fillmissing(XT, 'nearest');
YT = fillmissing(YT, 'nearest');

XT = imgaussfilt(XT, 1.2); 
YT = imgaussfilt(YT, 1.2);

%Gradients:
dx = lon_part(2) - lon_part(1);
dy = lat_part(2) - lat_part(1);
[dXT_dx, dXT_dy] = gradient(XT, dx, dy);
[dYT_dx, dYT_dy] = gradient(YT, dx, dy);

%Cauchy-green tensor and max eigenvalue
C11 = dXT_dx.^2 + dYT_dx.^2;
C12 = dXT_dx.*dXT_dy + dYT_dx.*dYT_dy;
C22 = dXT_dy.^2 + dYT_dy.^2;

%max eigenvalue
lambda_max = 0.5 * (C11 + C22 + sqrt((C11 - C22).^2 + 4*C12.^2));

%FTLE
T = 10; %integration time, 10 days
ftle5km = (1 / abs(T)) * log(sqrt(lambda_max));

ftle5km(~mask_agua) = NaN;

%% 1 km

ARCHIVO = ARCHIVO1km;
lon_all = ncread(ARCHIVO, 'lon');
lat_all = ncread(ARCHIVO, 'lat');

lon_start = lon_all(1, :); 
lat_start = lat_all(1, :);

lon_end = lon_all(end, :);
lat_end = lat_all(end, :);


XT = nan(size(X0));
YT = nan(size(Y0));


for k = 1:length(lon_start)

    [~, col] = min(abs(lon_part - lon_start(k)));
    [~, row] = min(abs(lat_part - lat_start(k)));
    

    XT(row, col) = lon_end(k);
    YT(row, col) = lat_end(k);
end


XT = fillmissing(XT, 'nearest');
YT = fillmissing(YT, 'nearest');


XT = imgaussfilt(XT, 1.2); 
YT = imgaussfilt(YT, 1.2);


dx = lon_part(2) - lon_part(1);
dy = lat_part(2) - lat_part(1);
[dXT_dx, dXT_dy] = gradient(XT, dx, dy);
[dYT_dx, dYT_dy] = gradient(YT, dx, dy);

C11 = dXT_dx.^2 + dYT_dx.^2;
C12 = dXT_dx.*dXT_dy + dYT_dx.*dYT_dy;
C22 = dXT_dy.^2 + dYT_dy.^2;


lambda_max = 0.5 * (C11 + C22 + sqrt((C11 - C22).^2 + 4*C12.^2));

T = 10;
ftle1km = (1 / abs(T)) * log(sqrt(lambda_max));

ftle1km(~mask_agua) = NaN;

%% Figures:
n = 256; 
nn=256;
col2=[1, 0, 0]; %red
col1=[0, 1, 1]; %cyan
colorMap = [linspace(col1(1),col2(1),nn)',linspace(col1(2),col2(2),nn)',...
    linspace(col1(3),col2(3),nn)'];

blues = [ones(n,1), linspace(1,0,n)', linspace(1,0,n)'];
N=0.6;
letra=20

fig=figure(gcf)
fig.Position(3:4)=[550,400];
set(gcf, 'Position', get(0, 'Screensize'))

subplot(1,2,1)
h= pcolor(X0, Y0, ftle5km); 
set(h, 'EdgeColor', 'none'); 
axis equal
shading interp; 
colormap(colorMap);
c=colorbar
clim([0 0.5])
c.FontSize=letra;
colorbar('off')
hold on;
contour(bat_lon, bat_lat, bat_Z, [1 1], 'k', 'LineWidth', 1); % Línea de costa
title('5 km', 'FontSize', letra);
set(gca,'FontSize',letra)

xlim([-89 -84.5])
ylim([15.6 22])
ylabel('')
yticks([16 17 18 19 20 21 22])
xticks([-89 -88 -87 -86 -85])
yticklabels({'16°N','17°N','18°N','19°N','20°N','21°N','22°N'})
 xticklabels({'89°W','88°W','87°W','86°W','85°W'})
set(gca,'TickDir','out');
set(gca,'TickLength',[0.02 0.035])
ax = gca;
ax.XAxis.FontSize = letra;
ylabel(titles1{ii}, 'FontWeight','bold')

subplot(1,2,1.8)
pcolor(X0, Y0, ftle1km); 
axis equal
shading interp; 
colormap(plasma); 
c=colorbar
clim([0 0.5])
ylabel(c,'FTLE_{backward} (day^{-1})','FontSize',letra,'Rotation',270,'FontWeight','bold')
c.FontSize=letra;
hold on;
contour(bat_lon, bat_lat, bat_Z, [1 1], 'k', 'LineWidth', 1); % Línea de costa
title('1 km','FontSize',letra);
xlim([-89 -84.5])
ylim([15.6 22])
ylabel('')
yticks([16 17 18 19 20 21 22])
xticks([-89 -88 -87 -86 -85])
yticklabels('')
xticklabels({'89°W','88°W','87°W','86°W','85°W'})
set(gca,'TickDir','out');
set(gca,'TickLength',[0.02 0.035])
ax = gca;
ax.XAxis.FontSize = letra;
cbarrow('up')

saveas(gcf,figures1{ii})
close

end


