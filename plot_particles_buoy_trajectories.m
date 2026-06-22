%Code to plot simulated particles and buoy trajectories (Figure A1):

clear all; close all; clc

%Created by: Ana Lucia de Santos Medina (https://github.com/luciadesanmed)

%%All data files required to run this script are in the data folder, you
%should add the corresponding paths 

%Run pre-script:
%buoy_validation_nc_output_to_mat %Uncomment this line if you obtained the
%output files from running opendrift-buoy-simulations.py

boyas={'boya1slastre','boya2slastre','boya3slastre',...
    'boya4slastre','boya5slastre'};
s4='_datosdiarios_skillscore.mat';
s5=strcat(boyas,s4);

titulos={'25/06/2023-04/07/2023','25/08/2022-01/09/2022','31/10/2022-15/11/2022',...
    '14/01/2023-21/01/2023','24/05/2023-04/06/2023'};

%Land mask:
LAT1=ncread('1kmcurrents_buoys_for_opendrift.nc','latitude');
LON1=ncread('1kmcurrents_buoys_for_opendrift.nc','longitude');
mask1=ncread('1kmcurrents_buoys_for_opendrift.nc','land_binary_mask');

[x1,y1]=meshgrid(LON1,LAT1);

for jj=1:length(boyas)
    load(s5{jj});
    
    if jj==5
        lon5=lon5(1:55,:); lon1=lon1(1:55,:);
        lat5=lat5(1:55,:); lat1=lat1(1:55,:);
    end
    
    %Buoy trajectories:
    csv_filename = strcat(boyas{jj}, '.csv');
    if exist(csv_filename, 'file')
        opts = detectImportOptions(csv_filename);
        tabla_boya = readtable(csv_filename, opts);
        LONC = tabla_boya.LON;
        LATC = tabla_boya.LAT;
    else
        warning('CSV file not found', csv_filename);
        continue;
    end
    
    [filas_modelo, part] = size(lon5);
    pasos_por_bloque = 5; 
    
    limite_final = floor(filas_modelo / pasos_por_bloque) * pasos_por_bloque;
   
    limite_boya = min(length(LONC), limite_final);
    LONC_plot = LONC(1:limite_boya);
    LATC_plot = LATC(1:limite_boya);
    
    %% Figures
    letra=20;
    fig=figure(jj);
    fig.Position(3:4)=[550,400];
    set(gcf, 'Position', get(0, 'Screensize'))
    
    n = 1;
    for i = pasos_por_bloque:pasos_por_bloque:limite_final
        
        lon5_bloque = lon5(n:i, :);
        lat5_bloque = lat5(n:i, :);
        
        lon1_bloque = lon1(n:i, :);
        lat1_bloque = lat1(n:i, :);
        
        for p = 1:part
            plot(lon5_bloque(:, p), lat5_bloque(:, p), 'LineWidth', 0.4, 'Color', 'r')
            hold on
            plot(lon1_bloque(:, p), lat1_bloque(:, p), 'LineWidth', 0.4, 'Color', 'b')
        end
        
        n = n + pasos_por_bloque;
    end
    
    %Land contour:
    contour(x1,y1,mask1',[1],'-k','LineWidth',1.5)
    hold on
    
    %Buoy trajectory from csv:
    plot(LONC_plot, LATC_plot, '-k', 'LineWidth', 1.5)
    
    axis equal
    xlim([-89 -84.5])
    ylim([15.6 22])
    
    num_dias = limite_final / pasos_por_bloque;
    title(titulos{jj}, 'FontSize', letra)
    
    xticks([-89 -88 -87 -86 -85])
    xticklabels({'89°W','88°W','87°W','86°W','85°W'})
    %xticklabels('')
    yticks([16 17 18 19 20 21 22])
    yticklabels({'16°N','17°N','18°N','19°N','20°N','21°N','22°N'})
    %yticklabels('')
    set(gca,'TickDir','out','FontSize',letra-3);
    set(gca,'TickLength',[0.02 0.035])
    
    saveas(gcf,strcat(boyas{jj},'_trajectories.png'))
    close
    
    clear lon5 lon1 lat5 lat1 LONC LATC tabla_boya LONC_plot LATC_plot
end