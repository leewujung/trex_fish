# TREX 13 fish echo analysis @APL
# Part II (2017)

##############################################
## 2017/01/13
Spent this past Mon/Wed/Fri trying to figure out the offset between my beamforming routine and Jie's output. Finally figured out what's going on...

There are 4 compensations that need to be taken into account:

1. Gain associated with match filtering (`gain_pc` in code).
2. Gain associated with beamforming (`gain_beamform` in code). This is se to `20*log10(48)` because there are 48 elements when used in the linear configuration, so total energy is enhanced by 48 times. Note that since cardioid beamforming was _normalized_ to the level of linear beamforming output, this factor is the same under cardioid beamforming.
3. Differences of load when driving the FORA array (`gain_load` in code). The gain is 46.95 dB when the array is driven as triplet, and 42.35 dB when the array is driven as linear array. My confusion before was that I thought the gain would be different when different combinations of elements were used.
4. FORA system gain (`gain_sys` in code). This gain is 12 dB for all runs starting from run 41, and 18 dB before that.


##############################################
## 2017/01/23
### Calibrate for source level
Going back to original code `get_SL`. The transmitted voltage is recorded at the output of the power amplifier (L10) before feeding into the transducer (see figure below). Data are called **HAARI**. HAARI files are sorted according to dates and transmit start time. In the data, ch0 is voltage and ch1 is current.

Transducer used is ITC-2015. Use `get_TVR_ITC2015` to get the TVR curve.

Unit for TVR is dB//uPa/V @1m. Unit of voltage recorded on HAARI (Vh) is dB//V. So source level (SL) is TVR*Vh. Note there is a scaling factor `A.ch_0_voltage_scale_factor=100` that needs to be applied to get the current transmit signal voltage.

Updated code `get_SL`:

* Note Jie uses **rms** values for calculating the source level, but I have to use the actual spectral level for potential resonance fitting using fish scattering models. In `get_SL`, the rms value is `tx_rms_dB`, which can be recovered by calculating `10*log10(sum(10.^(tx_psd_dB/10))*df)` (integrating over all spectrum).
* In the output of `get_SL`, `SL=SL_psd/fs`where `fs` is the sampling frequency, i.e., `SL_psd` is the spectral level.

	![](../Documents/Jie_cal_notes_sub.jpg){ width=70%}


##############################################
## 2017/01/25, 27
* Check to make sure `subset_beamform` is getting the right set of data --> Yes
* Revise `get_pie_outline` to work with degree input and simplied its output to only x,y coordinate points
* Sorting out the fft/psd issues:
	Within `get_spectrum_mtm`, the following are equal:
	```
	[10*log10(sum(abs(sig).^2,1))' 10*log10(sum(10.^(sig_fft_dB/10),1))']
	ans =
		155.8193  155.1548
		155.7985  155.2243
		155.8041  155.3125
		155.7904  155.3492
		155.7719  155.3426
		155.7733  155.3355
		155.7757  155.3366
		155.7324  155.3077
		155.6346  155.2192
		155.5392  155.0943
		155.5087  154.9790

	[10*log10(sum(abs(sig).^2,1)/fs)' 10*log10(sum(10.^(sig_psd_dB/10),1))']
	ans =
		114.8502  114.1857
		114.8294  114.2552
		114.8350  114.3434
		114.8213  114.3801
		114.8028  114.3735
		114.8042  114.3664
		114.8066  114.3675
		114.7633  114.3386
		114.6655  114.2501
		114.5701  114.1252
		114.5396  114.0099

	[10*log10(sum(10.^(sig_psd_dB(idx_sig,1)/10))*mean(diff(sig_freq_vec)));...
	10*log10(sum(pxx(idx_pxx,1))*mean(diff(f)))]
	ans =
		117.9556
		118.2376
	```

##############################################
## 2017/02/01-08
* Started re-writing the manuscript
* Updating split-window and energy normalizer code to work with new data format:
	* `normalizer_split_window`
	* `normalizer_energy`
* For reasons currently unknown, the energy normalizer has "rings" of elevated levels throughout range, corresponding to the locations of nulls in the non-pulse compressed but beamformed time series. **LOOK INTO THIS WHEN HAVE TIME!**
* The energy normalizer also requires using all data instead of just the subset. This makes processing a lot slower... for now only use the split-window normalizer for the paper.

##############################################
## 2017/02/15
* Functions to plot echogram:
	* `plot_small_echogram`: can be called to plot small scale echogram on a given axes handle
	* `plot_large_echogram`: not a function, can be used to plot full scale echogram
* Try `echo_info` on multiple overnight sessions
	* run 103: ping 155 and 160 seem stronger than other pings by a few dB??
	* run 79: fish spread toward southern side of the shipwreck
* Remember that run 94 pings after 573 have not been beamformed
* Remember to change the part re. ping_num swicth in `get_SL`



