/*This do file scrap does the following:
Open the dataset containing the vms datapoints inside the convex hull for area (nh), year(200i), and month (j)
It then formats the dates and times correctly so that stata can understand them.
It then keeps only the observations with the correct year and month.  If the dataset is empty, the program finishes.
If the dataset is non-empty, it drops duplicate trips (since a trip may be observed more than once).
It then generates a dummy variable called fishing effort
It sums the number of unique fishing trips by date and type of gear (easy to just sum by date or gear).
This produces a dataset with only two or three variables, date and fishing effort and gear type.*/ 


/*The next step is to "stack" the fishing effort variables together by region.  Then merge them by date
Also, fill in the timeseries so that there are no gaps.*/

forvalues i=2/6{
	forvalues j=6/10{
		use "C:\Users\Min-Yang\Documents\NMFS-synch\Natural Resource\Dissertation Travel Grant\Data\WWtrip data\Everything\monthlyvms\nh`j'_0`i'.dta", clear
		drop das_activi date_ year datesail datelnd year 
		gen subtractor=msofhours(4)
		gen double mypdate=clock(pdate,"DMYhms")
		gen double pdateET=mypdate-subtractor
		format pdateET %tc
		gen date=dofc(pdateET)
		drop subtractor
		format date %td
		gen year=year(date)
		gen month=month(date)
		drop pdate mypdate
		keep if year==200`i'
		keep if month==`j'
		gen nhfishingeffort=1
		if _N>0 {
			dups tripid date, terse drop
			collapse(sum) nhfishingeffort, by(date gearcode)
			save "C:\Users\Min-Yang\Documents\NMFS-synch\Natural Resource\Dissertation Travel Grant\Data\WWtrip data\Everything\monthlyvms\nh`j'_0`i'effort.dta", replace
		}
		else {
			keep date nhfishingeffort gearcode 
			save "C:\Users\Min-Yang\Documents\NMFS-synch\Natural Resource\Dissertation Travel Grant\Data\WWtrip data\Everything\monthlyvms\nh`j'_0`i'effort.dta", replace
		}	 
	}
}

/*use the june convex hulls to generate may fishing data, since may is so sparse*/
forvalues i=2/6{
		use "C:\Users\Min-Yang\Documents\NMFS-synch\Natural Resource\Dissertation Travel Grant\Data\WWtrip data\Everything\monthlyvms\nh6_0`i'.dta", clear
		drop das_activi date_ year datesail datelnd year 
		gen subtractor=msofhours(4)
		gen double mypdate=clock(pdate,"DMYhms")
		gen double pdateET=mypdate-subtractor
		format pdateET %tc
		gen date=dofc(pdateET)
		drop subtractor
		format date %td
		gen year=year(date)
		gen month=month(date)
		drop pdate mypdate
		keep if year==200`i'
		keep if month==5
		gen nhfishingeffort=1
		if _N>0 {
			dups tripid date, terse drop
			collapse(sum) nhfishingeffort, by(date gearcode)
			save "C:\Users\Min-Yang\Documents\NMFS-synch\Natural Resource\Dissertation Travel Grant\Data\WWtrip data\Everything\monthlyvms\nh5_0`i'effort.dta", replace
		}
		else {
			keep date nhfishingeffort gearcode
			save "C:\Users\Min-Yang\Documents\NMFS-synch\Natural Resource\Dissertation Travel Grant\Data\WWtrip data\Everything\monthlyvms\nh5_0`i'effort.dta", replace
		}	 
}
