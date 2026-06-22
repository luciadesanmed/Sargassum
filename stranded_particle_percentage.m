%Code to quantify and plot stranded particle percentage, and difference
%between 5 and 1 km grids (Figure 4)

close all; clear all; clc

%Created by: Ana Lucia de Santos Medina (https://github.com/luciadesanmed)

%%All data files required to run this script are in the data folder, you
%should add the corresponding paths 

casos={'mean','cyclone','rossby','eddy'};
titles1={'Mean circulation','Tropical cyclone',...
    'Large Ro', 'Anticyclonic eddy'};
figures1={'mean_strandedparts.png','cyclone_strandedparts.png',...
    'rossby_strandedparts_.png','eddy_strandedparts_.png'}
titles2={'Difference - Mean circulation', 'Difference - Tropical cyclone',...
    'Difference - Large Ro', 'Difference - Anticyclonic eddy'};
figures2={'mean_strandedparts_diff.png', 'cyclone_strandedparts_diff.png',...
    'rossby_strandedparts_diff.png', 'eddy_strandedparts_diff.png'};

for ii=1:length(casos)
CASO=ii;

%Load files:
%Surface currents:
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

%Opendrift output:
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

%% Classify particles as stranded if they cross the 50 m isobath:

%5 km bathymetry file:
load('batimetria5km.mat');

%Cropping to study area:
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

%1 km bathymetry file:
load('batimetria1km.mat'); 

[x1,y1]=meshgrid(LON1,LAT1);
[x5,y5]=meshgrid(LON5,LAT5);

%5 km grid:

%Bathymetry mask:
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

%Orders stranded particles:
p1=find(ST5<0);
ST5(p1)=1; Lo5(p1)=1; La5(p1)=1;

TAM1=length(st5(:,1)); TAM2=length(st5(1,:));
st5=reshape(ST5,TAM1,TAM2);
lon5=reshape(Lo5,TAM1,TAM2);
lat5=reshape(La5,TAM1,TAM2);

%To see if they got stranded
for i=1:length(st5(:,1)) 
for j=1:length(st5(1,:)) 
     if st5(i,j)==0 
    [val,idx]=min(abs(LON5-lon5(i,j))); 
    [val,idx2]=min(abs(LAT5-lat5(i,j))); 
     end
if H5(idx,idx2)==0
    if i~=length(dt)
        st5(i:end,j)=1; lon5(i+1,j)=1; lat5(i+1,j)=1; %stranded
    elseif i==length(dt)
        st5(i,j)=1; lon5(i,j)=lon5(i,j); lat5(i,j)=lat5(i,j); %stranded
    end
elseif H5(idx,idx2)==1
    lon5(i,j)=lon5(i,j); lat5(i,j)=lat5(i,j); %stranded particles
end
    end
end

for i=2:length(lon5(:,1)) 
    for j=1:length(lon5(1,:)) 
        if lon5(i,j)==1
            lon5(i,j)=lon5(i-1,j);
            lat5(i,j)=lat5(i-1,j);
        end
    end
end

fuera_lat_5km=find(lat5(end,:)>22);
st5(end,fuera_lat_5km)=2;
fuera_lon_5km=find(lon5(end,:)>-84); 
st5(end,fuera_lon_5km)=2;

num_fuera_5km=length(find(st5(end,:)==2)); %number of particles out of domain

for i=1:length(lon5(:,1)) 
    for j=1:length(lon5(1,:)) 
        if lat5(i,j)>22 | lon5(i,j)>-84
            lon5(i,j)=NaN;
            lat5(i,j)=NaN;
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

for i=2:length(lon1(:,1))
    for j=1:length(lon1(1,:))
        if lon1(i,j)==1
            lon1(i,j)=lon1(i-1,j);
            lat1(i,j)=lat1(i-1,j);
        end
    end
end

fuera_lat_1km=find(lat1(end,:)>22);
st1(end,fuera_lat_1km)=2;
fuera_lon_1km=find(lon1(end,:)>-84);
st1(end,fuera_lon_1km)=2;

num_fuera_1km=length(find(st1(end,:)==2)); %number of particles out of domain

for i=1:length(lon1(:,1))
    for j=1:length(lon1(1,:)) 
        if lat1(i,j)>22 | lon1(i,j)>-84
            lon1(i,j)=NaN;
            lat1(i,j)=NaN;
        end
    end
end

%% Percentage of stranded particles
total=length(st5(1,:)); %number of particles
EN5=find(st5(end,:)==1); NEN5=(length(EN5)/total)*100; %number of stranded particles
AC5=find(st5(end,:)==0); NAC5=(length(AC5)/total)*100; %number of active particles

EN1=find(st1(end,:)==1); NEN1=(length(EN1)/total)*100; %number of stranded particles
AC1=find(st1(end,:)==0); NAC1=(length(AC1)/total)*100; %number of active particles

%Nomber of particles out of the domain:
NF5=(num_fuera_5km/total)*100;
NF1=(num_fuera_1km/total)*100;

%1/4 degree grid to quantify the percentage of stranded particles in each
%cell:
ELAT=15.5:.25:22;
ELON=-89:.25:-84.5;
[X,Y]=meshgrid(ELON,ELAT);

porc5=zeros(length(ELON),length(ELAT)); %matrix to store the number of stranded particles per grid cell
for i=1:length(EN5)
K1=lon5(end,EN5(i));
K2=lat5(end,EN5(i));

[val,idx]=min(abs(ELON-K1)); %finding the cell with the closest lon
[val,idx2]=min(abs(ELAT-K2)); %finding the cell with the closest lat

porc5(idx,idx2)=porc5(idx,idx2)+1;
end

porc5=(porc5./length(EN5)).*100;
porc5(porc5<1)=NaN;

porc1=zeros(length(ELON),length(ELAT));

for i=1:length(EN1)
K1=lon1(end,EN1(i));
K2=lat1(end,EN1(i));

[val,idx]=min(abs(ELON-K1)); 
[val,idx2]=min(abs(ELAT-K2)); 

porc1(idx,idx2)=porc1(idx,idx2)+1;
end
porc1=(porc1./length(EN1)).*100;
porc1(porc1<1)=NaN;

%
%% Proximity filter:
[X_c, Y_c] = meshgrid(ELON, ELAT); 

porc5_masked = porc5;
porc1_masked = porc1;

% Threshold:
umbral = 0.12; 

for i = 1:length(ELON)
    for j = 1:length(ELAT)
        dist = min(sqrt((lon5(end,EN5) - ELON(i)).^2 + (lat5(end,EN5) - ELAT(j)).^2));
        if dist > umbral
            porc5_masked(i,j) = NaN;
        end
    end
end

for i = 1:length(ELON)
    for j = 1:length(ELAT)
        dist = min(sqrt((lon1(end,EN1) - ELON(i)).^2 + (lat1(end,EN1) - ELAT(j)).^2));
        if dist > umbral
            porc1_masked(i,j) = NaN;
        end
    end
end

%% Figures:
N=1;
part=length(st1(1,:)); 
letra=20;

fig=figure(gcf)
fig.Position(3:4)=[550,400];
set(gcf, 'Position', get(0, 'Screensize'))

subplot(1,2,1)
scatter(lon5(end,:),lat5(end,:),1,'MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor',[.7 .7 .7])
hold on
pcolor(X,Y,porc5')
hold on

M=5;
[xR,yR]=meshgrid(LON5(1:M:end),21.1);
uR=zeros(1,length(LON5(1:M:end))); vR=zeros(1,length(LON5(1:M:end)));
xRR=find(-88.6<LON5(1:M:end) & LON5(1:M:end)<-88);
uR(1,xRR(1))=0.5; %value for scale arrow
quiver([x5(1:M:end,1:M:end);xR],[y5(1:M:end,1:M:end);yR],[(u5(1:M:end,1:M:end)),uR']'...
    ,[(v5(1:M:end,1:M:end)),vR']','Color',"#0072BD",'AutoScale','off')
text(-88.6,20.8,'0.5 m/s','FontSize',letra)
hold on

yline(ELAT,'Color',[0.9 0.9 0.9],'LineWidth',.5)
hold on
xline(ELON,'Color',[0.9 0.9 0.9],'LineWidth',.5)
hold on

c=colorbar
clim([0 10])
colorbar('off')
hold on
contour(x1,y1,mask1',[1],'LineWidth',1,'Color','k')
hold on
contour(x1,y1,h1',[50 50],'-k','LineWidth',1.5)
hold on
axis equal

xlim([-89 -84.5])
ylim([15.6 22])

yticks([16 17 18 19 20 21 22])
yticklabels({'16°N','17°N','18°N','19°N','20°N','21°N','22°N'})
xticks([-89 -88 -87 -86 -85])
 xticklabels({'89°W','88°W','87°W','86°W','85°W'})
set(gca,'TickDir','out');
set(gca,'TickLength',[0.02 0.035])
ax = gca;
ax.XAxis.FontSize = letra;
ax.YAxis.FontSize = letra;
title('5 km',['A: ',num2str(NAC5,'%.2f'),'%, S: ',...
    num2str(NEN5,'%.2f'),'%, O: ',num2str(NF5,'%.2f'),'%'],'FontSize',letra)
ylabel(titles1{ii},'FontWeight','bold')

subplot(1,2,1.8)
scatter(lon1(end,:),lat1(end,:),1,'MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor',[.7 .7 .7])
hold on
pcolor(X,Y,porc1')
hold on

M=25;
[xR,yR]=meshgrid(LON1(1:M:end),21.1);
uR=zeros(1,length(LON1(1:M:end))); vR=zeros(1,length(LON1(1:M:end)));
xRR=find(-88.6<LON1(1:M:end) & LON1(1:M:end)<-88);
uR(1,xRR(1))=0.5; 
quiver([x1(1:M:end,1:M:end);xR],[y1(1:M:end,1:M:end);yR],[(u1(1:M:end,1:M:end)),uR']'...
    ,[(v1(1:M:end,1:M:end)),vR']','Color',"#0072BD",'AutoScale','off')
text(-88.6,20.8,'0.5 m/s','FontSize',letra)
hold on

yline(ELAT,'Color',[0.9 0.9 0.9],'LineWidth',.5)
hold on
xline(ELON,'Color',[0.9 0.9 0.9],'LineWidth',.5)
hold on
contour(x1,y1,mask1',[1],'LineWidth',1,'Color','k')
hold on
contour(x1,y1,h1',[50 50],'-k','LineWidth',1.5)
hold on
c=colorbar
clim([0 10])
ylabel(c,'SP%','FontSize',letra,'Rotation',270,'FontWeight','bold')
c.FontSize=letra;

axis equal
xlim([-89 -84.5])
ylim([15.6 22])
yticks([16 17 18 19 20 21 22])
xticks([-89 -88 -87 -86 -85])
set(gca,'TickDir','out');
set(gca,'TickLength',[0.02 0.035])
xticklabels({'89°W','88°W','87°W','86°W','85°W'})
yticklabels('')
ax = gca;
ax.XAxis.FontSize = letra;
title('1 km',['A: ',num2str(NAC1,'%.2f'),'%, S: '...
    ,num2str(NEN1,'%.2f'),'%, O: ',num2str(NF1,'%.2f'),'%'],'FontSize',letra)
cbarrow('up')


saveas(gcf,figures1{ii})
close

%% Difference between grids plots:
N=1;
part=length(st1(1,:));
letra=14;

for i=1:length(porc5(:,1))
    for j=1:length(porc5(1,:))
        if isnan(porc5(i,j))==1
            porc5(i,j)=0;
        end
        if isnan(porc1(i,j))==1
            porc1(i,j)=0;
        end
    end
end

diferencia=abs(porc5'-porc1');
for i=1:length(diferencia(:,1))
    for j=1:length(diferencia(1,:))
        if diferencia(i,j)==0
            diferencia(i,j)=NaN;
        end
    end
end

figure
pcolor(X,Y,diferencia)
hold on
contour(x1,y1,mask1',[1],'LineWidth',1,'Color','k')
hold on
contour(x1,y1,h1',[50 50],'-k','LineWidth',1.5)
hold on
yline(ELAT,'Color',[0.9 0.9 0.9],'LineWidth',.5)
hold on
xline(ELON,'Color',[0.9 0.9 0.9],'LineWidth',.5)
axis equal
c=colorbar
clim([0 11])
nn=11;%number of colors
col2=[1, 0, 0]; %red
col1=[0, 1, 1]; %cyan
colorMap = [linspace(col1(1),col2(1),nn)',linspace(col1(2),col2(2),nn)',...
    linspace(col1(3),col2(3),nn)'];
colormap(colorMap)
ylabel(c,'| SP% 5 km - SP% 1 km |','FontSize',13,'Rotation',270,'FontWeight','bold')
c.FontSize=letra
set(gca,'FontSize',letra)
yticks([16 17 18 19 20 21 22])
yticklabels({'16°N','17°N','18°N','19°N','20°N','21°N','22°N'})
xticks([-89 -88 -87 -86 -85])
xticklabels({'89°W','88°W','87°W','86°W','85°W'})
set(gca,'TickDir','out');
set(gca,'TickLength',[0.02 0.035])

title(titles2{ii})
cbarrow('up')
saveas(gcf,figures2{ii})
close

end
