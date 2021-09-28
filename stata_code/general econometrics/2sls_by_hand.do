webuse hsng2, clear
mata: mata clear
gen cons=1
qui ivregress 2sls rent pcturban cons (hsngval = faminc i.region), noc small
est store iv
xi i.region
qui regress hsngval faminc i.region pcturban cons, noc
predict hsngvalhat, xb

qui regress rent pcturban hsngvalhat cons, noc
est store byhand
predict u1, resid
predict xhat, xb
/* fix the Ses */
gen hsngvhat_old=hsngvalhat
replace hsngvalhat=hsngval
predict fixresiduals, resid

/* N comes from e(sample) K is 3, but i did this by hand, you should pull it from the length of e(b) */
qui count if e(sample)
global N_K=r(N)-e(rank)



mata:

resids=st_data(.,"fixresiduals")
sighat=resids'resids/$N_K


X=st_data(.,"pcturban hsngval cons")
Z=st_data(.,"pcturban faminc i.region cons")

vce=invsym(X'Z*(invsym(Z'Z))*Z'X)*(resids'resids/$N_K)
se=sqrt(diagonal(vce))

end
est replay iv

/* the se's match <ivregress, small>

temp=X'Z*(invsym(Z'Z))*Z'X
 */

