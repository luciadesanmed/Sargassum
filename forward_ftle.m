%Code to calculate and plot forward FTLE (Figure 2)

clear all; close all; clc

%Created by: Ana Lucia de Santos Medina (https://github.com/luciadesanmed)

%All data files required to run this script are in the data folder, you
%should add the corresponding paths 

casos={'mean','cyclone','rossby','eddy'};
titles1={'Mean circulation','Tropical cyclone',...
    'Large Ro', 'Anticyclonic eddy'};
figures1={'mean_ftlefor.png','cyclone_ftlefor.png',...
    'rossby_ftlefor.png','eddy_ftlefor.png'}

for ii=1:length(casos)
CASO=ii;
ARCHIVO1 = strcat('OD_1km_', casos{CASO}, '.nc');
load('batimetria1km.mat');

bat_Z = h1';
bat_Z(bat_Z == 1) = 0;
bat_lat = ncread(ARCHIVO1, 'latitude');
bat_lon = ncread(ARCHIVO1, 'longitude');

res_factor = 0.5; 
lon_part = linspace(min(bat_lon), max(bat_lon), round(length(bat_lon)*res_factor));
lat_part = linspace(min(bat_lat), max(bat_lat), round(length(bat_lat)*res_factor));
[X0, Y0] = meshgrid(lon_part, lat_part);
dx = lon_part(2) - lon_part(1);
dy = lat_part(2) - lat_part(1);

Z_interp = interp2(bat_lon, bat_lat, bat_Z, X0, Y0);
mask_agua = Z_interp > 0; 


calcular_ftle = @(x_final, y_final, mask, dx, dy, T) ...
    estabilizar_y_calcular(x_final, y_final, mask, dx, dy, T, X0);

ARCHIVO5km = strcat(casos{CASO}, '_5km_300s_ftles_55579.nc');
x_final_5 = ncread(ARCHIVO5km, 'lon'); x_final_5 = x_final_5(end, :);
y_final_5 = ncread(ARCHIVO5km, 'lat'); y_final_5 = y_final_5(end, :);

ftle5km = calc_FTLE(x_final_5, y_final_5, mask_agua, dx, dy, 10, X0);

ARCHIVO1km = strcat(casos{CASO}, '_1km_300s_ftles_55579.nc');
x_final_1 = ncread(ARCHIVO1km, 'lon'); x_final_1 = x_final_1(end, :);
y_final_1 = ncread(ARCHIVO1km, 'lat'); y_final_1 = y_final_1(end, :);

ftle1km = calc_FTLE(x_final_1, y_final_1, mask_agua, dx, dy, 10, X0);

try
    se = strel('disk', 1); 
    mask_visual = imerode(mask_agua, se);
catch
    mask_visual = mask_agua;
end

resta = ftle5km - ftle1km;
resta(~mask_visual) = NaN;

%%  Figures
letra=20;

fig=figure(gcf)
fig.Position(3:4)=[550,400];
set(gcf, 'Position', get(0, 'Screensize'))

subplot(1,2,1)
h= pcolor(X0, Y0, ftle5km); 
set(h, 'EdgeColor', 'none'); 
axis equal
shading interp; 
colormap(spring);
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
ylabel(titles1{ii},'FontWeight','bold')


subplot(1,2,1.8)
pcolor(X0, Y0, ftle1km); 
axis equal
shading interp; 
colormap(viridis); 
c=colorbar
clim([0 0.5])
ylabel(c,'FTLE_{forward} (day^{-1})','FontSize',letra,'Rotation',270,'FontWeight','bold')
c.FontSize=letra;
hold on;
contour(bat_lon, bat_lat, bat_Z, [1 1], 'k', 'LineWidth', 1); 
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

%% FTLE function
function ftle = calc_FTLE(xf, yf, mask, dx, dy, T, X0)
    XT = nan(size(X0)); YT = nan(size(X0));
    XT(mask) = xf; YT(mask) = yf;
    
XT = fillmissing(XT, 'nearest');
YT = fillmissing(YT, 'nearest');

XT = imgaussfilt(XT, 1.2); 
YT = imgaussfilt(YT, 1.2);

    [dXT_dx, dXT_dy] = gradient(XT, dx, dy);
    [dYT_dx, dYT_dy] = gradient(YT, dx, dy);
    
    C11 = dXT_dx.^2 + dYT_dx.^2;
    C12 = dXT_dx.*dXT_dy + dYT_dx.*dYT_dy;
    C22 = dXT_dy.^2 + dYT_dy.^2;
    
    disc = (C11 - C22).^2 + 4*C12.^2;
    disc(disc < 0) = 0; 
    
    lambda_max = 0.5 * (C11 + C22 + sqrt(disc));

    lambda_max(lambda_max < 1) = 1;
    
    ftle = (1 / abs(T)) * log(sqrt(lambda_max));
    ftle(~mask) = NaN;
    ftle(isinf(ftle)) = NaN; 
end

