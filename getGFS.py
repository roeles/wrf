import os
import urllib

year = 2014
month = 1
day = 1
tforcast = 0
t0 = 0
t1 = 24
dt = 3

dirout = str(year)+str(month).zfill(2)+str(day).zfill(2)
if not os.path.exists(dirout):
  os.mkdir(dirout)

nt = (t1-t0)/dt+1
for t in range(nt):
  tact = t0 + t * dt
  loc = 'http://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.'+\
          str(year)+\
          str(month).zfill(2)+\
          str(day).zfill(2)+\
          str(tforcast).zfill(2)
  fil = 'gfs.t'+\
          str(tforcast).zfill(2)+\
          'z.pgrb2f'+\
          str(tact).zfill(2)
  url = loc + '/' + fil

  print "'" + str(url) + "' -> '" + dirout + "/" + fil + "'"
  urllib.urlretrieve (url,dirout+'/'+fil)
 
   


