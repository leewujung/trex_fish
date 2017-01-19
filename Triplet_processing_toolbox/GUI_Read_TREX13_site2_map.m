function   [Map_X,Map_Y,Map_Z]=GUI_Read_TREX13_site2_map(latitude_center,longitude_center)
% Function  [Map_X,Map_Y,Map_Z]=Read_TREX13_site2_map(latitude_center,longitude_center)
% Input:  latitude_center,longitude_center : latitude and longitude for the array, degrees.
% Output: Map_X,Map_Y,Map_Z , :Cartesian coordinates and Depth of the sea, meters. 

%Most following code was written by Todd to read the Site map for the experiment. 

load GUI_PC_bath_data ; % Moray 1
clear PC_bath_data_for_aspm;

%% Grab a subset of the data for aspm
temp2=reshape(GUI_PC_bath_data,196,111,3);
temp3=temp2(35:1:105,10:1:70,:); % Just grabbing the area

%%interested in -change at will
a=size(temp3);
M1=reshape(temp3,a(1)*a(2),1,3);

%Set the central GPS data
% M2=[30.063; -85.695];
% M2=[latitude_center,longitude_center];

%% choose coordiate origin
% origin = M2;
origin = [latitude_center,longitude_center];

%  x, y positions of bathy points relative to s/r  - approximate assuming sphere.
for i_bath=1:length(M1);
    
    [x(i_bath),y(i_bath)] = GUI_latlon(M1(i_bath,1),M1(i_bath,2),origin(1),origin(2));
    bath(i_bath)=M1(i_bath,3);
    
end

x_bath=reshape(x,a(1),a(2));
y_bath=reshape(y,a(1),a(2));
bathy=reshape(bath,a(1),a(2));

% % % % % 
% % % % % %% BIG VIEW OF AREA
% % % % % figure(1)
% % % % % clf
% % % % % % pcolor(x_bath/1000,y_bath/1000,bathy)
% % % % % % shading('interp')
% % % % % % caxis([-30 0])
% % % % % % hold on
% % % % % [c,h]=contour(x_bath/1000,y_bath/1000,bathy,[-2:-2:-30],'k');
% % % % % clabel(c,h,'fontsize',10,'linewidth',2);
% % % % % hold on;
% % % % % 
% % % % % axis('equal')
% % % % % xlabel('distance (km).','FontSize',16,'Fontweight','bold')
% % % % % ylabel('distance (km).','FontSize',16,'Fontweight','bold')
% % % % % cmap = colormap;
% % % % % cmap(end,:) = [0.5 0.5 0.5];
% % % % % cmap(end-1,:) = [0.5 0.5 0.5];
% % % % % colormap(cmap)
% % % % % 
% % % % % 
% % % % % title(strcat('water depth (m) centered at (  ',num2str(M2(1)),'N,  ',num2str(M2(2)),' W) .',' '),'FontSize',16,'Fontweight','bold')
% % % % % set(gca,'FontSize',16,'Fontweight','bold')
% % % % % 
% % % % % [th,r,z] = cart2pol(x_bath/1000,y_bath/1000,bathy);
% % % % % 
% % % % % figure;
% % % % % 
% % % % % h = polar([0 2*pi], [0 max(max(r))]);
% % % % % delete(h)
% % % % % hold on
% % % % % [c,h]=contour(x_bath/1000,y_bath/1000,bathy,[-2:-2:-30],'k');
% % % % % clabel(c,h,'fontsize',10,'linewidth',2);
% % % % % 
% % % % % axis('equal')
% % % % %  
 
Map_X = x_bath;
Map_Y = y_bath;
Map_Z = bathy;


return;

% % 
% % 
% % 
% % %% Bearing lines
% % 
% % mlx = 0;
% % mly = 0;
% % % 
% % % rot_angle = -35;
% % % 
% % % bearing1 = 5*[cos((-1 + rot_angle)*pi/180) sin((-1 + rot_angle)*pi/180)];
% % % bearing2 = 5*[cos((1 + rot_angle)*pi/180) sin((1 + rot_angle)*pi/180)];
% % % bearing3 = 5*[cos((-2.5 + rot_angle)*pi/180) sin((-2.5 + rot_angle)*pi/180)];
% % % bearing4 = 5*[cos((2.5 + rot_angle)*pi/180) sin((2.5 + rot_angle)*pi/180)];
% % % 
% % % plot([mlx bearing1(1)], [mly bearing1(2)],'-r','linewidth',2)
% % % plot([mlx bearing2(1)], [mly bearing2(2)],'-r','linewidth',2)
% % % plot([mlx bearing3(1)], [mly bearing3(2)],'-r','linewidth',2)
% % % plot([mlx bearing4(1)], [mly bearing4(2)],'-r','linewidth',2)
% % % 
% % plot(mlx,mly,'.k','markersize',23)          
% % 
% % 
% % %  m1x=0;
% % %  m1y=0;
% % %  for j_bearing=1:1
% % %      bearing1=[5 -tan((j_bearing)*9*pi/180)*100];
% % %      bearing2=[5 -tan((j_bearing)*11*pi/180)*100];
% % %      plot([m1x bearing1(1,1) ],[m1y bearing1(1,2)],'--k');
% % %      plot([m1x bearing2(1,1) ],[m1y bearing2(1,2)],'--k');
% % %  %    plot([-m1x -bearing1(1,1) ],[m1y bearing1(1,2)],'--k');
% % %  %    plot([-m1x -bearing1(1,1) ],[-m1y -bearing1(1,2)],'--k');
% % %  end
% % 
% % % Range lines
% % 
% % % for i_range=1:1:5
% % %     for j_bearing = 1:6
% % %         bearing1(j_bearing,1)=i_range*cos(((j_bearing) + rot_angle - 3.5)*pi/180);
% % %         bearing1(j_bearing,2)=i_range*sin(((j_bearing) + rot_angle - 3.5)*pi/180);
% % %     end
% % %     plot(bearing1(:,1), bearing1(:,2),'-r','linewidth',2);
% % %     hold on
% % % end
% % axis([-7 7 -7 7])
% % % %set(1,'Position',[3142         761         560         420])
% % % 
% % % 
% % % for i_range=1:1:5
% % %     for j_bearing = 1:(6+120)
% % %         bearing1(j_bearing,1)=i_range*cos(((j_bearing) + rot_angle - 3.5 - 120)*pi/180);
% % %         bearing1(j_bearing,2)=i_range*sin(((j_bearing) + rot_angle - 3.5 - 120)*pi/180);
% % %     end
% % %     plot(bearing1(:,1), bearing1(:,2),'--r','linewidth',2);
% % %     hold on
% % % end      
% % 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % % Ship Wrecks for Panama City - Add more from map as desired
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 
% % fntsz = 15;
% % 
% %   [a,b]=latlon(30.053833,-85.62145,origin(1),origin(2)); % Simpson Tug
% %   plot(a/1000,b/1000,'ok','Markersize',10,'linewidth',3)
% % %  text(a/1000,b/1000,'* ST','fontsize',fntsz,'color','k')
% % %  
% %   [a,b]=latlon(30.00756667,-85.6078666,origin(1),origin(2)); % Davis Barge
% %   plot(a/1000,b/1000,'ok','Markersize',10,'linewidth',3)
% % %  text(a/1000,b/1000,'* DB','fontsize',fntsz,'color','k')
% % %   
% %   [a,b]=latlon(29+55.066/60,-85-40.466/60,origin(1),origin(2)); % Sherman X Tug
% %   plot(a/1000,b/1000,'ok','Markersize',10,'linewidth',3)
% % %  text(a/1000,b/1000,'* SXT','fontsize',fntsz,'color','k')
% % 
% %  [a,b]=latlon(30+00.891/60,-85-41.477/60,origin(1),origin(2)); % Loss Pontoon
% %  plot(a/1000,b/1000,'ok','Markersize',10,'linewidth',3)
% % % text(a/1000,b/1000,'* LP','fontsize',fntsz,'color','k')
% %  
% %    [a,b]=latlon(30+00.00/60,-85-40.50/60,origin(1),origin(2)); % USS Grierson
% %    plot(a/1000,b/1000,'ok','Markersize',10,'linewidth',3)
% % %   text(a/1000,b/1000,'* UG','fontsize',fntsz,'color','k')
% % 
% %   [a,b]=latlon(30+01.863/60,-85-42.666/60,origin(1),origin(2)); % USS Strength
% %   plot(a/1000,b/1000,'*k','Markersize',10,'linewidth',3)
% % %  text(a/1000,b/1000,'* US','fontsize',fntsz,'color','k')
% %   
% %    [a,b]=latlon(30+02.703/60,-85-43.175/60,origin(1),origin(2)); % Midway site #6
% %   plot(a/1000,b/1000,'+k','Markersize',10,'linewidth',3)
% % %   text(a/1000,b/1000,'* MS6','fontsize',fntsz,'color','k')
% %   
% %   [a,b]=latlon(30+02.282/60,-85-43.407/60,origin(1),origin(2)); % Midway site 
% %   plot(a/1000,b/1000,'vk','Markersize',10,'linewidth',3)
% % %  text(a/1000,b/1000,'* MS','fontsize',fntsz,'color','k')
% %   
% %   [a,b]=latlon(30+02.212/60,-85-43.671/60,origin(1),origin(2)); % Hathaway Span #2 
% %   plot(a/1000,b/1000,'xk','Markersize',10,'linewidth',3)
% % %  text(a/1000,b/1000,'* HS2','fontsize',fntsz,'color','k')
% % 
% %   [a,b]=latlon(30+02.081/60,-85-43.893/60,origin(1),origin(2)); % Hathaway Span #12 
% %   plot(a/1000,b/1000,'*k','Markersize',10,'linewidth',3)
% % %  text(a/1000,b/1000,'* HS12','fontsize',fntsz,'color','k')
% %   
% %   [a,b]=latlon(30+02.670/60,-85-43.727/60,origin(1),origin(2)); % Hathaway Span #1 
% %   plot(a/1000,b/1000,'+k','Markersize',10,'linewidth',3)
% %   %text(a/1000,b/1000,'* HS1','fontsize',fntsz,'color','k')
