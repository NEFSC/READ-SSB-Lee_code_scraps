cd "/home/mlee/Documents/Workspace/technical folder/do file scraps"
quietly do "/home/mlee/Documents/Workspace/technical folder/do file scraps/odbc_connection_macros.do"
#delimit;
global oracle_cxn "conn("$mysole_conn") lower";
/* ORACLE SQL IN UBUNTU using Stata's connectstring feature.*/

#delimit ;
/* LOOPS OVER A QUERY from SOLE */
forvalues myy=1996/2015{;
	tempfile new;
	local NEWfiles `"`NEWfiles'"`new'" "'  ;
	clear;

	odbc load,  exec("select distinct gearid from vtr.veslog`myy'g;") $oracle_cxn;

	gen dbyear= `myy';
	quietly save `new';
};

dsconcat `NEWfiles';
	renvarlab, lower;

