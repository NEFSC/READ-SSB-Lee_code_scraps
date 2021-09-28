/* This illustrates drawing from a probability distribution using mata */
/* Min-Yang Lee */



clear
version 12
set more off
global numtrips 465000
cd "/home/mlee/Documents/Workspace/recreational_simulations/cod_and_haddock"
timer clear
preserve
/*
/* line drops */
use haddock_line_drops.dta, clear
sort hlinedrops
putmata myhaddpdf=(hlinedrops hpdf), replace


use haddock_length_count.dta, clear
sort length
do "process_haddock_selectivity.do"
use haddock_length_count.dta, clear

do "process_haddock.do"
restore

mata
/* This code gets the number of linedrops for haddock. I wrote it in two lines to make it explicit:
temp1=rdiscrete($numtrips,1 ,myhadd[.,2])
hrand=myhadd[temp1,1]*/


ehrand=myhaddpdf[rdiscrete($numtrips,1 ,myhaddpdf[.,2]),1]
end

clear
getmata ehrand 



tempvar hencounter cencounter
gen `hencounter'=0
gen byte ehkeep=0
gen byte ehrel=0
global haddockbag 20

scalar stopper=1

/* THESE ARE TAKEN FROM the cod-line-drops and haddock-line-drops*/
global haddock_upper_bound  25

timer on 99
mata



/* we can do this in 1 step*/
ehdraw=rowshape(matahadd_pdf[rdiscrete($numtrips*$haddock_upper_bound,1 ,matahadd_pdf[.,2]),1], $numtrips)
end


getmata (ehlength*)=ehdraw


 forval i=1/$haddock_upper_bound{   /* start haddock loop */
	replace `hencounter' =cond(`i'<=ehrand & ehkeep<$haddockbag,1,0) /* mark encountered */
	gen ehadd_status`i'=cond(`hencounter'==0,0, ///
		cond(ehlength`i'>=$hadd_min_keep & ehlength`i'<=$hadd_max_keep,1,2))  /* mark kept */
	
	replace ehkeep=ehkeep +1 if ehadd_status`i'==1  /* increment bag */
	replace ehrel=ehrel+1 if ehadd_status`i'==2     /* increment discards */
	replace `hencounter'=0

	quietly summ ehadd_status`i', meanonly
	scalar stopper=r(mean)

	if scalar(stopper)==0{
		display " `i' is the max"
		continue, break
	} 

	
} /* Endhaddock loop */
timer off 99
drop ehl* ehadd*
timer on 88
quietly forval i=1/$haddock_upper_bound{   /* start haddock loop */
	gen byte ehlength`i'=hadd_sizest[irecode(runiform(),$hadd_Fs_adj_cdf)+1, 1] /* fish length */
	replace `hencounter' =cond(`i'<=ehrand & ehkeep<$haddockbag,1,0) /* mark encountered */
	gen ehadd_status`i'=cond(`hencounter'==0,0, ///
		cond(ehlength`i'>=$hadd_min_keep & ehlength`i'<=$hadd_max_keep,1,2))  /* mark kept */
	
	replace ehkeep=ehkeep +1 if ehadd_status`i'==1  /* increment bag */
	replace ehrel=ehrel+1 if ehadd_status`i'==2     /* increment discards */
	replace `hencounter'=0

	quietly summ ehadd_status`i', meanonly
	drop ehlength`i' ehadd_status`i' 
	scalar stopper=r(mean)
	if scalar(stopper)==0{
		display " `i' is the max"
		continue, break
	} 

	
} /* Endhaddock loop */





timer off  88
timer list


*/











use haddock_line_drops.dta, clear
sort hlinedrops
putmata myhaddpdf=(hlinedrops hpdf), replace
global haddock_upper_bound=hlinedrops[_N]

use cod_line_drops.dta, clear
sort clinedrops
putmata mycodpdf=(clinedrops cpdf), replace
global cod_upper_bound=clinedrops[_N]
restore


global cdrop_range `"1/$cod_upper_bound"' 
global hdrop_range `"1/$haddock_upper_bound"' 








mata
/* This code gets the number of linedrops for haddock. I wrote it in two lines to make it explicit:
temp1=rdiscrete($numtrips,1 ,myhadd[.,2])
hrand=myhadd[temp1,1]*/


hrand=myhaddpdf[rdiscrete($numtrips,1 ,myhaddpdf[.,2]),1]
crand=mycodpdf[rdiscrete($numtrips,1 ,mycodpdf[.,2]),1]
ehrand=myhaddpdf[rdiscrete($numtrips,1 ,myhaddpdf[.,2]),1]
ecrand=mycodpdf[rdiscrete($numtrips,1 ,mycodpdf[.,2]),1]

/*check out the hrand and crand 

hrand[|1\30|]
crand[|1\30|]*/

/* THESE ARE TAKEN FROM the cod-line-drops and haddock-line-drops*/

/* This is 3 lines of code:
Line 1: draw the indices for haddock lengths.
Line 2: convert indices to lengths
Line 3: reshape into a matrix with $numtrips rows and $haddockbag columns 
hdraw=rdiscrete($numtrips*$haddockbag,1 ,matahadd_pdf[.,2]),1
hdraw1=matahadd_pdf[rdiscrete($numtrips*$haddockbag,1 ,matahadd_pdf[.,2]),1] 
hdraw2=rowshape(hdraw1,$numtrips)
*/

/* we can do this in 1 step*/
ehdraw=rowshape(matahadd_pdf[rdiscrete($numtrips*$haddock_upper_bound,1 ,matahadd_pdf[.,2]),1], $numtrips)
ecdraw=rowshape(matacod_pdf[rdiscrete($numtrips*$cod_upper_bound,1 ,matacod_pdf[.,2]),1], $numtrips)
hdraw=rowshape(matahadd_pdf[rdiscrete($numtrips*$haddock_upper_bound,1 ,matahadd_pdf[.,2]),1], $numtrips)
cdraw=rowshape(matacod_pdf[rdiscrete($numtrips*$cod_upper_bound,1 ,matacod_pdf[.,2]),1], $numtrips)
end

timer on 88
getmata ehrand hrand ecrand crand (ehlength*)=ehdraw (eclength*)=ecdraw (hlength*)=hdraw (clength*)=cdraw, double
timer off 88





