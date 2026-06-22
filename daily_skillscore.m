%Code to calculate Liu-Weisberg skill score:

clear all; close all; clc

%Created by: Ana Lucia de Santos Medina (https://github.com/luciadesanmed)

%%All data files required to run this script are in the data folder, you
%should add the corresponding paths 

%Run pre-script:
%buoy_validation_nc_output_to_mat %uncomment this line if you obtained the
%opendrift files from opendrift-buoy-simulations.py

boyas={'boya1slastre','boya2slastre','boya3slastre',...
    'boya4slastre','boya5slastre'};
diasporboya=[8,7,15,7,11];
s4='_datosdiarios_skillscore.mat';
s5=strcat(boyas,s4);

load('boyassinlastre.mat');

for jj=1:length(boyas)
%Simulated particle trajectories
load(s5{jj});

if jj==5
    lon5=lon5(1:55,:); lon1=lon1(1:55,:);
    lat5=lat5(1:55,:); lat1=lat1(1:55,:);
    wd5=wd5(1:55,:);  wd1=wd1(1:55,:);
    st5=st5(1:55,:); st1=st1(1:55,:);
    t5=t5(1:55,:); t1=t1(1:55,:);
end

%Observed buoy trajectories:
LONC=lons(indporboyas{jj}); LATC=lats(indporboyas{jj});
time=datetime(times(indporboyas{jj}),'convertfrom','datenum');

if jj==5
  LONC=LONC(1:45); LATC=LATC(1:45); time=time(1:45);
end
tinicio=datestr(time(1),'dd/mm/yyyy'); tfinal=datestr(time(end),'dd/mm/yyyy');

%% Obtain separation between trajectories:

LONCD=[LONC(1:4:end)];
LONDIST=[];
LATDIST=[];
redondeo=floor(length(LONC)/5);
    for i=1:length(LONCD)
    hola=find(LONC(:,1)==LONCD(i));
        if hola<=redondeo*5 & hola~=length(LONC)
        LONDIST=[LONDIST;LONC(hola:hola+4)];
        LATDIST=[LATDIST;LATC(hola:hola+4)];
        end
    end

     % Calculate the Lagragian separation distance between the end locations of
     % the observed and simulated trajectories:
  for i = 1:length(lon5(1,:)) 
      for ii=1:length(LATDIST) 
      day=ii;
      xm_5km = lon5(day,i);
      ym_5km = lat5(day,i); 
      xm_1km = lon1(day,i);
      ym_1km = lat1(day,i); 
      xo = LONDIST(day);
      yo = LATDIST(day);
      distancia_cada_tiempo_5km(ii,i) = sw_dist([yo,ym_5km], [xo,xm_5km],'km');
      distancia_cada_tiempo_1km(ii,i) = sw_dist([yo,ym_1km], [xo,xm_1km],'km');
      end
  end

 dl = sw_dist(LATDIST,LONDIST,'km');
 dl=nonzeros(dl);
 dll=reshape(dl,[4,length(dl)/4]);

cdl= cumsum(dll);  % cumulative along the path
cl3 = nansum(cdl);

%Mean skill score:
distancia_5km=reshape(distancia_cada_tiempo_5km,[5,length(dl)/4,length(lon5(1,:))]);
distancia_1km=reshape(distancia_cada_tiempo_1km,[5,length(dl)/4,length(lon5(1,:))]);

 for i=1:length(lon5(1,:))
  %5km:
      for j=1:length(cl3)
      cd3_5km=nansum(distancia_5km(:,:,i),1);
      s_5km(:,i)= cd3_5km./cl3(j);
      %1 km:
      cd3_1km=nansum(distancia_1km(:,:,i),1);
      s_1km(:,i)= cd3_1km./cl3(j);
      end
 end

    n = 1.0;  % Tolerance threshold n is set to be 1. This means 
	    % the trajectory model is considered to have no skill if the 
	    % cumulative Lagrangian sepration is larger than the length of 
	    % the drifter path.
     
  ss3_5km= 1 - s_5km/n;  
 
  ss3_5km(ss3_5km<=0) = 0.000000001; 
  
  ss3_1km= 1 - s_1km/n;  
 
  ss3_1km(ss3_1km<=0) = 0.000000001; % Reset the negative values to 0.000000001,
                                 % so that the skill scores are in the range 
				 % of [0-1]
  skills_todaslasboyas_1km{jj}=ss3_1km;
  skills_todaslasboyas_5km{jj}=ss3_5km;

   clear lon5 lon1 lat5 lat1 wd5 wd1 st5 st1 t1 t5 dl dll LATC LONC ...
       LATDIST LONDIST LONCD day distancia_cada_tiempo_1km distancia_cada_tiempo_5km ...
       cd3_5km cd3_1km cl3 s_5km s_1km
end
save('skills_allbuoys.mat','skills_todaslasboyas_1km','skills_todaslasboyas_5km');