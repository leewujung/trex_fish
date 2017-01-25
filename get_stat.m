function stat = get_stat(env,npt)

env = env(:);

[x,px] = findEchoDist(env,npt);
[x_n,px_n] = findEchoDist(env/sqrt(mean(env.^2)),npt);
[x_kde,px_kde] = findEchoDist_kde(env,npt);
[x_n_kde,px_n_kde] = findEchoDist_kde(env/sqrt(mean(env.^2)),npt);

lambda = mean(env.^2);
scint = mean((env.^2-lambda).^2)/lambda^2;

stat.x = x;
stat.px = px;
stat.x_n = x_n;
stat.px_n = px_n;
stat.x_kde = x_kde;
stat.px_kde = px_kde;
stat.x_n_kde = x_n_kde;
stat.px_n_kde = px_n_kde;
stat.lambda = lambda;
stat.scint = scint;
