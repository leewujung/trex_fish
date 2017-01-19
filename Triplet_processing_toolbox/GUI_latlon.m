function [x,y]=GUI_latlon(lat,lon,lat0,lon0)
%   latlon.m    Given (lat,lon), the point's [x,y] in meters,
%   are calculated relative to the reference point (lat0,lon0).
%   The latitude and longitude should be given in 
%   degrees and decimal minutes.
%   For example, lat = [lat_degrees] = [30.43]; 
%                lon = [lon_degrees] = [86.67];
%   Programer DJ Tang, 09/19/2004

R = 6366700;    % Earth radius in meters
x = pi*R*((lon)-(lon0))/180*cos((lat0)*pi/180);
y = pi*R*((lat)-(lat0))/180;
