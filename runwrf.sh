WRFPATH=/scratch/mpi/mpiaes/m300241/WRFnl

# start and end dates
# AUTO SELECTION
#YEAR=$(date +%Y)
#MONTH=$(date +%m)
#DAY=$(date +%d)
#ENDYEAR=$(date --d "now +1 days" +%Y)
#ENDMONTH=$(date --d "now +1 days" +%m)
#ENDDAY=$(date --d "now +1 days" +%d)

# MANUAL SELECTION
YEAR=2014
MONTH=01
DAY=01

ENDYEAR=2014
ENDMONTH=01
ENDDAY=02

# ===============================================================
# Download GFS data using Gribmaster
# ===============================================================
#echo '************************'
#echo 'GRIBMASTER'
#echo '************************'

#cd $WRFPATH/gribmaster5
GFSDATA=$YEAR$MONTH$DAY
#./gribmaster --dset gfs004grb2 --date $GFSDATA --length 24 #>& gribmaster.log
#
#if [ $( grep "ENJOY" gribmaster.log | wc -l ) -eq 1 ]; then
#  echo "    GRIBMASTER -> SUCCES, continuing.." 
#else
#  echo "    GRIBMASTER -> FAILED, stopping..."
#  exit 1
#fi

# ===============================================================
# Start WPS routine
# ===============================================================
echo '************************'
echo 'WPS routines'
echo '************************'
cd $WRFPATH/WPS

STARTSTRINGWPS=\'$YEAR-$MONTH-$DAY'_00:00:00'\'','\'$YEAR-$MONTH-$DAY'_00:00:00'\'
ENDSTRINGWPS=\'$ENDYEAR-$ENDMONTH-$ENDDAY'_00:00:00'\'','\'$ENDYEAR-$ENDMONTH-$ENDDAY'_00:00:00'\'

# Find-replace in namelist.wps
echo '    Changing WPS namelist'
sed -i -e "s/\(start_date\).*/\1 = $STARTSTRINGWPS/g" namelist.wps
sed -i -e "s/\(end_date\).*/\1 = $ENDSTRINGWPS/g" namelist.wps

# Remove old stuff
rm -f GRIBFILE*
rm -f FILE*
rm -f met_em*

# Start routines
echo '    Running geogrid.'
./geogrid.exe 
GFSDIR=$YEAR$MONTH$DAY
./link_grib.csh ../GFSDATA/$GFSDIR/*
echo '    Running ungrib..'
./ungrib.exe 
echo '    Running metgrid...'
./metgrid.exe 

## ===============================================================
## Start WRF forecast
## ===============================================================
echo '************************'
echo 'WRF routines'
echo '************************'
cd $WRFPATH/WRFV3/run/
rm -f met_em*

WRFYEAR=$YEAR','$YEAR','
WRFMONTH=$MONTH','$MONTH','
WRFDAY=$DAY','$DAY','
WRFENDYEAR=$ENDYEAR','$ENDYEAR','
WRFENDMONTH=$ENDMONTH','$ENDMONTH','
WRFENDDAY=$ENDDAY','$ENDDAY','

# Find-replace in namelist.input
sed -i -e "s/\(start_year\).*/\1 = $WRFYEAR/g" namelist.input
sed -i -e "s/\(start_month\).*/\1 = $WRFMONTH/g" namelist.input
sed -i -e "s/\(start_day\).*/\1 = $WRFDAY/g" namelist.input
sed -i -e "s/\(end_year\).*/\1 = $WRFENDYEAR/g" namelist.input
sed -i -e "s/\(end_month\).*/\1 = $WRFENDMONTH/g" namelist.input
sed -i -e "s/\(end_day\).*/\1 = $WRFENDDAY/g" namelist.input

# start routines
ln -s ../../WPS/met_em* .
echo '    running real & WRF'
./real.exe 
echo '    running wrf.....'
./wrf.exe
#sbatch runles.slurm

exit 

