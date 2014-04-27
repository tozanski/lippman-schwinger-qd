#!/usr/bin/octave -qf

#QCG host=zeus
#QCG queue=plgrid-testing
#QCG nodes=1:1

#QCG stage-in-file=calka.m -> calka.m
#QCG stage-out-file=calka.oct -> calka.oct 
#QCG output=${JOB_ID}.output.txt
#QCG error=${JOB_ID}.error.txt

#QCG module=apps/octave
#QCG module=libs/gsl

#QCG notify=mailto:tomasz.ozanski@pwr.wroc.pl

cflags = sprintf('-I%s/include',getenv('GSL'));
libs = sprintf('-L%s/libs -lgsl -lgslcblas -lm',getenv('GSL'));

mkoctfile('calka.cpp','-Wall',libs,cflags);


