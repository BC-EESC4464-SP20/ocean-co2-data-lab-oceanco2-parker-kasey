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
CO2data = ans;
longrid = unique(CO2data.LON); 
latgrid = unique(CO2data.LAT);
monthgrid = unique (CO2data.MONTH);
longrid(73)= 2.5;



%Create empty 3-dimensional arrays of NaN values to hold your reshaped data
    %You can make these for any variables you want to extract - for this
    %lab you will need PCO2_SW (seawater pCO2) and SST (sea surface
    %temperature)
PCO2_grid = NaN([length(longrid), length(latgrid), length(monthgrid)]);

SST_grid = NaN([length(longrid), length(latgrid), length(monthgrid)]);

%% 2b. Pull out the seawater pCO2 (PCO2_SW) and sea surface temperature (SST)
%data and reshape it into your new 3-dimensional arrays

PCO2 = CO2data.PCO2_SW;
 SST = CO2data.SST;    
    
for i = 1:length(PCO2)
    
    lo = find(longrid == CO2data.LON(i)); 
    
    la = find(latgrid == CO2data.LAT(i));
    
    m = find(monthgrid == CO2data.MONTH(i));

    PCO2_grid(lo,la,m) = PCO2(i);
    
    SST_grid(lo,la,m) = SST(i);
end

%PCO2_grid(73,:,:)=PCO2_grid(1,:,:);
%SST_grid(73,:,:)=SST_grid(1,:,:);
 
%% 3a. Make a quick plot to check that your reshaped data looks reasonable
%Use the imagesc plotting function, which will show a different color for
%each grid cell in your map. Since you can't plot all months at once, you
%will have to pick one at a time to check - i.e. this example is just for
%January
figure 
imagesc(latgrid,longrid,flipud(SST_grid(:,:,1)'));
colorbar

title('January Sea Surface Temperature (^oC)')


%% 3b. Now pretty global maps of one month of each of SST and pCO2 data.
%I have provided example code for plotting January sea surface temperature
%(though you may need to make modifications based on differences in how you
%set up or named your variables above).

figure
worldmap world
contourfm(latgrid, longrid, SST_grid(:,:,1)','linecolor','none');
colorbar('southoutside')
geoshow('landareas.shp','FaceColor','black')
title('January Sea Surface Temperature (^oC)')

%%

%Check that you can make a similar type of global map for another month
%and/or for pCO2 using this approach. Check the documentation and see
%whether you can modify features of this map such as the contouring
%interval, color of the contour lines, labels, etc.

figure
worldmap world
contourfm(latgrid, longrid, PCO2_grid(:,:,1)','linecolor','none');
colorbar('southoutside')
geoshow('landareas.shp','FaceColor','black')
title('January pCO2 of Seawater (\muatm)')

%% 4. Calculate and plot a global map of annual mean pCO2
%<--

Annual_mean_CO2W=nanmean (PCO2_grid,3);

figure
worldmap world
contourfm(latgrid, longrid, Annual_mean_CO2W','linecolor','none');
colorbar('southoutside');
geoshow('landareas.shp','FaceColor','black')
title('Annual Mean pCO2 of Seawater (\muatm)')

%% 5. Calculate and plot a global map of the difference between the annual mean seawater and atmosphere pCO2
%<--
% PCO2_grid_atmo = NaN([length(longrid), length(latgrid), length(monthgrid)]);

% Taken from ESRL https://www.esrl.noaa.gov/gmd/ccgg/trends/gl_data.html
PCO2_atm = 368.83;


%seawater minus the atmosphere


CO2_mean_differ = Annual_mean_CO2W - PCO2_atm;

figure
worldmap world
contourfm(latgrid, longrid, CO2_mean_differ','linecolor','none');
cmocean('balance','zero')
h = colorbar('southoutside')
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

sitelat = [32.83 50' -76.5];
sitelon = [295.17 215 176];

latindex = [];
lonindex = [];

for i = 1:3
    ilat = find(sitelat(i) < latgrid);
    ilon = find(sitelon(i) < longrid);
    
    latindex(i) = ilat(1);
    lonindex(i) = ilon(1);
    
if latindex(i) ~= 1    
    lat1 = latgrid(latindex(i)-1); 
    lat2 = latgrid(latindex(i));
    if sitelat(i) < [lat1 + (lat2-lat1)/2]
        latindex(i) = latindex(i) - 1;
    elseif sitelat(i) >= [lat1 + (lat2-lat1)/2]
        latindex(i) = latindex(i);

end
elseif latindex == 1
latindex(i) = latindex(i);    
end

if lonindex(i) ~= 1    
    lon1 = longrid(lonindex(i)-1); 
    lon2 = longrid(lonindex(i));
    if sitelon(i) < [lon1 + (lon2-lon1)/2]
        lonindex(i) = lonindex(i) - 1;
    elseif sitelon(i) >= [lon1 + (lon2-lon1)/2]
        lonindex(i) = lonindex(i);

    end
    
elseif lonindex == 1
lonindex(i) = lonindex(i);    
end

gridcoors(i,:) = [latgrid(latindex(i)) longrid(lonindex(i))];

end



for i = 1:3
    iSST_O = squeeze(SST_grid(lonindex(i),latindex(i),:));
    iPCO2_O = squeeze(PCO2_grid(lonindex(i),latindex(i),:));
    iPCO2_BP = squeeze(PCO2_BP(lonindex(i),latindex(i),:));
    iPCO2_T = squeeze(PCO2_T(lonindex(i),latindex(i),:));
    figure
    subplot(3,1,1)
    plot(iSST_O,'k')
    xlim ([1 12])
    ylabel('^oC')
    title('Sea Surface Temperature')
    subplot(3,1,2)
    plot(iPCO2_O, 'k')
    xlim ([1 12])
    ylabel('\muatm')
    title('pCO2 of Seawater')
    xlim ([1 12])
subplot(3,1,3)
plot(iPCO2_BP,'g')
xlim ([1 12])
hold on
plot(iPCO2_T,'b');
xlim ([1 12])
xlabel('Months')
ylabel('Seawater pCO2 (\muatm)')
title('The Temperature and Bio-phsyical Effects on Seawater pCO2') 
legend('Bio-physical Effect','Temperature Effect')
hold off
end
    
%% 8. Reproduce your own versions of the maps in figures 7-9 in Takahashi et al. 2002
% But please use better colormaps!!!
% Mark on thesese maps the locations of the three stations for which you plotted the
% seasonal cycle above

%<--

for i = 1:length(longrid)
    for j = 1:length(latgrid)
        CO2_BP_A(i,j) = max(PCO2_BP(i,j,:)) - min(PCO2_BP(i,j,:));
        CO2_T_A(i,j) = max(PCO2_T(i,j,:)) - min(PCO2_T(i,j,:));
        CO2_A_diff(i,j) = CO2_T_A(i,j) - CO2_BP_A(i,j);
    end
end

%figure 7 in paper 
figure
worldmap world
contourfm(latgrid, longrid, CO2_BP_A','linecolor','none');
h = colorbar('southoutside');
geoshow('landareas.shp','FaceColor','black')
title('The Seasonal Biological Drawdown of Seawater pCO2')
xlabel(h,'pCO2 Drawdown (\muatm)','FontSize',14,'FontWeight','bold')
hold on
scatterm(sitelat,sitelon,40,'m','filled')

%%
%Figure 8 in paper
figure
worldmap world
contourfm(latgrid, longrid, CO2_T_A','linecolor','none');
h=colorbar('southoutside')
geoshow('landareas.shp','FaceColor','black')
title('Seasonal Temperature Effect on Seawater pCO2 ')
xlabel(h, 'pCO2 Change (\muatm)','FontSize',14,'FontWeight','bold')
hold on
scatterm(sitelat,sitelon,40,'m','filled')
%%
%figure 9 in paper 
figure
worldmap world
contourfm(latgrid, longrid, CO2_A_diff','linecolor','none');
cmocean('balance','pivot',1)
h = colorbar('southoutside')
geoshow('landareas.shp','FaceColor','black')
title('The Difference Between the Seaonal Temperature and Bio-physical Effects on pCO2')
xlabel(h,'pCO2 (\muatm)','FontSize',14,'FontWeight','bold')
hold on
scatterm(sitelat,sitelon,40,'m','filled')

