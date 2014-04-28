fun0 = @(u) calka(u,0,0,0);
afun0 = @(u) arrayfun( fun0, u );

fun1 = @(u) calka(u,1,1,0);
afun1 = @(u) arrayfun( fun1, u );

u = (0.001:0.001:0.1)';
y0 = afun0(u);
y1 = afun1(u);

plot( u, abs(y0) );
title('absolute value plot')
xlabel('u')
ylabel('G_0(0,0,u)')
saveas(1,'udivergence0.png')


plot( log(u), log(y0) );
alpha0 = regress( log(u), log(abs(y0)));
title(sprintf('log of absolute value plot regression: alpha=%f',1/alpha0));
xlabel('log(u)')
ylabel('log(G_0(0,0,u))')
saveas(1,'udivergence0log.png')


plot( u, abs(y1) );
title('absolute value plot')
xlabel('u')
ylabel('G_0(1,1,u)')
saveas(1,'udivergence1.png')


plot( log(u), log(y1) );
alpha1 = regress( log(u), log(abs(y1)));
title(sprintf('log of absolute value plot regression: alpha=%f',1/alpha1));
xlabel('log(u)')
ylabel('log(G_0(1,1,u))')
saveas(1,'udivergence1log.png')
