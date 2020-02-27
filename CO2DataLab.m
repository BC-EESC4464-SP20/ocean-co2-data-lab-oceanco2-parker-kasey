%%Kasey Cannon and Parker Walsh 

% Instructions: Follow through this code step by step, while also referring
% to the overall instructions and questions from the lab assignment sheet.

%% 1. Read in the monthly gridded CO2 data from the .csv file
% The data file is included in your repository as �LDEO_GriddedCO2_month_flux_2006c.csv�
% Your task is to write code to read this in to MATLAB
% Hint: you can again use the function �readtable�, and use your first data lab code as an example.
readtable LDEO_GriddedCO2_month_flux_2006c.csv;

%% 2a. Create new 3-dimensional arrays to hold reshaped data
%Find each unique longitude, latitude, and month value that will define
%your 3-dimensional grid
CO2data=ans;
longrid = unique(CO2data.LON); 
latgrid = unique(CO2data.LAT);
monthgrid = unique (CO2data.MONTH);



%Create empty 3-dimensional arrays of NaN values to hold your reshaped data
    %You can make these for any variables you want to extract - for this
    %lab you will need PCO2_SW (seawater pCO2) and SST (sea surface
    %temperature)
PCO2_grid = NaN([length(longrid), length(latgrid), length(monthgrid)]);
SST_grid = NaN([length(longrid), length(latgrid), length(monthgrid)]);

%% 2b. Pull out the seawater pCO2 (PCO2_SW) and sea surface temperature (SST)
%data and reshape it into your new 3-dimensional arrays

PCO2 = CO2data.PCO2_SW;


    
for i = 1:length(PCO2)
    
    lo = find(longrid == CO2data.LON(i)); 
    
    la = find(latgrid == CO2data.LAT(i));
    
    m = find(monthgrid == CO2data.MONTH(i));

    PCO2_grid(lo,la,m) = PCO2(i);
end

 SST = CO2data.SST;    

 for i = 1:length(SST)
    
    lo = find(longrid == CO2data.LON(i)); 
    
    la = find(latgrid == CO2data.LAT(i));
    
    m = find(monthgrid == CO2data.MONTH(i));

    SST_grid(lo,la,m) = SST(i);
end
 
    
 
%% 3a. Make a quick plot to check that your reshaped data looks reasonable
%Use the imagesc plotting function, which will show a different color for
%each grid cell in your map. Since you can't plot all months at once, you
%will have to pick one at a time to check - i.e. this example is just for
%January
figure(1);clf 
imagesc(latgrid,longrid, SST_grid(:,:,1)');
colorbar

title('January Sea Surface Temperature (^oC)')


%% 3b. Now pretty global maps of one month of each of SST and pCO2 data.
%I have provided example code for plotting January sea surface temperature
%(though you may need to make modifications based on differences in how you
%set up or named your variables above).

figure(2); clf
worldmap world
contourfm(latgrid, longrid, SST_grid(:,:,1)','linecolor','none');
colorbar
geoshow('landareas.shp','FaceColor','black')
title('January Sea Surface Temperature (^oC)')

%Check that you can make a similar type of global map for another month
%and/or for pCO2 using this approach. Check the documentation and see
%whether you can modify features of this map such as the contouring
%interval, color of the contour lines, labels, etc.

figure(3); clf
worldmap world
contourfm(latgrid, longrid, PCO2_grid(:,:,12)','linecolor','none');
colorbar
geoshow('landareas.shp','FaceColor','black')
title('December pCO2 of Seawater (\muatm)')

%% 4. Calculate and plot a global map of annual mean pCO2
%<--

Annual_mean_CO2W=nanmean(PCO2_grid,3);

figure(4); clf
worldmap world
contourfm(latgrid, longrid, Annual_mean_CO2W','linecolor','none');
colorbar
geoshow('landareas.shp','FaceColor','black')
title('Annual Mean pCO2 of Seawater (\muatm)')

%% 5. Calculate and plot a global map of the difference between the annual mean seawater and atmosphere pCO2
%<--
PCO2_grid_atmo = NaN([length(longrid), length(latgrid), length(monthgrid)]);

PCO2_atm = CO2data.PCO2_AIR;


    
for i = 1:length(PCO2_atm)
    
    lo = find(longrid == CO2data.LON(i)); 
    
    la = find(latgrid == CO2data.LAT(i));
    
    m = find(monthgrid == CO2data.MONTH(i));

    PCO2_grid_atmo(lo,la,m) = PCO2_atm(i);
end

Annual_mean_CO2A=nanmean(PCO2_grid_atmo,3);



%seawater minus the atmosphere


CO2_mean_differ = Annual_mean_CO2W - Annual_mean_CO2A;

figure(5); clf
worldmap world
contourfm(latgrid, longrid, CO2_mean_differ','linecolor','none');
colorbar
geoshow('landareas.shp','FaceColor','black')
title('Annual Mean Difference pCO2 of Seawater and Air (\muatm)')


%% 6. Calculate relative roles of temperature and of biology/physics in controlling seasonal cycle
%<--
Annual_mean_SST=nanmean(SST_grid,3);

repAMS = repmat(Annual_mean_SST,1,1,12); 

PCO2_BP = PCO2_grid.*exp(0.0423.*(repAMS-SST_grid));

repAMC = repmat(Annual_mean_CO2W,1,1,12);

PCO2_T = repAMC.*exp(0.0423.*(SST_grid-repAMS));

%% 7. Pull out and plot the seasonal cycle data from stations of interest
%Do for BATS, Station P, and Ross Sea (note that Ross Sea is along a
%section of 14 degrees longitude - I picked the middle point)

%<--
%location of BATS station data
Bat_lat = find(latgrid == 32);
[~,Bat_lon] = min(abs(longrid-64));
 
BATSBP_season=squeeze(PCO2_BP(Bat_lat,Bat_lon,:));
BATST_season = squeeze(PCO2_T(Bat_lat,Bat_lon,:));
% The station nearest to the location has all NaN values, not sure how to
% adjust for that 


%location of Ocean Station Papa

[~,OSP_lat] = min(abs(latgrid-50));
[~,OSP_lon] = min(abs(longrid-145));

OSPBP_season=squeeze(PCO2_BP(OSP_lat,OSP_lon,:));
OSPT_season = squeeze(PCO2_T(OSP_lat,OSP_lon,:));

figure(6) 

plot(monthgrid,OSPBP_season,'o-')
hold on 
plot(monthgrid, OSPT_season,'o-')
% Ross Sea Station 

[~,RSS_lat] = min(abs(latgrid-76.5));
[~,RSS_lon] = min(abs(longrid-173)); 

RSSBP_season=squeeze(PCO2_BP(RSS_lat,RSS_lon,:));
RSST_season = squeeze(PCO2_T(RSS_lat,RSS_lon,:));

figure(7) 

plot(monthgrid,RSSBP_season,'o-')
hold on 
plot(monthgrid, RSST_season,'o-')

%% 8. Reproduce your own versions of the maps in figures 7-9 in Takahashi et al. 2002
% But please use better colormaps!!!
% Mark on thesese maps the locations of the three stations for which you plotted the
% seasonal cycle above

%<--


