/* The lenting calendar */
/* Note that while Lent has 40 days, these 40 days omit Sunday */
/* These are the dates of Ash Wednesday 
Feb 18, 2015
Mar 5, 2014
Feb 13, 2013
Feb 22, 2012
Mar 9, 2011
Feb 17, 2010
Feb 25, 2009
Feb 6, 2008
Feb 21, 2007
March 1, 2006
Feb 9, 2005
Feb 25, 2004
Mar 5, 2003
Feb 13, 2002
Feb 28, 20011
Mar 8, 2000
Feb 17, 1999
Feb 25, 1998

These are the dates of easter Sunday
April 5, 2015
April 20, 2014
Mar 31, 2013
April 8, 2012
April 24, 2011
April 4, 2010
April 12, 2009
March 23, 2008
April 8, 2007
April 16, 2006
March 27, 2005
April 11, 2004
April 20, 2003
March 31, 2002
April 15, 2001
April 23, 2000
April 4, 1999
April 12, 1998
 */
 
 
cd "/home/mlee/Documents/technical folder/do file scraps"
clear
set obs 2
gen mydate=date("01/01/1998", "MDY")
replace mydate=date("01/01/2016", "MDY") if _n==2
format mydate %td
tsset mydate
tsfill, full

gen lent=0
replace lent=1 if mydate>=date("02/25/1998", "MDY") & mydate<=date("04/12/1998", "MDY")
replace lent=1 if mydate>=date("02/17/1999", "MDY") & mydate<=date("04/4/1999", "MDY")
replace lent=1 if mydate>=date("03/8/2000", "MDY") & mydate<=date("04/23/2000", "MDY")
replace lent=1 if mydate>=date("02/28/2001", "MDY") & mydate<=date("04/15/2001", "MDY")
replace lent=1 if mydate>=date("02/13/2002", "MDY") & mydate<=date("03/31/2002", "MDY")
replace lent=1 if mydate>=date("03/05/2003", "MDY") & mydate<=date("04/20/2003", "MDY")
replace lent=1 if mydate>=date("02/25/2004", "MDY") & mydate<=date("04/11/2004", "MDY")
replace lent=1 if mydate>=date("02/09/2005", "MDY") & mydate<=date("03/27/2005", "MDY")
replace lent=1 if mydate>=date("03/01/2006", "MDY") & mydate<=date("04/16/2006", "MDY")
replace lent=1 if mydate>=date("02/21/2007", "MDY") & mydate<=date("04/8/2007", "MDY")
replace lent=1 if mydate>=date("02/6/2008", "MDY") & mydate<=date("03/23/2008", "MDY")
replace lent=1 if mydate>=date("02/25/2009", "MDY") & mydate<=date("04/12/2009", "MDY")
replace lent=1 if mydate>=date("02/17/2010", "MDY") & mydate<=date("04/04/2010", "MDY")
replace lent=1 if mydate>=date("03/09/2011", "MDY") & mydate<=date("04/24/2011", "MDY")
replace lent=1 if mydate>=date("02/22/2012", "MDY") & mydate<=date("04/8/2012", "MDY")
replace lent=1 if mydate>=date("02/13/2013", "MDY") & mydate<=date("03/31/2013", "MDY")
replace lent=1 if mydate>=date("03/05/2014", "MDY") & mydate<=date("04/20/2014", "MDY")
replace lent=1 if mydate>=date("02/18/2015", "MDY") & mydate<=date("04/5/2015", "MDY")
rename mydate date
note lent: The dummy variable date takes on the value of 1 if it is Lent (Date between Ash Wednesday and Easter Sunday, Inclusive).  Otherwise, it is 0.
save "/home/mlee/Documents/technical folder/do file scraps/lent_dates.dta", replace
