Hello and welcome to the README :-)

MATLAB codes work using the data in the data folder.

Run the following codes to:
-Obtain and plot the results for the backward FTLE analysis: backward_ftle.m
-Obtain and plot the results for the forward FTLE analysis: forward_ftle.m
-Calculate and plot the percentage of stranded particles: stranded_particle_percentage.m
-Calculate and plot the percentage of stranded particles as a function of release time: stranding_percentages_by_release.m
-Calculate and plot the mean stranding time: mean_stranding_time.m
-Obtain and plot the Liu-Weisberg skill score as a function of windage factor for the comparison of simulated particles with observed buoy trajectories: plot_skillscore_windage.m
-Plot buoy and simulated particle trajectories: plot_particles_buoy_trajectories.m

**********************************
In case you have installed OpenDrift (https://opendrift.github.io/install.html) and want to run simulations with the ROMS surface currents and ERA5 winds, you can find the code opendrift-buoy-simulations.py. In this code you can re-run the simulations we used for comparing particle trajectories with observed trajectories of undrogued buoys from the NOAA Global Drifter Program (https://doi.org/10.25921/7ntx-z961). The surface currents (1kmcurrents_buoys_for_opendrift.nc, 5kmcurrents_buoys_for_opendrift.nc) and ERA5 winds (OD_vientosERA5_2022.nc, OD_vientosERA5_2023.nc) in the data folder are ready to be read by OpenDrift. The output from this code can be used to run buoy_validation_nc_output_to_mat.m
************************************

GGs,
Ana Lucia de Santos Medina (https://github.com/luciadesanmed)
