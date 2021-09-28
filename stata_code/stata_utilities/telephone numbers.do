/* this cod takes a 10 digit string phone number and adds the usual "formatting" */
/*phone is a string AAABBBCCCC.  This becomes
tel=(AAA) BBB-CCCC */



gen tel="("+ substr(phonenumber, 1,3) + ")" + " " + substr(phonenumber, 4,3) + "-" + substr(phonenumber, 7,4)
