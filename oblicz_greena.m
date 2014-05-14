
%L = [10.0]; 
%N = 101;
%u = 0.01;
%n = 0;

%assure following variables are defined
L;
U;
N;
m;

<<<<<<< HEAD
result = zeros( N,N,length(U) );
=======
result = zeros( size(y,1),size(y,2),length(U) );
>>>>>>> 13904509af74c88eae0ba07dc739c188cc9db63f

for i = 1:length(U)

	u = U(i);

	fun = @(r1,r2) nowa_calka( n, r1, r2, u);
	ferr =@(s, x)  NaN;

	rs = linspace(0,L,N);

	r1 = repmat( rs', 1, N );
	r2 = repmat( rs, N, 1 );

	[y] = arrayfun(fun, r1, r2,"ErrorHandler",ferr);

	result(:,:,i) = y;
end

save -binary result.dat result U
