quietly do "/home/mlee/Documents/Workspace/technical folder/do file scraps/odbc_connection_macros.do"
local solesql "select * from vlsppsyn;"
local novasql "select * from OBGEAR;"
local ratsql "select * from avtr.image_scan_blob where imgid=4415603;"
#delimit;
/*test sole */
odbc load,  exec("`solesql'") conn("$mysole_conn") lower clear;

/*odbc load,  exec("`solesql'") conn("$mysole_conn") lower clear;*/


/*test nova*/
clear;
odbc load,  exec("`novasql'") conn("$mynova_conn") lower clear;

odbc load,  exec("`ratsql'") conn("$mynero_conn") lower clear;
