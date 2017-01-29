# TREX 13 fish echo analysis @APL

## 2016/08/29
### Pick up from June/July
Code:

- `linear_beamformer` -- performning linear beamforming on unpacked TREX data
- `beamform_linear_20160627` -- modified from Jie's code (triplet array) and only use one row of the array for linear beamforming.
- `beamform_linear_noMF_20160628` -- skips the matched filter processing procedure and produce raw echo output. This was used in the energy normalizer
- `split_window_normalizer` -- use MF results directly for normalization (ref: Fialkawski & Gauss 2010, IEEE JOE)
- `energy_normalizer` -- combine MF and noMF results for normalization (ref: Fialkawski & Gauss 2010, IEEE JOE)

### ASA Hawaii abstract
_**Mid-frequency clutter and reverberation characteristics of fish in a shallow ocean waveguide**_

Wu-Jung Lee, Dajun Tang, Eric I. Thorsos (Applied Physics Laboratory, University of Washington)

Horizontal-looking, mid-frequency sonar systems allow synoptic underwater observation over kilometer scales and are useful for a wide range of applications. However, quantitative assessment of fish aggregations using such systems in a shallow water environment is challenging due to the complexity of sound interactions with the surface and seafloor. Based on data collected during TREX13 (Target and Reverberation Experiment 2013), this study investigates methods to reliably distinguish fish echoes from background contributions to reverberation. The data were collected on a fixed, horizontal receiving line array from a source transmitting linear frequency-modulated signals in the band between 1.8-3.6 kHz. The experimental site was nearly isodepth (approximately 20 m) and characterized by a well-mixed, isothermal water column. Fish echoes were ubiquitously found in the data, with noticeable differences between day and night. In a particularly interesting case, a large aggregation of fish was observed emerging from a shipwreck, evolving in space, obscuring the wreck echoes temporarily, and eventually dispersing and disappearing into the overall reverberation background. Using a physics-based approach, the scattering level, statistical features, and spatial characteristics of both the fish echoes and background reverberation in this data set were analyzed and modeled. [Work supported by the APL postdoctoral fellowship and ONR.]

### Beamwidth difference for MF and no-MF results
Code: `beamwidth_cmp_MF_noMF` --> MF results seem to be in the intermediate beamwidth and also suppress sidelobes compared to single frequency results.

<figure>
  <img src=".\figs_results\beamwidth_cmp_MF_noMF_run87\beamwidth_cmp_MF_noMF.png" width="500">
</figure>

### Linear beamforming by using a shorter array
Code: `beamform_linear_shortarray` --> beamwidth increases as expected

<figure>
  <img src=".\figs_results\beamwidth_cmp_array_length_run87\beamwidth_cmp_array_length.png" width="500">
</figure>



#####################################################
## 2016/08/30
### Nearby runs from run 87
Run 79, 94 both contain the "converging" fish pattern as seen in run 87. The groups are fully converged around 5AM. Run 103 also has the same pattern but the data quality seems bad (echogram flashing under the same color scale). Run 120 covers the same location during overnight run as well but didn't see the same diverging/converging pattern. Run 124 and 131 also contain this pattern and the data appear to be really "clean". Diverging time usually ~8PM. Run 69 also contains this pattern, didn't cover diverging but cover converging. Run 62 contains this pattern but SNR seems bad.

**Run/waveform summary:**

- Run 62 -- [wfm 3, 3.4-3.5 kHz] contains this pattern but SNR seems bad
- Run 69 -- [wfm 3, 3.4-3.5 kHz] contains this pattern, didn't cover diverging but cover converging
- Run 79 -- [wfm 3, 3.4-3.5 kHz] contains the "converging" fish pattern as seen in run 87
- Run 87 -- [wfm 1, 3.4-3.5 kHz] fish diverging and converging pattern
- Run 94 -- [wfm 1, 1.8-2.0 kHz] contains the "converging" fish pattern as seen in run 87
- Run 103 -- [wfm 4, 3.3-3.5 kHz] covers the same location during overnight run but didn't see the same diverging/converging pattern
- Run 124 -- [wfm 2, 2.7-3.6 kHz] contain this pattern and the data appear to be really "clean"
- Run 131 -- [wfm 2, 2.7-3.6 kHz] contain this pattern and the data appear to be really "clean"

**Need to process Run 94 with Wfm 3.**



#####################################################
## 2016/08/31
### Cardioid beamforming
Read Haralabus and Baldacci 2006 IEEE paper, also read through Jie's cardioid beamforming code.

Questions to Jie:

1. What is `normalization_factor = (Npts*dt/tau)*10;` (line 196) ? Is this to compensate for the matched filter scaling?

2. What are the constants (46.95 and GainSet) added to be beamforming results on line 197? `ang_int = 10*log10( beamform * normalization_factor) + 46.95-GainSet;`

3. Is line 190 combining broadband results by integrating them? `beamform(nwin,:) = 2*sum(abs(Cardioid_beamformer_foraTrip_INFreq_Domain(select_data,X_a,Y_a,Z_a,fai,th,dt,cw,max(center_freq-full_bandwidth/2,1),min(center_freq+full_bandwidth/2,1/dt*0.5))).^2,2);`

4. In the function `Cardioid_beamformer_foraTrip_INFreq_Domain`, the calibration factor $6 \pi f(r sin(\theta))^2/c$ was computed according to each frequency (by changing f). The Haralabus & Baldacci paper seems to suggest that LFM can be calibrated just using the center frequency. Is this a modification to make the calibration more precise?

### Echo statistics near wrecks: Run 87 (incoherent processing results)
Look into how echo statistics change with and without fish around the wrecks. Below wreck1 is the wreck where more fish emerged from, and wreck2 is on the left of wreck1 where only a few fish came out.

<figure>
  <img src=".\figs_results\echo_stat_wreck_multiping_20160831\echo_stat_wreck_multiping_20160831_wreck1_summary.png" width="550">
</figure>
<figure>
  <img src=".\figs_results\echo_stat_wreck_multiping_20160831\echo_stat_wreck_multiping_20160831_wreck2_summary.png" width="550">
</figure>

**Wreck1 location**

<figure>
  <img src=".\figs_results\echo_stat_wreck_multiping_20160831\echo_stat_wreck_multiping_20160831_wreck1_p0151.png" width="800">
</figure>
<figure>
  <img src=".\figs_results\echo_stat_wreck_multiping_20160831\echo_stat_wreck_multiping_20160831_wreck1_p0181.png" width="800">
</figure>

**Wreck2 location**

<figure>
  <img src=".\figs_results\echo_stat_wreck_multiping_20160831\echo_stat_wreck_multiping_20160831_wreck2_p0151.png" width="800">
</figure>
<figure>
  <img src=".\figs_results\echo_stat_wreck_multiping_20160831\echo_stat_wreck_multiping_20160831_wreck2_p0181.png" width="800">
</figure>



#####################################################
## 2016/09/01-02
### Echo statistics near wrecks: Run 94 (incoherent processing results)
See very similar results as in Run 87 above that when fish obscured the wreck the scintillation index is smaller (wreck 1). Interesting oscillation pattern for wreck 2.

<figure>
  <img src=".\figs_results\echo_stat_wreck_multiping_20160901\echo_stat_wreck_multiping_20160901_wreck1_summary.png" width="550">
</figure>
<figure>
  <img src=".\figs_results\echo_stat_wreck_multiping_20160901\echo_stat_wreck_multiping_20160901_wreck2_summary.png" width="550">
</figure>

### Discussion with DJ
Simulation for fish school echoes? multiple identical scatterers with reasonable TS prescribed. Maybe can prescribe some movement path for each of the fish to simulate what's shown in the data. This may not be doable before the Monterey TREX workshop but it's good to show something preliminary.

### Echo pdf shape (linear beamforming results)
Echo pdf shape seems to be a little weird for background-only section... supposed to be Rayleigh, but it deviates from it significantly at the low-amplitude portion of the pdf curve. See below:

<figure>
  <img src=".\figs_results\echo_stat_wreck_multiping_bfcmp_20160901_run094\echo_stat_wreck_multiping_bfcmp_20160901_run094_p0803.png" width="800">
</figure>
<figure>
  <img src=".\figs_results\echo_stat_wreck_multiping_bfcmp_20160901_run087\echo_stat_wreck_multiping_bfcmp_20160901_run087_p0151.png" width="800">
</figure>

### Echo pdf shape (cardioid beamforming, incoherent results)
Results are qualitatively similar to the linear beamformed case. In the example below the ensemble is formed by taking samples over multiple pings within the same range bin along the direction in the middle of the white box.

<figure>
  <img src=".\figs_results\echo_stat_multiping_cardioid_20160902_run087\echo_stat_multiping_cardioid_20160902_run087_p0151.png" width="800">
</figure>

Compare:
results from cardioid beamforming

<figure>
  <img src=".\figs_results\echo_stat_multiping_cardioid_20160902_run087\echo_stat_multiping_cardioid_20160902_run087_summary.png" width="550">
</figure>

results from linear beamforming

<figure>
  <img src=".\figs_results\echo_stat_wreck_multiping_bfcmp_20160901_run087\echo_stat_wreck_multiping_bfcmp_20160901_run087_summary.png" width="550">
</figure>


### Codes for echo statistics from incoherent results
- `echo_stat_bkg_fish`
- `echo_stat_wreck`
- `echo_stat_wreck_multiping_20160831`
- `echo_stat_wreck_multiping_20160901`
- `echo_stat_wreck_multiping_bfcmp_20160901`
- `echo_stat_wreck_multiping_bfcmp_cardioid_20160901`
- `echo_stat_multiping_cardioid_20160902`



#####################################################
## 2016/09/07
### Weird echo pdf shape
Had a conversation with Tim about this. He said this is called "evacuated" pdf where the low amplitude component are swamped or eliminated from the data. This is due to the incoherent summation operation in the Fourier transformed Cardioid beamformed samples in Jie's code.

### Reprocess data -- beamforming, coherent operation 
Code: `beamform_linear_coherent.m` --> beamforming first and then pulse compression, both in frequency domain. Can select only certain range of data to process.


### Array angle problem
Spent some time again to figure out the angle convention (see figure below). Also found out that the magnetic declination at the experimental site (lat 30.0599, lon -85.6811) was actually 3 deg 18 min, instead of 3.18 deg. Corrected this in my code.

In the figure below,

- `beamform_angle` is set to -87 to 87 deg
- `polar angle` is calculated by `polar_angle = -process_heading-beamform_angle+mag_decl;`
- its mirror image (since it's linear beamforming) is `polar_angle_mir = -process_heading+180+beamform_angle+mag_decl;`
- Magnetic declination is `mag_decl = 3+18/60;  % [deg]`.


<figure>
  <img src=".\figs_results\20160908_array_angle\20160908_array_angle.png" width="800">
</figure>

### Re-visit Kraken modeling results
Code: `calc_ir_time_shifted_20160425` --> used to predict received time series. The figures below verified that the reduced time approach is working.

**Impulse response only:**

<figure>
  <img src=".\kraken_model\calc_ir_time_shifted_20160425\calc_ir_time_shifted_20160425_ir.png" width="500">
</figure>
<figure>
  <img src=".\kraken_model\calc_ir_time_shifted_20160425\calc_ir_time_shifted_20160425_ir_zoom.png" width="500">
</figure>

**After convolving with transmit signal:**

<figure>
  <img src=".\kraken_model\calc_ir_time_shifted_20160425\calc_ir_time_shifted_20160425_w_tx.png" width="500">
</figure>


#####################################################
## 2016/09/08-/10
### Model echoes from fish aggregations
Code: `simu_fish_echo_20160908` --> use the "reduced time" approach to calculate the echoes from each individual fish and coherently average the results. Simulated echoes are calculated for 48 hydrophones (location taken from TREX data, ping 0001 from Run 87). The simulated echoes are then beamformed to compare with the fish locations.

### Array angle double check
Compare the array angle calculated in the coherent linear beamform routine (`beamform_linear_coherent`), incoherent beamform routine (`beamform_linear`), and Jie's code (`TREX_reverb_data_processing_main_program.m`). Note that the magnetic declination should be 3+18/60 deg instead of 3.18 deg. But here use 3.18 deg for comparison with Jie's case.

<figure>
  <img src=".\figs_results\20160910_array_angle\20160910_array_angle_cmp.png" width="600">
</figure>


#####################################################
## 2016/09/13-15
### Discussion with DJ
On Monterey bay workshop: make a clear focus on the message you want to deliver in the talk and impress the audience + program officer.

On fish data simulation:

- consider using simple phase shift for time series simulation for each array element, instead of calculating each fish-hydrophone pair --> try to do some comparison to see is this approach can give accurate answer.
- consider simplifying the fish range part of calculation if the model fish school is constrained in a relatively small geographical area. 

### Simplify calculation for each mic element
Code: `simu_fish_echo_20160913_simplify` Take DJ's suggestion to speed up repeated calculation for each hydrophone. Below are verification figures showing the phase compensation approach can give the right output.

### Revise linear incoherent code
Code: `beamform_linear_incoh` -- **revise to correct 1) the normalization factor and 2) beamforming angles**. Revised from `beamform_linear_20160627`. Revising this code so that the coherently and incoherently processed beamforming results can be compared side-by-side.

Reference document 'foracal.pdf' by Jie for the gain setting. Use `Ll = 20*log10(x) + 42.35 - G (Linear level)` suggested. The gain factor G is can be found from document 'ITC2015 source levels for all waveforms.docx'


### Compare coherent and incoherent broadband beamforming results
Code: `bf_lin_coh_incoh_cmp` -- spent a lot of time because of an error in setting the Gain in the code. After correcting this Gain factor the incoh and coh processed results corresponds to each other well. Below are examples from Run 87. Note the images are detrended by $30log_10(r)$ where $r$ is the range in meter.

**Ping 150:**

<figure>
  <img src=".\figs_results\bf_lin_coh_incoh_cmp_run087\bf_lin_coh_incoh_cmp_run087_p0150_img_zoom1.png" width="800">
</figure>
<figure>
  <img src=".\figs_results\bf_lin_coh_incoh_cmp_run087\bf_lin_coh_incoh_cmp_run087_p0150_img_zoom2.png" width="800">
</figure>

**Ping 200:**

<figure>
  <img src=".\figs_results\bf_lin_coh_incoh_cmp_run087\bf_lin_coh_incoh_cmp_run087_p0200_img_zoom1.png" width="800">
</figure>
<figure>
  <img src=".\figs_results\bf_lin_coh_incoh_cmp_run087\bf_lin_coh_incoh_cmp_run087_p0200_img_zoom2.png" width="800">
</figure>

**Smoothed time series for ping 150 and ping 200:**

<figure>
  <img src=".\figs_results\bf_lin_coh_incoh_cmp_run087\bf_lin_coh_incoh_cmp_run087_p0150_ts1angle.png" width="400">
</figure>
<figure>
  <img src=".\figs_results\bf_lin_coh_incoh_cmp_run087\bf_lin_coh_incoh_cmp_run087_p0200_ts1angle.png" width="400">
</figure>

### Test to plot only smoothed echogram
Code: `bf_lin_coh_smooth_cmp` -- check to make sure it's OK to smooth and sub-sample the beamformed echo time series for faster plotting. There is no obvious differences between the raw results and the smoothed/sub-sampled results (see below): 

<figure>
  <img src=".\figs_results\bf_lin_coh_smooth_cmp_run087\bf_lin_coh_smooth_cmp_run087_p0150_img_sm100.png" width="800">
</figure>
<figure>
  <img src=".\figs_results\bf_lin_coh_smooth_cmp_run087\bf_lin_coh_smooth_cmp_run087_p0200_img_sm100.png" width="800">
</figure>

Check the smoothed/sub-sampled time series:

<figure>
  <img src=".\figs_results\bf_lin_coh_smooth_cmp_run087\bf_lin_coh_smooth_cmp_run087_p0150_ts1angle_sm100.png" width="600">
</figure>
<figure>
  <img src=".\figs_results\bf_lin_coh_smooth_cmp_run087\bf_lin_coh_smooth_cmp_run087_p0200_ts1angle_sm100.png" width="600">
</figure>

### Compile movies
Code: `bf_lin_coh_smooth_plot_movie` -- plot polar echogram and compile movies. Testing 2 zoom scales to see which works better.



#####################################################
## 2016/09/19
### Wreck loc/magnetic inclination
Check with Jie about the wreck locations and magnetic declination. Apparently the variable `process_angle` is to force the angle of the array, and in that case the magnetic declination is already taken care of. We compared our processed results with the wreck location (from her code) plotted. Using the fixed wreck locations as a reference, my processing results would correspond to hers if I remove the 3+18/60 deg magnetic declination that was originally in the code. For comparsion see below. The magenta circles are the wreck locations. Also the wreck near the fish "action" site is USS Strength.

Compare how the 3-wreck site line up with the USS Strength site.

<figure>
  <img src=".\figs_results\20160918_wreck_loc\20160918_wreck_loc.png" width="600">
</figure>
<figure>
  <img src=".\figs_results\20160918_wreck_loc\20160919_wreck_loc_remove_magnetic_decl.png" width="600">
</figure>

### More on wreck location
Marked two wrecks seen on the sidescan map sent by Todd (folder `TREX13-2 (Google Earth KMZ Files - August 2014)`). The two wreck sites correspond to the top and left strong scattering sites on the echogram map. Cannot see the 3rd strong scattering site (see below). Note the echogram map is rotated to the right orientation without the additional magnetic declination.

<figure>
  <img src=".\figs_results\20160918_wreck_loc\20160919_remove_magnetic_decl_sidescan_wreck_loc.png" width="600">
</figure>

To get the wreck location I used `GUI_latlon` to convert Lat-Lon to X-Y coordinates on the map. The wreck GPS Lat-Lon coordinates are stored in `TREX13-2 (Google Earth KMZ Files - August 2014)\wreck_marks.kmz`.

### Fix beamform angle
Code `fix_bf_angle` -- use this to fix beamform angles (originally have magnetic declination compensated but Jie said that's not necessary, just use the `process_angle`).

Fixed the angles for current beamformed data in folders `beamform_linear_coherent_*`.


#####################################################
## 2016/09/20-23
### Observation location and reproducibility
Large scale location of observations:
<figure>
  <img src=".\20160923_trex_monterey_v3\Slide7.PNG" width="700">
</figure>

**Run 87** -- waveform 3.5-3.6 kHz

<figure>
  <img src=".\20160923_trex_monterey_v3\Slide9.PNG" width="700">
</figure>

**Run 131** -- waveform 2.7-3.5 kHz

<figure>
  <img src=".\20160923_trex_monterey_v3\Slide10.PNG" width="700">
</figure>


### Fish spectrum
Code `echo_stat_int_coh_fsh_bkg_cmp_raw_indivfig.m` and `echo_stat_int_coh_fsh_bkg_cmp_raw.m` -- results from run 131 shown in the Monterey workshop slide below:

<figure>
  <img src=".\20160923_trex_monterey_v3\Slide13.PNG" width="800">
</figure>

Observations:

- no obvious consistent resonance structure in fish spectrum
- quite a bit of variability in fish spectrum

When all pings are pooled together, there is variation with the fish spectrum (see below), but there is no consistent trend suggesting resonance structure. This is uncalibrated spectrum.

<figure>
  <img src=".\figs_results\echo_int_coh_wreck_run131\echo_int_coh_wreck_run131_spec_all.png" width="500">
</figure>


### Maximum reverberation level in boxes
Code `echo_int_coh_wreck.m` -- results from run 131 shown in the Monterey workshop slide below:

<figure>
  <img src=".\20160923_trex_monterey_v3\Slide16.PNG" width="800">
</figure>

Observations:

- max value in the top box increases dramatically as fish moved into the area as expected
- max value in the bottom box started to decrease as fish emerged out from the wreck and keeps decreasing until around ping 550 when the max values between the two boxes are comparable
- this seems to be hinting that fish echoes contributed to the higher *apparent* wreck echoes during the day?

### Total energy contained in box around wreck
Code `echo_int_coh_sum_energy_seq2.m` -- results from run 131 shown in the Monterey workshop slide below:

<figure>
  <img src=".\20160923_trex_monterey_v3\Slide17.PNG" width="800">
</figure>

Observations:

- there is a slight decrease of total energy so there was no conservation of energy...
- possibility 1: fish swimbladder change induced changes in TS per fish, which in turn changed the the total scattered energy
- possibility 2: the fish aggregation was so dense around the wreck during the day there that the total scattered energy did not reflect the echoes would be from the sum of each individual fish




#####################################################
## 2016/09/27
### Cardioid beamforming
Code `beamform_cardioid_coherent.m` -- revised from `beamform_linear_coherent.m`

Referencing Jie's code `Cardioid_beamformer_foraTrip_INFreq_Domain.m` to figure out the details of cardioid beamforming. The problem is that the Haralabus & Baldacci 2006 IEEE JOE paper only introduced cardioid beamforming in a reduced form when considering only one triplet within the whole array, so the array length dimension (y-axis in the paper) was not well-explained. Based on Jie's code, the key is to follow the verbal explanation in the paper to do the processing: 
> Cardioid beamforming is implemented by a) shifting the triplet signals to the center of the triplet, b) weighting them by their projection on ta desired direction and c) summing them.

Following the papers notation, assume $u(\theta,\phi)$ is the unit vector pointing to the beamforming direction and $v_{jk}$ is the position vector of each array element, the phase delay factor using the beamforming should be $e^{j k \left< u(\theta,\phi) \cdot v_{jk} \right<}$. Assume $w=(dx,dy,dz)$ which is the position vector of each hydrophone element *from the center of the associated triplet*. the amplitude multiplication factor should be $w \cdot u$. Note that it is important to multiple the beamformed results by the calibration factor $C=6 \pi f (r \sin \theta)^2/c$, where $c$ is the sound speed, $r$ is the radius of each triplet, and $\theta$ is the azimuthal beamform direction. If the calibration factor is not multiplied, the resultant beamform results would have a sinusoidal type of amplitude variation across $\theta$ due to the $(r \sin \theta)^2$ factor. 

### Array angle re-check
Wanted to verify again that the shipwreck/bridge locations fit with cardioid beamforming results too. Assuming the sidescan-derived wreck GPS locations are correct, using `process_heading=353` seems to be better than using `process_heading=356`. See figure below for comparison. (All results shown above/during the Monterey workshop were plotted using `process_heading=353`)

<figure>
  <img src=".\figs_results\20160927_cardioid_process_angle\cardioid_process_angle_run87_p150_353deg.png" width="600">
</figure>

<figure>
  <img src=".\figs_results\20160927_cardioid_process_angle\cardioid_process_angle_run87_p150_356deg.png" width="600">
</figure>



#####################################################
## 2016/10/04
### Check linear vs cardioid beamforming calibrated reverb level
Code: `bf_linear_cardioid_cmp.m`.

There seems to be a small discrepancy on the calibrated reverberation level between the linear and cardioid beamforming processing results. The cardioid beamforming results seem generally higher than the linear beamforming results by ~2 dB --> <span style="background-color:yellow">need to check this with Jie!</span>

In the figures below, -131$^o$ cut through the USS Strength wreck.

#### Ping 80:
<figure>
  <img src=".\figs_results\bf_linear_cardioid_cmp_run087\bf_linear_cardioid_cmp_run087_p0080_img.png" width="800">
</figure>
<figure>
  <img src=".\figs_results\bf_linear_cardioid_cmp_run087\bf_linear_cardioid_cmp_run087_p0080_ts_-131deg.png" width="800">
</figure>
<figure>
  <img src=".\figs_results\bf_linear_cardioid_cmp_run087\bf_linear_cardioid_cmp_run087_p0080_ts_-120deg.png" width="800">
</figure>

#### Ping 150:
<figure>
  <img src=".\figs_results\bf_linear_cardioid_cmp_run087\bf_linear_cardioid_cmp_run087_p0150_img.png" width="800">
</figure>
<figure>
  <img src=".\figs_results\bf_linear_cardioid_cmp_run087\bf_linear_cardioid_cmp_run087_p0150_ts_-131deg.png" width="800">
</figure>
<figure>
  <img src=".\figs_results\bf_linear_cardioid_cmp_run087\bf_linear_cardioid_cmp_run087_p0150_ts_-120deg.png" width="800">
</figure>

#### Ping 200:
<figure>
  <img src=".\figs_results\bf_linear_cardioid_cmp_run087\bf_linear_cardioid_cmp_run087_p0200_img.png" width="800">
</figure>
<figure>
  <img src=".\figs_results\bf_linear_cardioid_cmp_run087\bf_linear_cardioid_cmp_run087_p0200_ts_-131deg.png" width="800">
</figure>
<figure>
  <img src=".\figs_results\bf_linear_cardioid_cmp_run087\bf_linear_cardioid_cmp_run087_p0200_ts_-120deg.png" width="800">
</figure>

### Compare plotting raw and smoothed cardioid beamform data
Code: `bf_plot_raw_smooth_cmp`

It seems safe to use only the smoothed data. The resultant figures are qualitatively identical.

<figure>
  <img src=".\figs_results\bf_plot_raw_smooth_cmp_run087\bf_plot_raw_smooth_cmp_run087_p0100.png" width="800">
</figure>
<figure>
  <img src=".\figs_results\bf_plot_raw_smooth_cmp_run087\bf_plot_raw_smooth_cmp_run087_p0200.png" width="800">
</figure>

### Extract only a subset of beamformed data
Code: `extract_subset_bf_data_run087` -- for faster plotting and processing. See `bf_plot_raw_smooth_cmp` for plotting routines.



#####################################################
## 2016/10/05
### Check array heading using airhose/VLA locations
Code: `check_airhose_location` and `get_bf_plot_stuff`. Got airhose/VLA locations from Jie (file locations). It seems like there may be some problem in the GPS locations of these landmarks, because to match the shipwreck/bridge locations (lower-left quadrant) would require conflicting rotation directions compared to if we were to match the airhose/VLA location...

<figure>
  <img src=".\figs_results\check_airhose_location_run087\check_airhose_location_run087_p0111_353deg.png" width="700">
</figure>
<figure>
  <img src=".\figs_results\check_airhose_location_run087\check_airhose_location_run087_p0111_356deg.png" width="700">
</figure>

One possibility for the reason why the rotation required for matching shipwreck/bridge and airhose/VLA locations are contradictory may be that the boat's location was not accurate. For example, if the boat moves south by ~100 m, it would induce the opposite rotation angle requirement.


#####################################################
## 2016/10/07
### TREX fish ms figures
Revise figure plan and wrote figure captions and discussion points associated with each figure. File: `trex_fish_fig_v0.1.pptx`. There are a few things that need to be settled down before the everything can be written:

- spectral calibration for the whole system
- make sure there is no contamination from the opposite side for linear processing if linear processing results are to be used
- process data from other runs


#####################################################
## 2016/11/21
### Spectral calibration
Output voltage before feeding into transducer is in `HAARI_data/Amp_mon_data` (_mon_ for monitoring).
Jie's explanation on how the source can be calibrated is shown below:

![](./Documents/Jie_cal_notes.png){ width=70%}


************************************************************************
## TO-DO
- Annotate current version of codes and start a new folder for follow-up work
- [done--2016/09/20-23] compile results done before the workshop
- Binning and KDE results seem to be "shifted" horizontally when npt is small... LOOK INTO THIS!!!
- Figuring out the 3 dB differences between `echo_int_coh_sum_energy_seq2` and `echo_int_coh_sum_energy_seq3`.
- Calibrate the fish echo spectrum
- Use threshold and linking to extract a time series of "fish area" variation as a time series for all overnight runs 
- [done--2016/10/04] compare linear and cardioid beamforming results
- Fit K-distribution to the fish+wreck echo pdf (Tim's suggestion)
- Look at fish spectrum in 1.8-2.6 kHz along with 2.7-3.6 kHz
 
************************************************************************
## Codes after 2016/09/22
- `beamform_cardioid_coherent`
- `bf_linear_cardioid_cmp`
- `bf_plot_raw_smooth_cmp`
- `extract_subset_bf_data_run087`
- `check_airhose_location`
- `get_bf_plot_stuff` -- get the beamformed echo envelope and X,Y coordinates for plotting reverb map, called by `check_airhose_location`

## Codes before 2016/09/22
- `bf_lin_coh_data_subset` -- extract a subset from linear coherently beamformed data for faster processing and plotting
- `get_range_angle_idx_coh` -- get index of a selected range and angle extent, called by `bf_lin_coh_data_subset` and `bf_plot_raw_smooth_cmp`
- `echo_stat_int_coh_fsh_bkg_cmp_raw_indivfig` and `echo_stat_int_coh_fsh_bkg_cmp_raw` -- computer echo pdf and spectrum for each individual ping

************************************************************************
## List of goals
- better way to detrend the data
- comparing fish echoes and bottom only reverb characteristics
- simulate a wider beam by taking out some hydrophones in the array
- measuring rough speed of a patch movement
- difference of beamwidth for MF vs single frequency results