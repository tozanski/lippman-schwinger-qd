function [val,err] = nowa_calka(n,x1,x2,u)

	if nargin ~= 4
		error('expected arguments n,x1,x2,u');
	end
	if ~ (isscalar(n) & isscalar(x1) & isscalar(x2) & isscalar(u) )
		error('n,x1,x2,u must be scalars');
	end

	t1 = @(z) sqrt( z .* z + 1 );
	f1 = @(z) -bessel_Jn( n, x1 .* t1(z) ) .* bessel_Jn( n, x2 .* t1(z) ) .* exp( -u .* z );

	t2 = @(z) sqrt( 1 - z.*z );
	f2re = @(z) bessel_Jn( n, x1 .* t2(z) ) .* bessel_Jn( n, x2 .* t2(z) ) .* sin( u .* z );
	f2im = @(z)-bessel_Jn( n, x1 .* t2(z) ) .* bessel_Jn( n, x2 .* t2(z) ) .* cos( u .* z );

	[val1,	err1] 	= quadcc( f1, 	0, inf, 1e-6 );
	[val2re,err2re] = quadcc( f2re, 0, 1  , 1e-6 );
	[val2im,err2im] = quadcc( f2im, 0, 1  , 1e-6 );

	val = val1 + val2re + I*val2im;
	err = err1 + err2re + I*val2im;

end




