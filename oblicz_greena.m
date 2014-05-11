
%L = [10.0]; 
%N = 101;
%u = 0.01;
%n = 0;

%assure following variables are defined
L;
U;
N;
m;

result = zeros( size(y,1),size(y,2),length(U) );

for i = 1:length(U)

	u = U(i);

	fun = @(r1,r2) calka( u, r1, r2, m);
	ferr =@(s, x)  NaN;

	rs = linspace(0,L,N);

	r1 = repmat( rs', 1, N );
	r2 = repmat( rs, N, 1 );

	[y] = arrayfun(fun, r1, r2,"ErrorHandler",@ferr);

	result(:,:,i) = y;
end

save -binary result.dat result U
