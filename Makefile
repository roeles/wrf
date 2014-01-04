#TODO: modify configure.wrf for WRF, add optimizer options  -O3 -ffast-math -march=native -funroll-loops -fno-protect-parens -flto
#TODO: modify configure.wrf to make stuff compile with the -cpp flag

all:  WPS/ungrib.exe
	echo All	


GFS/%:
	mkdir -p `dirname $@` && \
	wget -O $@ http://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.`echo $@ | sed -e 's/GFS\///' `

WPS/configure: wps.tar.gz
	tar -xzf $< && \
	touch $@

WPS/configure.wps: WPS/configure wps-configure.input WRFV3/main/wrf.exe
	(cd WPS && \
	bash ./configure < ../wps-configure.input && \
	sed -i -e 's/-O -fconvert=big-endian -frecord-marker=4/-O -fconvert=big-endian -frecord-marker=4 -cpp/' configure.wps) && \
	touch $@

WPS/geogrid.exe WPS/ungrib.exe WPS/metgrid.exe: WPS/configure.wps WRFV3/main/wrf.exe
	(cd WPS && \
	csh ./compile && \
	strip geogrid.exe ungrib.exe metgrid.exe)

WPS/namelist.wps: namelist.wps
	cp $< $@
	touch $@

#Compilation of WRFV3
WRFV3/configure: wrf.tar.gz
	tar -xzf $<
	touch $@

WRFV3/configure.wrf: WRFV3/configure wrf-configure.input
	(cd WRFV3 && \
	bash ./configure < ../wrf-configure.input && \
	sed -i -e 's/-O2 -ftree-vectorize -funroll-loops/-O3 -ffast-math -march=native -funroll-loops -fno-protect-parens -flto/' configure.wrf && \
	sed -i -e 's/FORMAT_FIXED    =       /FORMAT_FIXED    =       -cpp /' configure.wrf && \
	sed -i -e 's/FORMAT_FREE     =       /FORMAT_FREE     =       -cpp /' configure.wrf && \
	sed -i -e 's/FCNOOPT         =       -O0/-O3 -ffast-math -march=native -funroll-loops -fno-protect-parens -flto -cpp/' configure.wrf) && \
	touch $@

WRFV3/main/wrf.exe WRFV3/main/real.exe: WRFV3/configure.wrf
	(cd WRFV3 && \
	csh ./compile em_real && \
	strip main/wrf.exe main/real.exe)

WRFV3/run/namelist.input: namelist.input
	cp $< $@
	touch $@

#Archives
wrf.tar.gz:
	wget -O $@ http://www.mmm.ucar.edu/wrf/src/WRFV3.5.1.TAR.gz

wps.tar.gz:
	wget -O $@ http://www.mmm.ucar.edu/wrf/src/WPSV3.5.1.TAR.gz

geog.tar.gz:
	wget -O $@ http://www.mmm.ucar.edu/wrf/src/wps_files/geog_v3.4.tar.gz
