FYI, Stata+ODBC isn't getting along nicely with the 16 digit GEARIDs. 

It's best to do:
select to_char(gearid) as mygearid from veslog2010g;
instead of
select gearid from veslog2010g;
