%Code to plot mean Liu-Weisberg skill score as a function of windage factor
%(Figure A1):

clear all; close all; clc

%Created by: Ana Lucia de Santos Medina (https://github.com/luciadesanmed)

%%All data files required to run this script are in the data folder, you
%should add the corresponding paths 

%Run pre-script:
daily_skillscore

load('skills_allbuoys.mat');

indslastre=[1,2,3,4,5];

boyaslastre_5km=[]
boyaslastre_1km=[]

for i=1:length(indslastre)
boyaslastre_5km=[boyaslastre_5km;skills_todaslasboyas_5km{indslastre(i)}];
boyaslastre_1km=[boyaslastre_1km;skills_todaslasboyas_1km{indslastre(i)}];
end

wd=linspace(0,5,100);

%% Figure:

letra=15;

mean5km=nanmean(boyaslastre_5km,1);
mean1km=nanmean(boyaslastre_1km,1);

[maxval5km,max5]=max(mean5km(:));
[maxval1km,max1]=max(mean1km(:));


plot(wd,nanmean(boyaslastre_5km,1),'r',wd,nanmean(boyaslastre_1km,1),'b','LineWidth',1.5)
hold on
yline(maxval5km,'--','color',[246/255,154/255,205/255],'LineWidth',1.5);
hold on
yline(maxval1km,'--','color',"#4DBEEE",'LineWidth',1.5);
hold on
xline(2.5,'--','color',"k",'LineWidth',1.5);
title('','FontSize',letra)
xlabel('Windage factor (%)','FontSize',letra,'FontWeight','bold')
ylabel('ss','FontWeight','bold','FontSize',letra,'FontWeight','bold')
xlim([0 5])
ylim([0.35 0.75])
ax=gca;
ax.FontSize=letra;
grid on
axis square
legend('5 km','1 km','Max ss 5 km', 'Max ss 1 km', '2.5% windage')
