webuse _robust, clear
gen cons=1
keep if rep78~=0

qui regress mpg weight gear_ratio foreign cons, noconstant hascons
est store canned_ols

qui count if e(sample)
global N=r(N)
global N_K=r(N)-e(rank)

predict residuals, resid


qui regress mpg weight gear_ratio foreign cons, noconstant hascons robust
est store canned_white


/* estimate OLS by hand with mata. compute regular standard errors and heteroskedasticity consistent se's*/

mata:
Y=st_data(.,"mpg")
X=st_data(.,"weight gear_ratio foreign cons")

XpX  = quadcross(X, X)
XpXi=invsym(XpX)
XpY  = quadcross(X, Y)
ols=XpXi*XpY

resids=Y-X*ols


vce=(resids'resids/$N_K)*XpXi
se=sqrt(diagonal(vce))

test=resids:^2
sandwich=quadcross(X,resids:^2,X)

robust= $N/$N_K*XpXi*sandwich*XpXi
rob_se=sqrt(diagonal(robust))

ols 
se
rob_se

end
est replay canned
est replay canned_white


 sort rep78



/* estimate OLS by hand with mata. compute cluster-robust standard errors */
mata:
id   = st_data(., "rep78")
y    = st_data(., "price")
X    = st_data(., "mpg trunk")
n    = rows(X)

X    = X,J(n,1,1)
k    = cols(X)

XpX  = quadcross(X, X)
XpXi = invsym(XpX)

b    = XpXi*quadcross(X, y)
e    = y - X*b




info = panelsetup(id, 1)
info

nc   = rows(info)
M    = J(k, k, 0)

for(i=1; i<=nc; i++) {
     xi = panelsubmatrix(X,i,info)
     ei = panelsubmatrix(e,i,info)
     M  = M + xi'*(ei*ei')*xi
 }
 
V    = ((n-1)/(n-k))*(nc/(nc-1))*XpXi*M*XpXi
sqrt(diagonal(V))'
end
/* All I need to do is make the IV/2SLS style adjustment */



webuse hsng2, clear
mata: mata clear


/* IV REgress by hand with mata. compute standard errors */
mata:
id   = st_data(., "region")
y    = st_data(., "rent")

X    = st_data(., "pcturban hsngval")
n    = rows(X)
X    = X,J(n,1,1)
k    = cols(X)

Z    = st_data(.,"pcturban faminc")
Z    = Z,J(n,1,1)


XpZ  = quadcross(X, Z)
XpZi = invsym(XpZ)

ZpZ  = quadcross(Z, Z) 
ZpZi = invsym(ZpZ)

ZpX  = quadcross(Z, X) 
Zpy  = quadcross(Z, y) 


Pz   = Z*ZpZi*Z'
Pzi=invsym(Pz)

b=invsym(XpZ*ZpZi*ZpX) * (XpZ*ZpZi*Zpy)
e    = y - X*b

sighat=quadcross(e,e)/(n-k)

vce=sighat*invsym(XpZ*ZpZi*ZpX)
se=sqrt(diagonal(vce))


b
se

end

ivregress 2sls rent pcturban (hsngval = faminc), small


/* this doesn't work */
/* this doesn't work */

/* this doesn't work */
sort region


/* IV REgress by hand with mata. compute clustered standard errors */
mata:
id   = st_data(., "region")
y    = st_data(., "rent")

X    = st_data(., "pcturban hsngval")
n    = rows(X)
X    = X,J(n,1,1)
k    = cols(X)

Z    = st_data(.,"pcturban faminc")
Z    = Z,J(n,1,1)


XpZ  = quadcross(X, Z)
XpZi = invsym(XpZ)

ZpZ  = quadcross(Z, Z) 
ZpZi = invsym(ZpZ)

ZpX  = quadcross(Z, X) 
Zpy  = quadcross(Z, y) 


Pz   = Z*ZpZi*Z'
Pzi=invsym(Pz)

b=invsym(XpZ*ZpZi*ZpX) * (XpZ*ZpZi*Zpy)
e    = y - X*b



info = panelsetup(id, 1)
info

nc   = rows(info)
M    = J(k, k, 0)

for(i=1; i<=nc; i++) {
     xi = panelsubmatrix(X,i,info)
     zi = panelsubmatrix(Z,i,info)
     ei = panelsubmatrix(e,i,info)
     uj =  ei*(xi'zi)*invsym(zi'zi)zi'
     M  = M + ei*(xi'zi)*invsym(zi'zi)zi'
 }
 
V    = ((n-1)/(n-k))*(nc/(nc-1))*XpZ*ZpZi*ZpX*M*XpZ*ZpZi*ZpX
sqrt(diagonal(V))'
end
/* this doesn't work */
/* this doesn't work */
/* this doesn't work */


/* new strategy -- 
    Estimate SUR
    Construct predictors
    Estimate 2nd stage
    
    replace `predictions' with actuals
    predict residuals
    
    cluster boostrap.	
	
	
	
	*/









