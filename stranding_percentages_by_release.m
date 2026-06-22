%Code to compare and plot the stranded particle percentages as a function
%of release time (Figure 3)

close all; clear all; clc

%Created by: Ana Lucia de Santos Medina (https://github.com/luciadesanmed)

%All data files required to run this script are in the data folder, you
%should add the corresponding paths 

casos={'mean','cyclone','rossby','eddy'};

for ii=1:length(casos) 
    CASO=ii
    %Load data:
    ARCHIVO1=strcat('OD_1km_',casos{CASO},'.nc');
    ARCHIVO2=strcat('OD_5km_',casos{CASO},'.nc');
    
    LAT1=ncread(ARCHIVO1,'latitude');
    LON1=ncread(ARCHIVO1,'longitude');
    mask1=ncread(ARCHIVO1,'land_binary_mask');
    u1=ncread(ARCHIVO1,'x_sea_water_velocity');
    v1=ncread(ARCHIVO1,'y_sea_water_velocity');
    
    LAT5=ncread(ARCHIVO2,'latitude');
    LON5=ncread(ARCHIVO2,'longitude');
    mask5=ncread(ARCHIVO2,'land_binary_mask');
    u5=ncread(ARCHIVO2,'x_sea_water_velocity');
    v5=ncread(ARCHIVO2,'y_sea_water_velocity');
    
    %Opendrift particle output:
    archivo1=strcat('particles_1km_',casos{CASO},'_10min_6h.nc');
    archivo2=strcat('particles_5km_',casos{CASO},'_10min_6h.nc');
    
    %1 km:
    t1=ncread(archivo1,'time');
    lon1=ncread(archivo1,'lon');
    lat1=ncread(archivo1,'lat');
    st1=ncread(archivo1,'status');
    
    %5 km:
    t5=ncread(archivo2,'time');
    lon5=ncread(archivo2,'lon');
    lat5=ncread(archivo2,'lat');
    st5=ncread(archivo2,'status');
    
    dt=datetime(2000,1,1,0,0,t1,'Format','dd-MM-yyyy');
    
    u1=nanmean(u1,3); v1=nanmean(v1,3);
    
    %% Codes to mark as stranded the particles that cross the 50 m isobath
    
    %5 km bathymetry file:
    load('batimetria5km.mat');
    
    %Cropping 5 km grid data to our study area:
    loni=ncread('time5.nc','lon_rho'); loni=loni(:,1);
    lati=ncread('time5.nc','lat_rho'); lati=lati(1,:);
    
    min_lat=min(LAT1);  min_lon=min(LON1);
    max_lat=max(LAT1);  max_lon=max(LON1);
    
    in1=find(lati>min_lat & lati<max_lat);
    in2=find(loni>min_lon & loni<max_lon);
    
    h5=h5(in2,in1);
    
    in1=find(LAT5>min_lat & LAT5<max_lat);
    in2=find(LON5>min_lon & LON5<max_lon);
    LAT5=LAT5(in1);
    LON5=LON5(in2);
    mask5=mask5(in2,in1);
    u5=u5(in2,in1); v5=v5(in2,in1);
    u5=nanmean(u5,3); v5=nanmean(v5,3);
    
    %1 km grid bathymetry file:
    load('batimetria1km.mat'); 
    
    [x1,y1]=meshgrid(LON1,LAT1);
    [x5,y5]=meshgrid(LON5,LAT5);
    
    %5 km grid:
    
    %Bathymetry mask with 0 and 1:
    for i=1:length(LON5)
        for j=1:length(LAT5)
    if h5(i,j)>50
        H5(i,j)=1;
    else
        H5(i,j)=0;
    end
        end
    end
    
    ST5=reshape(st5,1,[]);
    Lo5=reshape(lon5,1,[]);
    La5=reshape(lat5,1,[]);
    
    %finds the stranded particles that are marked as error and orders them
    p1=find(ST5<0);
    ST5(p1)=1; Lo5(p1)=1; La5(p1)=1;
    
    TAM1=length(st5(:,1)); TAM2=length(st5(1,:));
    st5=reshape(ST5,TAM1,TAM2);
    lon5=reshape(Lo5,TAM1,TAM2);
    lat5=reshape(La5,TAM1,TAM2);
    
    
    %To check how many particles crossed the 50 m isobath (we consider them as stranded)
    for i=1:length(st5(:,1)) %no days
    for j=1:length(st5(1,:)) %no particles
         if st5(i,j)==0 %if st5 is equal to zero, the particle is stranded
        [val,idx]=min(abs(LON5-lon5(i,j))); %find the grid cell with the closes lon
        [val,idx2]=min(abs(LAT5-lat5(i,j))); %find the grid cell with the closest lat
         end
    if H5(idx,idx2)==0
        if i~=length(dt)
            st5(i:end,j)=1; lon5(i+1,j)=1; lat5(i+1,j)=1; %stranded
        elseif i==length(dt)
            st5(i,j)=1; lon5(i,j)=lon5(i,j); lat5(i,j)=lat5(i,j); %stranded
        end 
    elseif H5(idx,idx2)==1
        lon5(i,j)=lon5(i,j); lat5(i,j)=lat5(i,j); %not stranded
    end
        end
    end
    
    %1 km grid:
    for i=1:length(LON1)
        for j=1:length(LAT1)
    if h1(i,j)>50
        H1(i,j)=1;
    else
        H1(i,j)=0;
    end
        end
    end
    
    ST1=reshape(st1,1,[]);
    Lo1=reshape(lon1,1,[]);
    La1=reshape(lat1,1,[]);
    
    p1=find(ST1<0);
    ST1(p1)=1; Lo1(p1)=1; La1(p1)=1;
    
    TAM1=length(st1(:,1)); TAM2=length(st1(1,:));
    st1=reshape(ST1,TAM1,TAM2);
    lon1=reshape(Lo1,TAM1,TAM2);
    lat1=reshape(La1,TAM1,TAM2);
    
    for i=1:length(st1(:,1)) 
    for j=1:length(st1(1,:)) 
         if st1(i,j)==0
        [val,idx]=min(abs(LON1-lon1(i,j)));
        [val,idx2]=min(abs(LAT1-lat1(i,j)));
         end
    if H1(idx,idx2)==0
        if i~=length(dt)
            st1(i:end,j)=1; lon1(i+1,j)=1; lat1(i+1,j)=1;
        elseif i==length(dt)
            st1(i,j)=1; lon1(i,j)=lon1(i,j); lat1(i,j)=lat1(i,j);
        end
    elseif H1(idx,idx2)==1
        lon1(i,j)=lon1(i,j); lat1(i,j)=lat1(i,j);
    end
        end
    end
    
    %% Stranded particle percentages
    total=length(st5(1,:)); %number of particles
    
    j=1;
    jj=9000;
    part=9000;
    
    for i=1:40
    EN5=find(st5(end,j:jj)==1); NEN5(i)=(length(EN5)/part)*100;
    AC5=find(st5(end,j:jj)==0); NAC5(i)=(length(AC5)/part)*100; 
    EN1=find(st1(end,j:jj)==1); NEN1(i)=(length(EN1)/part)*100;
    AC1=find(st1(end,j:jj)==0); NAC1(i)=(length(AC1)/part)*100; 
    
    j=j+9000
    jj=jj+9000
    end
    
    %% Figures
    letra=15
    
    figure(ii)
    
    yyaxis right
    plot(1:40,abs(NEN5-NEN1),'LineWidth',1.2,'Color',[0 0.7 0.7])
    ylabel('|SP% 5 km - SP% 1 km|','FontWeight','bold')
    ylim([0 25])
    ax=gca;
    
    yyaxis left
    plot(1:40,NEN5, '-r',1:40, NEN1,'-b','LineWidth',1.5)
    xlabel('Release time')
    xticks(0:4:40)
    xticklabels({'0','1 d','2 d','3 d','4 d','5 d','6 d','7 d','8 d','9 d', '10 d'})
    axis square
    legend('5 km','1 km','Location','northeast')
    fontsize(gcf,scale=1.2)
    ylim([0 45])
    
    if CASO==1
    ylabel({'Mean circulation','SP (%)'},'FontWeight','bold')
    elseif CASO==2
    ylabel({'Tropical cyclone','SP (%)'},'FontWeight','bold')
    elseif CASO==3
    ylabel({'Large Ro','SP (%)'},'FontWeight','bold')
    elseif CASO==4
    ylabel({'Anticyclonic eddy','SP (%)'},'FontWeight','bold')
    end
    ax.YAxis(2).Color = [0 0.7 0.7];
    ax.YAxis(1).Color = 'k';
end
