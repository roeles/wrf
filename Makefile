#TODO: modify configure.wrf for WRF, add optimizer options  -O3 -ffast-math -march=native -funroll-loops -fno-protect-parens -flto
#TODO: modify configure.wrf to make stuff compile with the -cpp flag

all:  WPS-compile
	echo All	

WPS-compile: WRFV3-compile wps.tar.gz-untargz wps-configure.input
	(cd WPS && \
	bash ./configure < ../wps-configure.input && \
	csh ./compile wps)

WRFV3-compile: wrf.tar.gz-untargz wrf-configure.input
	(cd WRFV3 && \
	bash ./configure < ../wrf-configure.input && \
	csh ./compile em_real &&
	strip main/wrf.exe main/real.exe)


%.tar.gz-untargz: %.tar.gz
	tar -xvvzf $<

wrf.tar.gz:
	wget -O $@ http://www.mmm.ucar.edu/wrf/src/WRFV3.5.1.TAR.gz

wps.tar.gz:
	wget -O $@ http://www.mmm.ucar.edu/wrf/src/WPSV3.5.1.TAR.gz

geog.tar.gz:
	wget -O $@ http://www.mmm.ucar.edu/wrf/src/wps_files/geog_v3.4.tar.gz
