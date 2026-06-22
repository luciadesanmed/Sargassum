%Code to create mat file from nc output from opendrift for buoy comparison

clear all; close all; clc

%Created by: Ana Lucia de Santos Medina (https://github.com/luciadesanmed)

%Only run this script if you ran the opendrift-buoy-simulations.py and
%obtained the output files

%%All data files required to run this script are in the data folder, you
%should add the corresponding paths 

s1='SK_';
boyas={'boya1slastre','boya2slastre','boya3slastre',...
    'boya4slastre','boya5slastre'};
s2={'_1km_','_5km_'};
s3={'dia1.nc','dia2.nc','dia3.nc','dia4.nc','dia5.nc','dia6.nc','dia7.nc','dia8.nc',...
    'dia9.nc','dia10.nc','dia11.nc','dia12.nc','dia13.nc','dia14.nc','dia15.nc'};
diasporboya=[8,7,15,7,11];
s4='_datosdiarios_skillscore.mat';
s5=strcat(boyas,s4);

lon5=[]; lon1=[]; lat5=[]; lat1=[]; st1=[]; st5=[]; t1=[]; t5=[]; wd1=[]; wd5=[];
for jj=1:length(diasporboya)
    for i=1:diasporboya(jj)
            archivo1=strcat(s1,boyas{jj},s2{1},s3{i});
            archivo2=strcat(s1,boyas{jj},s2{2},s3{i});
            %1 km:
            T1=ncread(archivo1,'time');
            LON1=ncread(archivo1,'lon');
            LAT1=ncread(archivo1,'lat');
            ST1=ncread(archivo1,'status');
            WD1=ncread(archivo1,'wind_drift_factor');
            
            %5 km:
            T5=ncread(archivo2,'time');
            LON5=ncread(archivo2,'lon');
            LAT5=ncread(archivo2,'lat');
            ST5=ncread(archivo2,'status');
            WD5=ncread(archivo2,'wind_drift_factor');
    
    lon5=[lon5;LON5]; lon1=[lon1;LON1];
    lat5=[lat5;LAT5]; lat1=[lat1;LAT1];
    wd5=[wd5;WD5]; wd1=[wd1;WD1];
    st5=[st5;ST5]; st1=[st1;ST1];
    t5=[t5;T5]; t1=[t1;T1];
    end
    save(s5{jj},'lon5','lon1','lat5','lat1','wd5','wd1','st5','st1','t1','t5');
    lon5=[]; lon1=[]; lat5=[]; lat1=[]; st1=[]; st5=[]; t1=[]; t5=[]; wd1=[]; wd5=[];
end