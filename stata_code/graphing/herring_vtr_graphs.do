/*create a graph of weekly landings (5yr average)*/

use "C:\Users\Min-Yang\Documents\NMFS-synch\data\DMR-data\summary\weekly_landings_5year_average.dta", clear
twoway (tsline mt), ytitle(Herring Landings (mt)) ttitle(Week)

graph export C:\Users\Min-Yang\Documents\NMFS-synch\data\DMR-data\summary\averageweekly0206.eps, replace

/*create a graph of weekly landings (each year)*/
use "C:\Users\Min-Yang\Documents\NMFS-synch\data\DMR-data\summary\weekly_landings2.dta", clear
xtline cumulative, overlay ytitle(Herring Landings (mt)) ttitle(Week) title(Cumulative Herring Landings 2002-2006)
graph export C:\Users\Min-Yang\Documents\NMFS-synch\data\DMR-data\summary\weekly0206.eps, replace