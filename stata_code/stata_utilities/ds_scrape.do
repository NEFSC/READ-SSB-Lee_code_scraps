/*I'm not exactly sure what this does
 this relies on the order of the variables being in the proper order*/

ds *_tsn
local taxa=r(varlist)

gen taxa_level=""

foreach level of local taxa{
local myl: subinstr  local level "_tsn" ""
replace taxa_level="`myl'" if `level'~=.
di "`myl'"
}

/*
kingdom_tsn      phylum_tsn       class_tsn        order_tsn        subsection_tsn   tribe_tsn        species_tsn
subkingdom_tsn   subphylum_tsn    subclass_tsn     suborder_tsn     superfamily_tsn  subtribe_tsn     subspecies_tsn
infrakingdom_tsn infraphylum_tsn  infraclass_tsn   infraorder_tsn   family_tsn       genus_tsn
superphylum_tsn  superclass_tsn   superorder_tsn   section_tsn      subfamily_tsn    subgenus_tsn
*/
