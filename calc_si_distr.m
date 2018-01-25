% 2018 01 23  Calculate SI for different distributions, especially
%             compare high tail ones

r(:,1) = raylrnd(ones(1e6,1)/sqrt(2));
r(:,2) = normrnd(0,1,[1e6,1]);
r(:,3) = poissrnd(1,[1e6,1]);
r(:,4) = poissrnd(2,[1e6,1]);
r(:,5) = poissrnd(3,[1e6,1]);
r(:,6) = poissrnd(4,[1e6,1]);
r(:,7) = poissrnd(10,[1e6,1]);


lambda = mean(r.^2);
scint = mean((r.^2-repmat(lambda,1e6,1)).^2,1)./lambda.^2;

[x,dens,~] = findEchoDist(r(:,1)/sqrt(mean(r(:,1).^2)),100);
[x2,dens2,~] = findEchoDist(r(:,2)/sqrt(mean(r(:,2).^2)),100);
[x3,dens3,~] = findEchoDist(r(:,3)/sqrt(mean(r(:,3).^2)),100);

[x_poiss01,dens_poiss01] = findEchoDist(r(:,3)/sqrt(mean(r(:,3).^2)),100);
[x_poiss03,dens_poiss03,bw_poiss03] = findEchoDist(r(:,4)/sqrt(mean(r(:,4).^2)),100);
[x_poiss10,dens_poiss10,bw_poiss10] = findEchoDist(r(:,5)/sqrt(mean(r(:,5).^2)),100);





