#!/bin/bash
 
#QCG host=zeus
#QCG queue=plgrid-testing
#QCG walltime=PT5M
 
#QCG output=${JOB_ID}.output
#QCG error=${JOB_ID}.error
 
#QCG stage-in-file=skrypt.m -> skrypt.m
 
#QCG module=apps/octave

##QCG notify=mailto:tomasz.ozanski@pwr.edu.pl

octave skrypt.m

###QCG stage-out-file=upper.txt -> ${JOB_ID}.upper
