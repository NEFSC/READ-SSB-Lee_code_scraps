use "/home/mlee/Documents/xpbuntu/statawd/hedonic/all_dealers/daily_file.dta"

keep date qcod
replace qcod=qcod/1000
label var qcod "Cod Quantity ('000s lbs)
tsline qcod, graphregion(fcolor(white))

tsline qcod, graphregion(fcolor(white)) tlabel(#8, format(%tdCCYY))

