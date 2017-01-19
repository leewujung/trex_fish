function [Gaus_window,Npts,N_win,step_size,t_win] = func_gen_Gaussian_window( tau, t, sample_freq)

sigma = tau/sqrt(pi);

Gaus_window_complete = exp( -(t-max(t)/2).^2/(2*sigma^2) );
win_ind = find( t < 5*sigma );
[xx,yy] = max(Gaus_window_complete);

Gaus_window = Gaus_window_complete( yy-win_ind(end) : yy+win_ind(end) );

Npts = length(Gaus_window);

step_size = floor(tau*sample_freq);
max_beamform_time = length(t)/sample_freq;
N_win = floor( (max_beamform_time*sample_freq-Npts)/step_size );

t_win_ind=  (Npts+1)/2 + ([1:N_win]-1)*step_size;  % middle of the time window
t_win    =  t_win_ind/sample_freq;

