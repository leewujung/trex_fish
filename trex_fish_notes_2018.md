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
- revised `summarize_run_fcn.m` and `summarize_run_fcn_runner.m`
	- results saved in `summarize_run` (2017 results in `unequalAW12_summarize_run`)
	- figures used in Fig. 3-4 of ms v7.0
- revised `compare_run.m`
	- results saves in `compare_run` (2017 results in `unequalAW12_compare_run`)
	- figures used in Fig. 5 of ms v7.0
- revised `fig_stat_echogram`
	- results saved in `fig_stat_echogram_run` (2017 results in `unequalAW12_fig_stat_echogram_run*`)
	- figures used in Fig. 3 of ms v7.0
- note: `fig_selected_pings_echogram` is for plotting echograms only with windows, and was used to plot the panels in Fig. 2C of ms v5.0 (these panels are moved to form an independent Fig. 2 in ms v7.0)
