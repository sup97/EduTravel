import delimited C:\Users\soyou\Documents\GitHub\EduTravel\id_weight.csv, varnames(1) clear 
drop v1
save weights, replace

import delimited C:\Users\soyou\Documents\GitHub\EduTravel\final_data_0226.csv, ///
 numericcols(8/44) clear

merge m:m childid using weights 
save final_data_0226, replace
drop _merge

set more off

drop did tincth build-tellst parentid cregion
drop treatedm-treatedz
drop if c245pw0=="NA" | c245pw0=="0"
destring c245pw0, replace force
sum c245pw0

rename r4mscl math
rename r4rscl reading
rename screen english
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
bysort childid (round): replace english = english[2]

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
bysort childid (round): replace treated1 = 1 if trip[3] > 0
bysort childid (round): replace treated2 = 1 if trip[5] > 0 
bysort childid (round): replace treated3 = 1 if trip[3] > 0 & trip[5] > 0 

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

egen n = group(childid)
sum n

drop if reading ==. & round !=0
drop if math ==. & round !=0

sum n

* DID without cov*
diff reading, t(treated) p(time)
diff math, t(treated) p(time)

*DID with cov and psm*
//Trip//
set more off
qui pscore treated1 gender white black asian hispanic expect learn ///
english timewchildren ses [pw=c245pw0], pscore(psm) logit blockid(psm_block) detail

psgraph, treated(treated1) pscore(psm) 
graph export "C:\Users\soyou\Documents\GitHub\EduTravel\ps_score_trip.pdf", as(pdf) replace

qui psmatch2 treated1, outcome(reading) pscore(psm)
qui psmatch2 treated1, outcome(math) pscore(psm)

qui pstest gender white black asian hispanic expect learn ///
english timewchildren ses, treated(treated1) both graph
graph export "C:\Users\soyou\Documents\GitHub\EduTravel\matched_trip.pdf", as(pdf) replace

diff reading, t(treated1) p(time) cov(gender white black asian hispanic expect learn ///
english timewchildren ses) ps(psm) robust report 

diff math, t(treated1) p(time) cov(gender white black asian hispanic expect learn ///
english timewchildren ses) ps(psm) robust report

set more off
drop psm psm_block
qui pscore treated2 gender white black asian hispanic expect learn ///
english timewchildren ses [pw=c245pw0], pscore(psm) logit blockid(psm_block) detail
//psgraph, treated(treated2) pscore(psm) 

qui psmatch2 treated2, outcome(reading) pscore(psm)
qui psmatch2 treated2, outcome(math) pscore(psm)

qui pstest gender white black asian hispanic expect learn ///
english timewchildren ses, treated(treated2) both graph

diff reading, t(treated2) p(time) cov(gender white black asian hispanic expect learn ///
english timewchildren ses) ps(psm) robust report 

diff math, t(treated2) p(time) cov(gender white black asian hispanic expect learn ///
english timewchildren ses) ps(psm) robust report

set more off
drop psm psm_block
qui pscore treated3 gender white black asian hispanic expect learn ///
english timewchildren ses [pw=c245pw0], pscore(psm) logit blockid(psm_block) detail
//psgraph, treated(treated3) pscore(psm) 

qui psmatch2 treated3, outcome(reading) pscore(psm)
qui psmatch2 treated3, outcome(math) pscore(psm)

qui pstest gender white black asian hispanic expect learn ///
english timewchildren ses, treated(treated3) both graph

diff reading, t(treated3) p(time) cov(gender white black asian hispanic expect learn ///
english timewchildren ses) ps(psm) robust report 

diff math, t(treated3) p(time) cov(gender white black asian hispanic expect learn ///
english timewchildren ses) ps(psm) robust report

//Museum//
drop psm psm_block
set more off
qui pscore tmuseum gender white black asian hispanic expect learn ///
english timewchildren ses [pw=c245pw0], pscore(psm) blockid(psm_block) logit detail
//bysort childid (round): replace psm = psm[3]
//psgraph, treated(tmuseum) pscore(psm)
//graph export "C:\Users\soyou\Documents\GitHub\EduTravel\ps_score_museum.pdf", as(pdf) replace

qui psmatch2 tmuseum, outcome(reading) pscore(psm)
qui psmatch2 tmuseum, outcome(math) pscore(psm)
qui pstest gender white black asian hispanic expect learn ///
english timewchildren ses, treated(tmuseum) both graph
graph export "C:\Users\soyou\Documents\GitHub\EduTravel\matched_museum.pdf", as(pdf) replace

diff reading, t(tmuseum) p(time) cov(gender white black asian hispanic expect learn ///
english timewchildren ses) ps(psm) robust report
diff math, t(tmuseum) p(time) cov(gender white black asian hispanic expect learn ///
english timewchildren ses) ps(psm) robust report
drop psm psm_block

//Concert//
qui pscore tconcrt gender white black asian hispanic expect learn ///
english timewchildren ses [pw=c245pw0], pscore(psm) blockid(psm_block) 
//bysort childid (round): replace psm = psm[3]
//psgraph, treated(tconcrt) pscore(psm)
//graph export "C:\Users\soyou\Documents\GitHub\EduTravel\ps_score_concert.pdf", as(pdf) replace

psmatch2 tconcrt, outcome(reading) pscore(psm)
psmatch2 tconcrt, outcome(math) pscore(psm)
qui pstest gender white black asian hispanic expect learn ///
english timewchildren ses, treated(tconcrt) both graph
graph export "C:\Users\soyou\Documents\GitHub\EduTravel\matched_concert.pdf", as(pdf) replace

diff reading, t(tconcrt) p(time) cov(gender white black asian hispanic expect learn ///
english timewchildren ses) ps(psm) robust report

diff math, t(tconcrt) p(time) cov(gender white black asian hispanic expect learn ///
english timewchildren ses) ps(psm) robust report
drop psm psm_block

//Zoo//
qui pscore tzoo gender white black asian hispanic expect learn ///
english timewchildren ses [pw=c245pw0], pscore(psm) blockid(psm_block) detail
//psgraph, treated(tzoo) pscore(psm)
//graph export "C:\Users\soyou\Documents\GitHub\EduTravel\ps_score_zoo.pdf", as(pdf) replace

psmatch2 tzoo, outcome(reading) pscore(psm)
psmatch2 tzoo, outcome(math) pscore(psm)
qui pstest gender white black asian hispanic expect learn ///
english timewchildren ses, treated(tzoo) both graph
graph export "C:\Users\soyou\Documents\GitHub\EduTravel\matched_zoo.pdf", as(pdf) replace

diff reading, t(tzoo) p(time) cov(gender white black asian hispanic expect learn ///
english timewchildren ses) ps(psm) robust report

diff math, t(tzoo) p(time) cov(gender white black asian hispanic expect learn ///
english timewchildren ses) ps(psm) robust report
drop psm psm_block

//Sport//
qui pscore tsport gender white black asian hispanic expect learn ///
english timewchildren ses [pw=c245pw0], pscore(psm) blockid(psm_block) detail
//psgraph, treated(tsport) pscore(psm)
//graph export "C:\Users\soyou\Documents\GitHub\EduTravel\ps_score_sport.pdf", as(pdf) replace

psmatch2 tsport, outcome(reading) pscore(psm)
psmatch2 tsport, outcome(math) pscore(psm)
qui pstest gender white black asian hispanic expect learn ///
english timewchildren ses, treated(tsport) both graph
graph export "C:\Users\soyou\Documents\GitHub\EduTravel\matched_sport.pdf", as(pdf) replace

diff reading, t(tsport) p(time) cov(gender white black asian hispanic expect learn ///
english timewchildren ses) ps(psm) robust report

diff math, t(tsport) p(time) cov(gender white black asian hispanic expect learn ///
english timewchildren ses) ps(psm) robust report
