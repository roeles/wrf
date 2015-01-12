#TODO: make native date-format 2014-01-01_00 or so, and remove -_ when needed (downloading)
#TODO: consistently rename files with : to the same file containing | or something else make can handle. Or maybe remove the date in the filename completely if make needs that?

all:  WPS/ungrib.exe
	echo All	

#To actually run a simulation

#TODO: do sed magic to search-replace on start_date en end_date. How to extract those values from % ?
run/%/namelist.wps: namelist.wps
	cp $< $@ 

run/%/geogrid: WPS/geogrid
	ln -s $(CURDIR)/$< $@

run/%/geo_em.d01.nc run/%/geo_em.d02.nc: WPS/geogrid.exe run/%/geogrid run/%/namelist.wps
	(cd `dirname $@` && \
	$(CURDIR)/WPS/geogrid.exe)

#http://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.2014010100/gfs.t00z.pgrb2f00
run/gfs/%:
	mkdir -p `dirname $@` && \
	wget -O $@ http://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$@

run/%/GRIBFILE.AAA: $(CURDIR)/WPS/link_grib.csh $(CURDIR)/run/gfs/%/gfs.t00z.pgrb2f00 $(CURDIR)/run/gfs/%/gfs.t00z.pgrb2f03 $(CURDIR)/run/gfs/%/gfs.t00z.pgrb2f06 $(CURDIR)/run/gfs/%/gfs.t00z.pgrb2f09 $(CURDIR)/run/gfs/%/gfs.t00z.pgrb2f12 $(CURDIR)/run/gfs/%/gfs.t00z.pgrb2f15 $(CURDIR)/run/gfs/%/gfs.t00z.pgrb2f18 $(CURDIR)/run/gfs/%/gfs.t00z.pgrb2f21 $(CURDIR)/run/gfs/%/gfs.t00z.pgrb2f24
	(mkdir -p `dirname $@` && \
	cd `dirname $@` && \
	csh $^)

run/%/Vtable: $(CURDIR)/WPS/ungrib/Variable_Tables/Vtable.GFS
	ln -s $< $@

#TODO: hoe doe je dit algemener?
run/%/FILE\:2014-01-01_00: run/%/Vtable WPS/ungrib.exe run/%/GRIBFILE.AAA run/%/namelist.wps
	(cd `dirname $@` && \
	ungrib.exe)

run/%/metgrid: WPS/metgrid
	ln -s $(CURDIR)/$< $@


#TODO: ook algemener
run/%/met_em.d01.2014-01-01_00\:00\:00.nc: WPS/metgrid.exe run/%/metgrid run/%/namelist.wps
	(cd `dirname $@` && \
	$(CURDIR)/$<)


#Building WPS
WPS/configure WPS/geogrid WPS/metgrid WPS/ungrib/Variable_Tables/Vtable.GFS: wps.tar.gz
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
	rm namelist.wps)
	#strip geogrid.exe ungrib.exe metgrid.exe)

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

geog/%: geog.tar.gz
	tar -xzf $<

#Archives
wrf.tar.gz:
	wget -O $@ http://www2.mmm.ucar.edu/wrf/src/WRFV3.6.1.TAR.gz

wps.tar.gz:
	wget -O $@ http://www2.mmm.ucar.edu/wrf/src/WPSV3.6.1.TAR.gz

geog.tar.gz:
	wget -O $@ http://www2.mmm.ucar.edu/wrf/src/wps_files/geog_v3.4.tar.gz
