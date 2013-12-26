all:  WRFV3-compile
	echo All	

download: wrf.tar.gz wps.tar.gz wrfda.tar.gz wrf_chem.tar.gz
	echo Download

WRFV3-compile: wrf.tar.gz-untargz
	cd WRFV3 && csh ./compile -j8 wrf

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
