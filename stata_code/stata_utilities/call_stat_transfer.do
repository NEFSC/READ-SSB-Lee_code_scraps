/* This code will call stat-transfer and convert the file investigate_base.dta into a dbf. it will overwrite the file.*/
/* The general form of this is:
shell <your executable> 
For stat transfer, you have to supply the input filename and output filename.  the '-y' flag tells stat transfer to overwrite*/


/* this works and I left a symlink */
shell /home/mlee/Documents/StatTransfer12/st investigate_base.dta investigate_base.dbf -y

/* I reinstalled st transfer and added the directory to path, so use this */
shell st investigate_base.dta investigate_base.dbf -y
