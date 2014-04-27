
L = [0.0,10.0]; 
N = 101;
u = 0.01;
n = 0;

fun = @(r1,r2) calka( u, r1, r2, n);

function y = ferr (s, x), y = NaN; endfunction


rs = linspace(L(1),L(2),N);

r1 = repmat( rs', 1, N );
r2 = repmat( rs, N, 1 );

[y] = arrayfun(fun, r1, r2,"ErrorHandler",@ferr);

imagesc( rs, rs, abs(y) );

minimax = [min(min(abs(y))),max(max(abs(y)))];

title( sprintf("funkcja greena (abs) u=%f, n=%d\nmin=%f,max=%f",u,n,minimax(1),minimax(2)));
xlabel("x1");
ylabel("x2");

saveas(1,"green_abs.png");


imagesc( rs, rs, real(y) );

minimax = [min(min(real(y))),max(max(real(y)))];
title( sprintf("funkcja greena (Re) u=%f, n=%d\nmin=%f,max=%f",u,n,minimax(1),minimax(2)));
xlabel("x1");
ylabel("x2");

saveas(1,"green_real.png");


imagesc( rs, rs, imag(y) );

minimax = [min(min(imag(y))),max(max(imag(y)))];
title( sprintf("funkcja greena (Im) u=%f, n=%d\nmin=%f,max=%f",u,n,minimax(1),minimax(2)));
xlabel("x1");
ylabel("x2");

saveas(1,"green_imag.png");
