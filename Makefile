EDITOR = /usr/bin/gedit
INDENT = /usr/bin/indent

CC         = clang
#CC         = gcc
MAKEDEPEND = $(CC) -MM -MG
CPROTO     = cproto
GNUPLOT    = gnuplot

CPFLAGS = -q

LDFLAG = -O3
ifeq ($(CC), clang)
  CFLAGS  = -Weverything -Wextra -pedantic $(LDFLAGS)
else
  CFLAGS  = -Wextra -pedantic -std=c99 $(LDFLAGS)
endif

LDLIBS    = $(shell gsl-config --libs)

.PHONY: clean headers

target = ising-demo-metropolis

.SUFFIXES:
.SUFFIXES:  .o .h .d .c .res

%.o : %.c
	$(CC) -c $(CFLAGS) $<

%.h : %.c
	$(CPROTO) $(CPFLAGS) $< -o $@

%.d : %.c
	$(MAKEDEPEND) $< -MF $@

%.res: ising-demo-%
	./$< > $@

all: ising-demo-metropolis

OBJSM = ising-demo-metropolis.o ising.o metropolis.o matrixmem.o progressbar.o
SRCSM = $(OBJSM:.o=.c)
HDRSM = $(OBJSM:.o=.h)
DEPSM = $(OBJSM:.o=.d)

ising-demo-metropolis: $(OBJSM) headers_m
	$(CC) $(LDFLAGS) $(OBJSM) $(LDLIBS) -o $@

headers_m:
	@#$(foreach var,$(SRCSM),touch --reference=$(var) $(var:.c=.h);)
	touch -d "2000-01-01" $(HDRSM)

-include $(DEPSM)

edit : $(target).c
	$(EDITOR) $<
	$(INDENT) $<

res: ising-demo-metropolis
	./ising-demo-metropolis > res

show: ising-triangular.gp
	$(GNUPLOT) ising-triangular.gp
	eog ising-triangular.png

clean:
	rm -f *.*~
	rm -f ising-demo-metropolis $(OBJSM) $(HDRSM) $(DEPSM)
