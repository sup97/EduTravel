import delimited C:\Users\soyou\Documents\GitHub\EduTravel\final_data.csv, clear

set more off

drop did
drop tincth
drop build-tellst
drop parentid cregion

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

//generate ses variable
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

*DID with cov*
diff reading, t(treated1) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) robust kernel id(childid) report

set more off
diff reading, t(tmuseum) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) kernel id(childid) robust test report

diff reading, t(tconcrt) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) robust report

diff reading, t(tzoo) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) robust report

diff reading, t(tsport) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) robust report

diff math, t(treated1) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) robust report

*DID with PSM*
set more off

diff reading, t(treated1) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) kernel id(childid) report

diff reading, t(tmuseum) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) kernel id(childid) report

diff reading, t(tconcrt) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) kernel id(childid) report

diff reading, t(tzoo) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) kernel id(childid) report

diff reading, t(tsport) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) kernel id(childid) report

diff math, t(treated1) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) kernel id(childid) report

diff math, t(tmuseum) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) kernel id(childid) report

diff math, t(tconcrt) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) kernel id(childid) report

diff math, t(tzoo) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) kernel id(childid) report

diff math, t(tsport) p(time) cov(gender white black asian expect learn ///
screen timewchildren ses) kernel id(childid) report
