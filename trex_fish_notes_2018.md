# TREX 13 fish echo analysis @APL
# Notes 2018

************************************************
## 2018/01/13
### Set up emacs+git environment
- Use [Magit](https://magit.vc/) to integrate emacs workflow with git. The latest Magit code from the repo couldn't compile `magit-status.el`, so downloaded 2 releases back (now using v.2.10.3). When compiling v.2.11 and v.2.10.3, ran into problem with compiling `magit-version.el`, but it turned out to be not having installed `makeinfo`. Everything went fine after `sudo apt-get install texinfo` which contains `makeinfo` the code compiles without problem
- Quick hotkeys for Magit:
	- `C-x g` to bring Magit main menu, `s` to stage, `u` to unstage
	- `c` to bring up commit menu, `c` again to confirm commit and will bring up text file for commit message, `C-c C-c` when in the message editor to actually commit.
	- `P` to bring up push menu, and `u` to push to upstream
	- `y` to bring up branch menu

### Picked up from Sept 2017 re. TREX fish ms
- Change AW2 so that the sizes of AW1=AW2. As a result have to run all summary figures again and remake figures.
	- revised `echo_info.m`, `echo_info_fcn.m`, added `echo_info_runner.m`
	- rename all results from 2017 (with unequal sizes of AW1 and AW2) to be of the format `unequalAW12_*`
- New AW2 range and angle extend:
	```
	no_rr = [3.71999,3.92];  % modified 2018/01/13 (make sizes of AW2=AW1)
	no_aa = [-2.45,-2.26];
	```
	before it was
	```
	no_rr = [3.60,3.92];
	no_aa = [-2.45,-2.27];
	```

************************************************
## 2018/01/14
### Continue on updating all AW2 results
- Revised `summarize_run_fcn.m` and `summarize_run_fcn_runner.m`
	- results saved in `summarize_run` (2017 results in `unequalAW12_summarize_run`)
	- figures used in Fig. 3-4 of ms v7.0
- Revised `compare_run.m`
	- results saves in `compare_run` (2017 results in `unequalAW12_compare_run`)
	- figures used in Fig. 5 of ms v7.0
- Revised `fig_stat_echogram`
	- results saved in `fig_stat_echogram_run` (2017 results in `unequalAW12_fig_stat_echogram_run*`)
	- figures used in Fig. 3 of ms v7.0
- Note: `fig_selected_pings_echogram` is for plotting echograms only with windows, and was used to plot the panels in Fig. 2C of ms v5.0 (these panels are moved to form an independent Fig. 2 in ms v7.0)


************************************************
## 2018/01/19-21
### Quantitative estimation of fish speed
- Felt the best way to present fish speed is to present how the fish echoes spread along a particular direction from the center of the wreck (i.e., a radial line extending from the wreck center).
- This should probably be done over multiple directions (multiple radial lines) to show the variability, which may also make the estimation more convincing.
- Use the following 4 code for fish speed estimation
	- `fish_speed.m`:
		- Call`get_xyloc_along_line.m` find the set of x-y locations (`xy_loc`) that are nearest to the wanted locations (`dl.xy_vec`) and calculate the projected range from wreck (`r_proj`) along the specified direction (`dl.a`)
		- Call `get_echo_level_along_line.m` to use 1D interpolation to interpolate for fish echo level at the wanted range/locations (`echo_level`).
	- Note that to get `dl.xy_vec` there is a parameter to tune how fine the wanted locations are spaced (`dl.r_diff_div`). This parameter is explored by using `dl.r_diff_div = 1, 2, 4`.
	- `fish_speed_line_check.m`: compare the wanted and nearest x-y locations and projected range along a certain direction when suing different `dl.r_diff_div` values.
