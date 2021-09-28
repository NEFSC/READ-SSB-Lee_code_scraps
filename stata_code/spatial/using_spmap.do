/* Using SPMAP */
clear

cd "/home/mlee/Documents/Herring_PDT_work/fw3/newHMAs"
/* Split the shapefile using shp2dta 
shp2dta using New_Herring_Management_Areas.shp, database("HMA_data") coordinates("HMA_coords") replace
*/


/* load the data that contains the database filename into stata's memory*/ 
use HMA_data.dta



/* run spmap, using the "coordinates" dta file*/
spmap using "/home/mlee/Documents/Herring_PDT_Work/fw3/newHMAs/HMA_coords.dta", id(_ID)


/* Overlay points into that map */



/* following along with spmap */
/* the sample datasets are in my home directory */
