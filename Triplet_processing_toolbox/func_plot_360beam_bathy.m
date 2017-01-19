function func_plot_360beam_bathy(Rmax_map,Map_X,Map_Y,Map_Z,wrecgps,X,Y,ang_int)

figure(30);
h1 = polar([0 2*pi], [0 Rmax_map/1000]);
%         delete(h1);
set(h1,'Visible','off');

for nang = [0:30:330]
    set(findall(gcf, 'String', [num2str(nang)]),'String', [num2str(rem(90-nang+360,360)) '^o']);
end

ph=findall(gca,'type','text');
ps=get(ph,'string');

ps([4,5,10,11])={
    [ps(4) 'East']
    [ps(5) 'West']
    [ps(10) 'South']
    [ps(11) 'North']
    };
for n = length(ps):-1:16
    ps(n)={([cell2mat(ps(n)) 'km'])};%{[ps(n) 'km']};
end

set(ph,{'string'},ps);
ps=get(ph,'fontweight');
ps([4,5,10,11],1)={'bold'};
for n = length(ps):-1:16
    ps(n,1)={'bold'};
end
set(ph,{'fontweight'},ps);

hold on;
[c,h2]=contour(Map_X/1000,Map_Y/1000,Map_Z,[0:-2:-30],'k');
clabel(c,h2,'fontsize',8,'linewidth',1,'Color','k');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nplot = round(size(X,1)*.9);
pcolor(X(1:Nplot,:)/1000,Y(1:Nplot,:)/1000,ang_int(1:Nplot,:)); shading interp;%axis equal;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hold on;
[c,h2]=contour(Map_X/1000,Map_Y/1000,Map_Z,[0:-2:-30],'k');
clabel(c,h2,'fontsize',8,'linewidth',1,'Color','k');

caxis([80,120]);

h3=colorbar( 'WestOutside');PosColorbar = get(h3,'Position');
set(h3,'Position',PosColorbar+[-0.45*PosColorbar(1) 0 0 0 ]);
hold on;

plot(wrecgps(1,:)/1000, wrecgps(2,:)/1000,'+k','Markersize',5,'linewidth',1);
hold off;

set(gca,'fontsize',14)

figure(30),hold off


