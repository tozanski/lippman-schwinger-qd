cflags = sprintf('-I%s/include',getenv('GSL'));
libs = sprintf('-L%s/libs -lgsl -lgslcblas -lm',getenv('GSL'));

mkoctfile('calka.cpp','-Wall',libs,cflags);


