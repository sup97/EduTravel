import delimited C:\Users\soyou\Documents\GitHub\EduTravel\id_weight.csv, varnames(1) clear 
drop v1
save weights, replace

import delimited C:\Users\soyou\Documents\GitHub\EduTravel\final_data.csv, clear

merge m:m childid using weights 
save final_data, replace

set more off

drop did
drop tincth
drop build-tellst
drop parentid cregion
drop if c245pw0=="NA" | c245pw0=="0"

rename r4mscl math
rename r4rscl reading

destring concrt-treated, force replace

//time: 1 if greater than round 2, 0 else
//treated: if took at least one trip, 1, else 0

//set all income and father/mother education/job to base round (0) value
bysort childid (round): replace income = income[1] if round > 0
bysort childid (round): replace daded = daded[1] if round > 0
bysort childid (round): replace dadscr = dadscr[1] if round > 0
bysort childid (round): replace momed = momed[1] if round > 0
bysort childid (round): replace momscr = momscr[1] if round > 0

//set approach to learning, expectation for education level, and 
//english speaking environment to the first round value
bysort childid (round): replace learn = learn[2] 
bysort childid (round): replace expect = expect[2]
bysort childid (round): replace screen = screen[2]

bysort childid: egen timewchildren1 = mean(timewchildren)
bysort childid: replace timewchildren = timewchildren1 if timewchildren==.
//generate ses variable
sort childid round
factor daded dadscr income momed momscr, pcf
predict ses 

//generate treated variable - trip
gen treated1 = 0
gen treated2 = 0
gen treated3 = 0
bysort childid (round): replace treated1 = 1 if trip > 0 & round == 2
bysort childid (round): replace treated2 = 1 if trip > 1 & round == 2
bysort childid (round): replace treated3 = 1 if trip > 2 & round == 2

bysort childid (round): replace treated1 = treated1[3] 
bysort childid (round): replace treated2 = treated2[3] 
bysort childid (round): replace treated3 = treated3[3] 

//generate treated variable - museum
gen tmuseum = 0
gen tconcrt = 0
gen tzoo = 0
gen tsport = 0

bysort childid (round): replace tmuseum = 1 if museum > 0 & round == 2
bysort childid (round): replace tconcrt = 1 if concrt > 0 & round == 2
bysort childid (round): replace tzoo = 1 if zoo > 0 & round == 2
bysort childid (round): replace tsport = 1 if sport > 0 & round == 2

bysort childid (round): replace tmuseum = tmuseum[3] 
bysort childid (round): replace tconcrt = tconcrt[3] 
bysort childid (round): replace tzoo = tzoo[3] 
bysort childid (round): replace tsport = tsport[3] 

drop if reading ==.

* DID without cov*
diff reading, t(treated) p(time)
diff math, t(treated) p(time)

*DID with cov and psm*
set more off

qui pscore treated1 gender white black asian expect learn ///
screen timewchildren ses, pscore(psm) blockid(psm_block) detail
psgraph, treated(treated1) pscore(psm)
qui psmatch2 treated1, outcome(reading) pscore(psm)
qui psmatch2 treated1, outcome(math) pscore(psm)

qui pstest gender white black asian expect learn ///
screen timewchildren ses, treated(treated1) both graph

diff reading, t(treated1) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) ps(psm) robust report 

diff math, t(treated1) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) ps(psm) robust report
drop psm psm_block

qui pscore tmuseum gender white black asian expect learn ///
screen timewchildren ses, pscore(psm) blockid(psm_block) detail
psgraph, treated(tmuseum) pscore(psm)
qui psmatch2 tmuseum, outcome(reading) pscore(psm)
qui psmatch2 tmuseum, outcome(math) pscore(psm)
qui pstest gender white black asian expect learn ///
screen timewchildren ses, treated(tmuseum) both graph

diff reading, t(tmuseum) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) ps(psm) robust report
diff math, t(tmuseum) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) ps(psm) robust report
drop psm psm_block

qui pscore tconcrt gender white black asian expect learn ///
screen timewchildren ses, pscore(psm) blockid(psm_block) 
bysort childid (round): replace psm = psm[3]
psgraph, treated(tconcrt) pscore(psm)
psmatch2 tconcrt, outcome(reading) pscore(psm)
psmatch2 tconcrt, outcome(math) pscore(psm)
qui pstest gender white black asian expect learn ///
screen timewchildren ses, treated(tconcrt) both graph

diff reading, t(tconcrt) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) ps(psm) robust report

diff math, t(tconcrt) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) ps(psm) robust report
drop psm psm_block

qui pscore tzoo gender white black asian expect learn ///
screen timewchildren ses, pscore(psm) blockid(psm_block) detail
psgraph, treated(tzoo) pscore(psm)
psmatch2 tzoo, outcome(reading) pscore(psm)
psmatch2 tzoo, outcome(match) pscore(psm)
qui pstest gender white black asian expect learn ///
screen timewchildren ses, treated(tzoo) both graph

diff reading, t(tzoo) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) ps(psm) robust report

diff math, t(tzoo) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) ps(psm) robust report
drop psm psm_block

qui pscore tsport gender white black asian expect learn ///
screen timewchildren ses, pscore(psm) blockid(psm_block) detail
psgraph, treated(tsport) pscore(psm)
psmatch2 tsport, outcome(reading) pscore(psm)
psmatch2 tsport, outcome(math) pscore(psm)
qui pstest gender white black asian expect learn ///
screen timewchildren ses, treated(tsport) both graph

diff reading, t(tsport) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) ps(psm) robust report

diff math, t(tsport) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) ps(psm) robust report
