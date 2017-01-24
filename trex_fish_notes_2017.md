# TREX 13 fish echo analysis @APL
# Part II (2017)

## 2017/01/13
Spent this past Mon/Wed/Fri trying to figure out the offset between my beamforming routine and Jie's output. Finally figured out what's going on...

There are 4 compensations that need to be taken into account:

1. Gain associated with match filtering (`gain_pc` in code).
2. Gain associated with beamforming (`gain_beamform` in code). This is se to `20*log10(48)` because there are 48 elements when used in the linear configuration, so total energy is enhanced by 48 times. Note that since cardioid beamforming was _normalized_ to the level of linear beamforming output, this factor is the same under cardioid beamforming.
3. Differences of load when driving the FORA array (`gain_load` in code). The gain is 46.95 dB when the array is driven as triplet, and 42.35 dB when the array is driven as linear array. My confusion before was that I thought the gain would be different when different combinations of elements were used.
4. FORA system gain (`gain_sys` in code). This gain is 12 dB for all runs starting from run 41, and 18 dB before that.


## 2017/01/23
### Calibrate for source level
Going back to original code `get_SL`. The transmitted voltage is recorded at the output of the power amplifier (L10) before feeding into the transducer (see figure below). Data are called **HAARI**. HAARI files are sorted according to dates and transmit start time. In the data, ch0 is voltage and ch1 is current.

Transducer used is ITC-2015. Use `get_TVR_ITC2015` to get the TVR curve.

Unit for TVR is dB//uPa/V @1m. Unit of voltage recorded on HAARI (Vh) is dB//V. So source level (SL) is TVR*Vh. Note there is a scaling factor `A.ch_0_voltage_scale_factor=100` that needs to be applied to get the current transmit signal voltage.

![](../Documents/Jie_cal_notes.png){ width=50%}
