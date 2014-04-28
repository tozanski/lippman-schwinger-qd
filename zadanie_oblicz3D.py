#!/usr/bin/python
from numpy import linspace
from numpy import arange
from os import mkdir
from subprocess import call

N = 20;
L = 30;
m = 0;

U = list(arange(0.5,31,1));
jobs = 4;

file_template = """\
#!/bin/bash				 
#QCG name=obliczenia3D-lippmann-schwinger-qd

#QCG host=zeus
#QCG queue=plgrid
##QCG walltime = PT1H
#QCG nodes=1:1


#QCG stage-in-file=calka.oct -> calka.oct
#QCG stage-in-file=oblicz3D.m -> oblicz3D.m

#QCG stage-out-file=result.dat -> %s

#QCG output=../${JOB_ID}.output.txt
#QCG error=../${JOB_ID}.error.txt


#QCG module=apps/octave
#QCG module=libs/gsl

#QCG notify=mailto:tomasz.ozanski@pwr.wroc.pl

octave --eval "%s"
"""

octave_args_template = "N=%d, L=%f, U=%s, m=%f, oblicz_greena"

#mkdir('../jobs/')
jobs_dir = '../jobs/'

for i in xrange(jobs):
	jobU = U[i::len(U)/jobs]
	args = octave_args_template % (N,L,str(jobU),m,)
	result_path = "../lippmann-schwinger-qd_wyniki/slice%05d.dat" % i
	file_content = file_template % (result_path,args)
	desc_filename = jobs_dir + 'job_desc%d.sh' % i
	f = file(desc_filename,'w')
	f.write(file_content)


