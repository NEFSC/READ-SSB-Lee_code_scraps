/* This is a scrap which lets you draw from an 'ugly' discrete distribution */
/* This part just sets up the data:
	I have a frequency distribution of fish caught on a trip*/

clear
timer clear
macro drop _all

set seed 445
set obs 100000
/* I'll use poisson with lambda=4 to generate my data*/


gen fish_count=rpoisson(4)
gen number_of_trips=1
summ fish_count
collapse (sum)number_of_trips, by(fish_count)
tempvar totalcount
egen `totalcount'=total(number_of_trips)

/* It's probably a good idea to use double precision for the cdf and pdf.  Probably won't matter, but just in case. */

tempvar pdfcount
sort fish_count
gen double `pdfcount'=number_of_trips/`totalcount'
label var `pdfcount' "pdf of fish_caught on a trip"
gen double cdfcount=sum(`pdfcount')

line `pdfcount' fish_count 
desc
/*************************************/
/* this is the end of the setup */
/*************************************/


/* here is what you would do:
	1.  Make a local which contains the 'break points' in the CDF and is delimited by commas.
	2.  Create a matrix which contains the fish_caught and cdf of fish_caught
	3.  Generate an RV uniform (0,1)  
	4.  Use 'irecode' along with the local from step 1 to extract the 'index' of the data*/
sort fish_count
levelsof cdfcount, local(my_cdf_local) separate(,)
mkmat fish_count cdfcount, matrix(my_distribution_matrix)

clear
set obs 200000
tempvar x
gen `x'=runiform()
gen fish_count_sim=irecode(`x',`my_cdf_local')+1
replace fish_count_sim=my_distribution_matrix[fish_count_sim,1]
hist fish_count, width(1)








/*************************************/
/* Of course, this example is a little silly since you would just draw directly from stata's canned rpoisson() to create your data 
But what if the data instead looked like:

clear
set seed 30
set obs 30
egen fish_count=seq(), from (0) to (30)
gen number_of_trips=0+int((100-0+1)*runiform())


*lowess number_of_trips fish_count, adjust bwidth(.3) gen(trips) nograph
*drop number_of_trips
*rename trips number_of_trips 


tempvar totalcount
egen `totalcount'=total(number_of_trips)

tempvar pdfcount
sort fish_count
gen double `pdfcount'=number_of_trips/`totalcount'
label var `pdfcount' "pdf of fish_caught on a trip"
gen double cdfcount=sum(`pdfcount')
line `pdfcount' fish_count 

*/
