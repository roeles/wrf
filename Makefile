#TODO: modify configure.wrf for WRF, add optimizer options  -O3 -ffast-math -march=native -funroll-loops -fno-protect-parens -flto
#TODO: modify configure.wrf to make stuff compile with the -cpp flag

all:  WRFV3/main/wrf.exe
	echo All	

WPS-compile: WRFV3-compile wps.tar.gz-untargz wps-configure.input
	(cd WPS && \
	bash ./configure < ../wps-configure.input && \
	csh ./compile wps)


#Compilation of WRFV3
WRFV3/configure: wrf.tar.gz-untargz

WRFV3/configure.wrf: WRFV3/configure wrf-configure.input
	(cd WRFV3 && \
	bash ./configure < ../wrf-configure.input)

WRFV3-configure-patch: WRFV3/configure.wrf
	(cd WRFV3 && \
	sed -i -e 's/-O2 -ftree-vectorize -funroll-loops/-O3 -ffast-math -march=native -funroll-loops -fno-protect-parens -flto/' configure.wrf && \
	sed -i -e 's/FORMAT_FIXED    =       /FORMAT_FIXED    =       -cpp /' configure.wrf && \
	sed -i -e 's/FORMAT_FREE     =       /FORMAT_FREE     =       -cpp /' configure.wrf && \
	sed -i -e 's/FCNOOPT         =       -O0/-O3 -ffast-math -march=native -funroll-loops -fno-protect-parens -flto -cpp/' configure.wrf)

WRFV3/main/wrf.exe WRFV3/main/real.exe: WRFV3-configure-patch
	(cd WRFV3 && \
	csh ./compile em_real && \
	strip main/wrf.exe main/real.exe)


%.tar.gz-untargz: %.tar.gz
	tar -xvvzf $<

wrf.tar.gz:
	wget -O $@ http://www.mmm.ucar.edu/wrf/src/WRFV3.5.1.TAR.gz

wps.tar.gz:
	wget -O $@ http://www.mmm.ucar.edu/wrf/src/WPSV3.5.1.TAR.gz

geog.tar.gz:
	wget -O $@ http://www.mmm.ucar.edu/wrf/src/wps_files/geog_v3.4.tar.gz
