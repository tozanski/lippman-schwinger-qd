#!/bin/bash

#QCG name=kompilacja-lippmann-schwinger-qd

#QCG host=zeus
#QCG queue=plgrid-testing
#QCG nodes=1:1

#QCG stage-in-file=kompiluj_plgrid.m -> kompiluj_plgrid.m
#QCG stage-in-file=calka.cpp -> calka.cpp


#QCG stage-out-file=calka.oct -> calka.oct
#QCG output=../${JOB_ID}.output.txt
#QCG error=../${JOB_ID}.error.txt


#QCG module=apps/octave
#QCG module=libs/gsl

#QCG notify=mailto:tomasz.ozanski@pwr.wroc.pl
##QCG walltime=PT5M


octave kompiluj_plgrid.m
