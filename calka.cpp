#include <octave/oct.h>
#include <gsl/gsl_integration.h>
#include <gsl/gsl_sf_bessel.h>
#include <limits>
#include <complex>
#include <gsl/gsl_errno.h>
#include <assert.h>
#include <stddef.h>

static const int workspace_size = 1024*1024;
static const double epsrel = 1e-7;
static const double epsabs = 0;

typedef std::complex<double> complex;

struct Params{
	double u;
	double x1;
	double x2;
	int n;
	bool real;
};

struct cqws_wrap{
	cqws_wrap( size_t workspace_size )
		: workspace_size( workspace_size )
		, cquad_workspace( NULL )
	{}
	~cqws_wrap(){
		if( cquad_workspace != NULL )
			gsl_integration_cquad_workspace_free( cquad_workspace );
	}

	gsl_integration_cquad_workspace *get()
	{
		if(cquad_workspace == NULL)
			cquad_workspace = gsl_integration_cquad_workspace_alloc( workspace_size );
		return cquad_workspace;
	}
	size_t get_size() const{
		return workspace_size;
	}

	protected:
		size_t workspace_size;
		gsl_integration_cquad_workspace * cquad_workspace;
	private:
		cqws_wrap( cqws_wrap const &){}
		cqws_wrap & operator=( cqws_wrap const &){return *this;}
};


void error_handler( const char *reason, const char *file, int line, int gsl_errno){
	warning( reason );	
}


void chk_err( int err, const char * msg ){
	if( err == 0 )
		return;

	warning( msg );
}


inline
double integrand_vanishing( double zeta, double u, double x1, double x2, int n, bool real=true){
	if( !real )
		return 0;

	if( zeta == 1 )
		return std::numeric_limits<double>::infinity();

	assert( zeta > 1 );
	double s = sqrt( zeta*zeta - 1 );
	
	double fraction = -zeta / s;
	double exponent = exp( -s * u );
	double bessel = gsl_sf_bessel_Jn( n, zeta*x1 ) * gsl_sf_bessel_Jn( n, zeta*x2 );
	double result = fraction * exponent * bessel;
	return result;
}
inline
double integrand_oscillatory( double zeta, double u, double x1, double x2, int n, bool real=true,bool upper_sign=true){

	if( zeta == 1  )
		return std::numeric_limits<double>::quiet_NaN();

	assert( zeta < 1);
	assert( zeta >= 0 );

	double s = sqrt(1-zeta*zeta);

	double fraction = zeta / s;
	double exponent_times_i = std::numeric_limits<double>::quiet_NaN();

	if( real )
	{
		if( upper_sign)
			exponent_times_i = -sin( s * u );
		else
			exponent_times_i = +sin( s * u );
	}
	else
		exponent_times_i = cos( s * u );

	double bessel = gsl_sf_bessel_Jn( n, zeta * x1 ) * gsl_sf_bessel_Jn( n, zeta * x2 );
	double result = fraction * exponent_times_i * bessel;
	return result;
}


double fvan(double zeta, void *args) 
{
	Params *params = reinterpret_cast<Params*>(args);
	return integrand_vanishing(zeta,  params->u, params->x1, params->x2, params->n, params->real );
}

double fosc(double zeta, void *args) 
{
	Params *params = reinterpret_cast<Params*>(args);
	return integrand_oscillatory(zeta, params->u, params->x1, params->x2, params->n, params->real);
}


DEFUN_DLD (calka, args, nargout,  "Hello World Help String")
{

	int err = 0;

	if( args.length() < 4 )
	{
		error("oczekiwane 4 argumenty u, x1, x2, n");
		return octave_value();
	}

	Params params;
	params.u = args(0).double_value();
	params.x1 = args(1).double_value();
	params.x2 = args(2).double_value();
	params.n = args(3).int_value();

	if( args.length() > 4 )
	{
		octave_value_list retval;
		double zeta = args(4).double_value();
		
		double (*fptr)(double, void*);
		
		if( zeta >= 1 )
			fptr = fvan;
		else
			fptr = fosc;

		double rreal,rimag;
		params.real = true;
		rreal = fptr( zeta, reinterpret_cast<void*>( &params ) );
		params.real = false;
		rimag = fptr( zeta, reinterpret_cast<void*>( &params ) );
		retval.append( complex( rreal, rimag ) );

		return retval;

	}

	gsl_set_error_handler( error_handler );
	gsl_integration_workspace * workspace = gsl_integration_workspace_alloc( workspace_size );
	cqws_wrap cquad_workspace(workspace_size);

	gsl_function gsl_integrand_van, gsl_integrand_osc;

	gsl_integrand_van.function = &fvan;
	gsl_integrand_osc.function = &fosc;
	
	gsl_integrand_van.params = &params;
	gsl_integrand_osc.params = &params;

	size_t nevals;
	double resultLR=0, errorLR=0;
	
	err = gsl_integration_qags( &gsl_integrand_osc, 0, 1,  epsabs, epsrel, workspace_size, workspace, &resultLR, &errorLR );
	if( err!=0 )
		err = gsl_integration_cquad( &gsl_integrand_osc, 0, 1, epsabs, epsrel, cquad_workspace.get(), &resultLR, &errorLR, &nevals );
	chk_err( err, "real integral of osc integrand from 0 to 1 failed");


	double resultLI=0, errorLI=0;
	params.real = false;
	err = gsl_integration_qags( &gsl_integrand_osc, 0, 1, epsabs, epsrel, workspace_size, workspace, &resultLI, &errorLI); 
	if( err != 0 )
		err = gsl_integration_cquad( &gsl_integrand_osc, 0, 1, epsabs, epsrel, cquad_workspace.get(), &resultLI, &errorLI, &nevals );
	chk_err( err, "imag integral of osc integrand from 0 to 1 failed");
	params.real= true;
	

	double resultU = 0.0;
	double errorU = 0.0;
	err = gsl_integration_qagiu( &gsl_integrand_van, 1, epsabs, epsrel, workspace_size, workspace, &resultU, &errorU );
	if( err != 0 )
	{
		double resultU1=0, errorU1=0;
		err = gsl_integration_cquad( &gsl_integrand_van, 1, 2, epsabs, epsrel, cquad_workspace.get(), &resultU1, &errorU1, &nevals );
		chk_err( err, "integral of van integrand from 1 to 2 failed");


		double resultU2=0, errorU2=0;
		err = gsl_integration_qagiu ( &gsl_integrand_van, 2, epsabs, epsrel, workspace_size, workspace, &resultU2, &errorU2 ); 
    	chk_err( err, "integral of van integrand from 2 to infty failed");


		resultU = resultU1 + resultU2;
		errorU = errorU1 + errorU2;
	}

	gsl_integration_workspace_free (workspace);

	octave_value_list retval;

	//complex resultL = complex( resultLR, resultLI );
	complex result = complex( resultLR + resultU, resultLI );
	
	//complex errorL = complex( errorLR, errorLI );
	complex error = complex( errorLR + errorU, errorLI );
	

	retval.append( result );
	//retval.append( resultL );
	//retval.append( resultU );

	retval.append( error );
	
    return retval;
}
