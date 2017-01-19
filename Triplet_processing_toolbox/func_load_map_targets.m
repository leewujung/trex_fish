function [Map_X,Map_Y,Map_Z,wrecgps] = func_load_map_targets(M2)

[Map_X,Map_Y,Map_Z]=GUI_Read_TREX13_site2_map(M2(1), M2(2));

origin =  M2;

%%%%%%%%%%load in locations of all known clutter objects%%%%%%%%
wrecgps = [];

[a,b]=GUI_latlon(30.053833,-85.62145,origin(1),origin(2)); % Simpson Tug
wrecgps =[wrecgps [a;b]];%  text(a/1000,b/1000,'* ST','fontsize',fntsz,'color','k')

[a,b]=GUI_latlon(30.00756667,-85.6078666,origin(1),origin(2)); % Davis Barge
wrecgps =[wrecgps [a;b]];%  text(a/1000,b/1000,'* DB','fontsize',fntsz,'color','k')

[a,b]=GUI_latlon(29+55.066/60,-85-40.466/60,origin(1),origin(2)); % Sherman X Tug
wrecgps =[wrecgps [a;b]];%  text(a/1000,b/1000,'* SXT','fontsize',fntsz,'color','k')

[a,b]=GUI_latlon(30+00.891/60,-85-41.477/60,origin(1),origin(2)); % Loss Pontoon
wrecgps =[wrecgps [a;b]];% text(a/1000,b/1000,'* LP','fontsize',fntsz,'color','k')

[a,b]=GUI_latlon(30+00.00/60,-85-40.50/60,origin(1),origin(2)); % USS Grierson
wrecgps =[wrecgps [a;b]]; %   text(a/1000,b/1000,'* UG','fontsize',fntsz,'color','k')

[a,b]=GUI_latlon(30+01.863/60,-85-42.666/60,origin(1),origin(2)); % USS Strength
wrecgps =[wrecgps [a;b]];%  text(a/1000,b/1000,'* US','fontsize',fntsz,'color','k')

[a,b]=GUI_latlon(30+02.703/60,-85-43.175/60,origin(1),origin(2)); % Midway site #6
wrecgps =[wrecgps [a;b]];%   text(a/1000,b/1000,'* MS6','fontsize',fntsz,'color','k')

[a,b]=GUI_latlon(30+02.282/60,-85-43.407/60,origin(1),origin(2)); % Midway site
wrecgps =[wrecgps [a;b]];%  text(a/1000,b/1000,'* MS','fontsize',fntsz,'color','k')

[a,b]=GUI_latlon(30+02.212/60,-85-43.671/60,origin(1),origin(2)); % Hathaway Span #2
wrecgps =[wrecgps [a;b]];%  text(a/1000,b/1000,'* HS2','fontsize',fntsz,'color','k')

[a,b]=GUI_latlon(30+02.081/60,-85-43.893/60,origin(1),origin(2)); % Hathaway Span #12
wrecgps =[wrecgps [a;b]];%  text(a/1000,b/1000,'* HS12','fontsize',fntsz,'color','k')

[a,b]=GUI_latlon(30+02.670/60,-85-43.727/60,origin(1),origin(2)); % Hathaway Span #1
wrecgps =[wrecgps [a;b]];  %text(a/1000,b/1000,'* HS1','fontsize',fntsz,'color','k')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%read in the map information and data  end!!!


