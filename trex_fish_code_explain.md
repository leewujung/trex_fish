# Trex fish code

## Main functions
* `beamform_cardioid_coherent`: coherent cardioid beamforming
* `beamform_cardioid_incoh`: incoherent cardioid beamforming (processing from Jie's original code)
* `beamform_linear_coherent`: coherent cardioid beamforming
* `beamform_linear_incoh`: incoherent cardioid beamforming (swap out linear_beamform.m for cardioid routine from Jie's code)
* `subset_beamform`: Extract and save a subset of beamformed data for faster access


## Subfunctions
* `linear_beamformer`: incoherent linear beamforming function (modified from Jie's incoherent cardioid beamdorming function)
* `fit_pie`: Find range of angle and range (distance from source) that cover the specified [x,y] polygon
* `get_ra_idx_crd_coh`: get corresponding indices for range/angle vector given selected range/angle
* `get_pie_outlineo`: get outline of cut area specified by the desired range of angle and range
* `get_SL`: get source level for particular run number and waveform
* `get_TVR_ITC2015`: get TVR curve for source ITC-2015
* `get_mf_env_xy`: get envelope of matched filter output, it's smoothed and decimated version, and corresponding x,y coordinates for plotting using pcolor
* `get_stat`, `findEchoDist_kde`, `findEchoDist` to get echo statistical info
* `compensate_echo_spectrum`: compensating echo spectrum for all gains: FORA loading, FORA system gain, beamforming gain, and added energy from pulse compression

## Others
* `Triplet_processing_toolbox`: Jie's original code for incoherent cardioid beamforming; my code use some of the subfunctions for reading in data and associated log files
* `beamform_results_cmp`: Comparing ping#150 from run 131 for all beamforming results
* `beamform_check_simu_src`: Generate simulated data to check the scaling (vertical shift in the log domain) for the beamforming routines
* `check_sig_energy`: used in conjunction with `beamform_check_simu_src`


