all:  WPSV3-compile
	echo All	

download: wrf.tar.gz wps.tar.gz wrfda.tar.gz wrf_chem.tar.gz
	echo Download

untargz: wrf.tar.gz-untargz wps.tar.gz-untargz wrfda.tar.gz-untargz wrf_chem.tar.gz-untargz-untargz

WPSV3-compile: WRFV3-compile wps.tar.gz-untargz wrf-configure.input
	cd WPS && csh ./compile wps

WRFV3-compile: wrf.tar.gz-untargz
	cd WRFV3 && bash ./configure < ../wrf-configure.input && csh ./compile -j 8 wrf

%.tar.gz-untargz: %.tar.gz
	tar -xvvzf $<

wrf.tar.gz:
	wget -O $@ http://www.mmm.ucar.edu/wrf/src/WRFV3.5.1.TAR.gz

wps.tar.gz:
	wget -O $@ http://www.mmm.ucar.edu/wrf/src/WPSV3.5.1.TAR.gz

wrfda.tar.gz:
	wget -O $@ http://www.mmm.ucar.edu/wrf/src/WRFDA_V3.5.1.tar.gz

wrf_chem.tar.gz:
	wget -O $@ http://www.mmm.ucar.edu/wrf/src/WRFV3-Chem-3.5.1.TAR.gz
