/* filewrite lets me write a "file" from a string 
fileread lets me store a file as a string

Say I have a dataset that contains a "pdf" file (copy of a section of the federal register) in a strL variable called "federal_register"
*/
/* This command will write the federal register to the "output.pdf" file in your home directory for the first observation */

gen p=filewrite("output.pdf", federal_register) if _n==1
/* This command will store the file in "input.pdf" file into the strL variable called "federal_register" in the 999th observation if 
the federal register variable is empty for that observation
*/

drop p
replace federal_register=fileread("infile.pdf") if _n==999 & strmatch(federal_register,"")
