# TREX 13 fish echo analysis @APL
# Part II (2017)

## 2017/01/13
Spent this past Mon/Wed/Fri trying to figure out the offset between my beamforming routine and Jie's output. Finally figured out what's going on...

There are 3 sources of offsets that need to be taken into account:

1. Gain associated with match filtering (`gain_pc` in code).
2. Gain associated with beamforming (`gain_beamform` in code). This is se to `20*log10(48)` because there are 48 elements when used in the linear configuration, so total energy is enhanced by 48 times. Note that since cardioid beamforming was _normalized_ to the level of linear beamforming output, this factor is the same under cardioid beamforming.
3. Differences of load when driving the FORA array (`gain_load` in code). The gain is 46.95 dB when the array is driven as triplet, and 42.35 dB when the array is driven as linear array. My confusion before was that I thought the gain would be different when different combinations of elements were used.

