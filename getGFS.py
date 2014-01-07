import datetime
import sys

#http://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.2014010100/gfs.t00z.pgrb2f00

timestamp = datetime.datetime.now()
if len(sys.argv) > 3:
	pass 

year = 2014
month = 1
day = 1
tforcast = 0
t0 = 0
t1 = 24
dt = 3
root = "run/gfs"


str_year = str(year)
str_month = str(month).zfill(2)
str_day = str(day).zfill(2)
str_tforcast = str(tforcast).zfill(2)

nt = (t1-t0)/dt+1
for t in range(nt):
  tact = t0 + t * dt
  str_tact = str(tact).zfill(2)
  loc =   str_year + \
          str_month + \
          str_day + \
          str_tforcast
  fil = 'gfs.t'+\
          str_tforcast + \
          'z.pgrb2f'+ \
          str_tact
  url = root + "/" + loc + '/' + fil

  print url,
   


