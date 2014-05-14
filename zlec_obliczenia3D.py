#!/usr/bin/python
from numpy import linspace
from numpy import arange
from os import mkdir
from subprocess import call

N = 151;
L = 15;
m = 0;

U = list(arange(0.1,6,0.1));
jobs = 60;

file_template = """\
#!/bin/bash				 
#QCG name=obliczenia3D-lippmann-schwinger-qd

#QCG host=zeus
#QCG queue=plgrid
###QCG walltime = PT6H
#QCG nodes=1:1


<<<<<<< HEAD
#QCG stage-in-file=calka.oct -> calka.oct
=======
#QCG stage-in-file=nowa_calka.m -> nowa_calka.m
>>>>>>> 13904509af74c88eae0ba07dc739c188cc9db63f
#QCG stage-in-file=oblicz_greena.m -> oblicz_greena.m

#QCG stage-out-file=result.dat -> %s

#QCG output=../${JOB_ID}.output.txt
#QCG error=../${JOB_ID}.error.txt


#QCG module=apps/octave
#QCG module=libs/gsl

#QCG notify=xmpp:tomaszoz@gmail.com

octave --eval "%s" 2>/dev/null
"""

octave_args_template = "N=%d, L=%f, U=%s, m=%f, oblicz_greena"

#mkdir('../jobs/')
jobs_dir = '../jobs/'

for i in xrange(jobs):
	jobU = U[i::len(U)/jobs]
	args = octave_args_template % (N,L,str(jobU),m,)
	result_path = "../slice%05d.dat" % i
	file_content = file_template % (result_path,args)
	desc_filename = jobs_dir + 'job_desc%d.sh' % i
	f = file(desc_filename,'w')
	f.write(file_content)
	f.close()
	call(['qcg-sub',desc_filename])


