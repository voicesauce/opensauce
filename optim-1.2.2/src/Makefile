MKOCTFILE ?= mkoctfile

ifndef LAPACK_LIBS
LAPACK_LIBS := $(shell $(MKOCTFILE) -p LAPACK_LIBS)
endif
OCTAVE_LAPACK_LIBS := $(shell $(MKOCTFILE) -p LAPACK_LIBS)
# reported necessary for Apple's VecLib framework by Carlo de Falco
# <carlo.defalco@gmail.com>
ifndef BLAS_LIBS
BLAS_LIBS := $(shell $(MKOCTFILE) -p BLAS_LIBS)
endif
OCTAVE_BLAS_LIBS := $(shell $(MKOCTFILE) -p BLAS_LIBS)

# Passing LFLAGS, supplemented with LAPACK_LIBS and BLAS_LIBS, in the
# environment to mkoctfile is prefered over passing LAPACK_LIBS and
# BLAS_LIBS in mkoctfiles commandline due to mkoctfiles difficulties
# with non-standard flags on some systems (e.g. -framework ... on
# Apple)
LFLAGS := $(shell $(MKOCTFILE) -p LFLAGS)
OCTAVE_LFLAGS := $(LFLAGS)
LFLAGS += $(LAPACK_LIBS)
LFLAGS += $(BLAS_LIBS)
OCTAVE_LFLAGS += $(OCTAVE_LAPACK_LIBS)
OCTAVE_LFLAGS += $(OCTAVE_BLAS_LIBS)

all: __bfgsmin.oct numgradient.oct numhessian.oct samin.oct __disna_optim__.oct

# __disna_optim__ should be linked to the same Lapack library as used by Octave
__disna_optim__.oct: __disna_optim__.cc
	LFLAGS="$(OCTAVE_LFLAGS)" $(MKOCTFILE) -s __disna_optim__.cc

%.oct: %.cc
	LFLAGS="$(LFLAGS)" $(MKOCTFILE) -s $<

clean:
	$(RM) *.o core octave-core *.oct *~
