cd "/Users/mingzhao/Desktop"
unicode encoding set GB18030
unicode translate "CGSS2010.dta", invalid
unicode translate "CGSS2012.dta", invalid 
unicode translate "CGSS2013.dta", transutf8
unicode translate "CGSS2015.dta", invalid


use "CGSS2010.dta",clear
drop a89da a90da
append using "CGSS2012.dta", gen (year)
replace year=2010 if year==0
replace year=2012 if year==1
append using "CGSS2013.dta",force
replace year=2013 if year==.
append using "CGSS2015.dta",force
replace year=2015 if year==.

save "Thesis Datasets",replace

cd "/Users/mingzhao/Desktop"
use "Thesis Datasets",clear
tab year
********************************************************************************

//birth year
tab a3a,m
replace a3a=a301 if year==2015
tab a3a, nolab
gen ybirth=a3a
recode ybirth -3 -2=.
tab ybirth,m

//marriage year
tab a70,m
tab a70, nolab
gen ymar=a70
recode ymar -3 -2 -1 9997=.
tab ymar,m

//marital status
tab a69,m
tab a69,nolab
recode a69 -3=. 1/2=0 3/7=1, gen (married)
label variable married "Marital status"
lab def married 0 "0: unmarried" 1 "1: married"
lab val married married
tab married,m

//age at marriage or age at interview
*age at marriage
gen mage=ymar-ybirth
tab mage,m

*age at interview
gen iage=2015-ybirth if year==2015
replace iage=2013-ybirth if year==2013
replace iage=2012-ybirth if year==2012
replace iage=2010-ybirth if year==2010
tab iage,m

replace married=1 if mage!=.
tab married,m

gen age=.
replace age=mage
replace age=iage if married==0
label variable age "Age at marriage or age at interview"
tab age,m

//gender
tab a2,m
tab a2, nolab
recode a2 2=0, gen(gender)
label variable gender "Gender"
lab def gender 0 "0: female" 1 "1: male"
lab val gender gender
tab gender,m

//Household status
tab a18,m
tab a18, nolab

tab a18 if year==2015,m
tab a18 if year==2015, nolab

tab a18 if year==2013,m
tab a18 if year==2013, nolab

tab a18 if year==2012,m
tab a18 if year==2012, nolab

tab a18 if year==2010,m
tab a18 if year==2010, nolab

recode a18 1=0 2/5=1 *=., gen (hukou)   //军籍==1

label variable hukou "household status at marriage"
lab def hukou 0 "0: rural" 1 "1: urban"
lab val hukou hukou
tab hukou,m


tab a19,m
tab a19, nolab
recode a19 .=. 9997=. *=2, gen (change)
* if hukou status changed before marriage
gen mar_hukou=ymar-a19 if a19>0 & a19<2016
replace change=1 if mar_hukou>0 & mar_hukou<50
replace change=0 if mar_hukou<1
* umarried and hukou status
replace change=1 if married==0 & hukou==1 & change==2
* before 1980, no hukou change
replace change=0 if ymar<1980 & change==2
*why hukou change
replace change=0 if change==2 & a20>4 & a20<10
replace change=1 if change==2 & a20>0 & a20<5
*assumption
replace change=1 if change==2

label variable change "If hukou status changed before marriage"
lab def yesno 1 "1: yes" 0 "0: no"
lab val change yesno
tab change,m


replace hukou=0 if change==0


//Residence
tab s1,m
tab s1,nol
recode s1 2=0

tab s5a,m
tab s5a,nol
recode s5a 1/4=1 5=0 *=.

tab s5,m
tab s5,nol
recode s5 2=0

gen resid=.
replace resid=s1 if year==2015
replace resid=s5a if year==2012|year==2013
replace resid=s5 if year==2010

label variable resid "Current residence"
lab def resid 0 "0: rural" 1 "1: urban"
lab val resid resid
tab resid,m


/*
//If hukou status ever changed from rural to urban
tab a19,m
tab a19, nolab
recode a19 .=0 9997=0 1928/2015=1 -3/-1=1, gen (hukouchange)
label variable hukouchange "If hukou status ever changed from rural to urban"
lab def yesno 1 "1: yes" 0 "0: no"
lab val hukouchange yesno
tab hukouchange,m
*/

//Religion
tab a501,m
tab year if a501==.
tab a501, nolab

tab a5,m
tab a5, nolab

gen religion=.
replace religion = 0 if a501==1
replace religion=1 if a501==0
replace religion=0 if a5==1
replace religion=1 if a5>10 & a5<22
label define religion 1 "1: religious" 0 "0: not religious"
label variable religion "Religion"
lab val religion religion
tab religion,m


//Birth cohort
tab ybirth,m
recode ybirth (1914/1959=1) (1960/1974=2) (1975/1997=3) (*=.),gen(reform)
label variable reform "Birth cohort based on economic reform periods"
label define reform 1 "1: Pre-reform cohort (before 1960)" 2 "2: Early-reform cohort (1960-1974)" 3 "3: Late-reform cohort (after 1975)"
lab val reform reform
tab reform,m

//Highest education
tab a7a,m
tab a7a, nolab
recode a7a 1/3=1 4=2 5/8=3 9/13=4 *=., gen (edu)

label variable edu "Highest educational level before marriage"
lab def edu 1 "1: primary or below" 2 "2: junior high" 3 "3: senior high" 4 "4: college or above"
lab val edu edu
tab edu,m

//If highest education was achieved before marriage
tab a7c if a7b==4
gen ydegr=a7c if a7b==4
tab ydegr
recode ydegr -1 -2 -3 9997=.
tab ydegr,m

gen mar_degr=ymar-ydegr
tab mar_degr,m

	*When people's college degree is achieved after marriage within 4 years, their educational level before marriage is college
tab a7a,m
tab a7a, nolab
gen mar_collegedegr=0
replace mar_collegedegr=1 if (a7a==11|a7a==12) & (mar_degr==-1|mar_degr==-2|mar_degr==-3|mar_degr==-4)
tab mar_collegedegr

	*When people's junior college degree is achieved after marriage within 3 years, their educational level before marriage is junior college
gen mar_jcollegedegr=0
replace mar_jcollegedegr=1 if (a7a==9|a7a==10) & (mar_degr==-1|mar_degr==-2|mar_degr==-3)
tab mar_jcollegedegr	

	*When people's senior high degree is achieved after marriage within 3 years, their educational level before marriage is senior high
gen mar_highdegr=0
replace mar_highdegr=1 if (edu==3) & (mar_degr==-1|mar_degr==-2|mar_degr==-3)
tab mar_highdegr

	*highest education achieved before marriage: master or PhD (
gen collegeabove=0
replace collegeabove=1 if a7a==13
tab collegeabove

	*highest education achieved before marriage: primary or below education		
gen primary=0
replace primary=1 if edu==1
tab primary

	* highest education achieved before marriage: middle school 
gen middle=0
replace middle=1 if edu==2
tab middle

	*highest education achieved before marriage: dropout
tab a7b
tab a7b, nolab
gen dropout=0
replace dropout=1 if a7b==2|a7b==3
tab dropout

	*highest education achieved before marriage: unmarried
gen unmarried=0
replace unmarried=1 if married==0
tab unmarried


gen edubeforemar=.
replace edubeforemar=1 if mar_degr>-1 & mar_degr<46 //0 is assumed as education before marriage
replace edubeforemar=0 if mar_degr<0 & mar_degr>-45

replace edubeforemar=1 if mar_collegedegr==1
replace edubeforemar=1 if mar_jcollegedegr==1
replace edubeforemar=1 if mar_highdegr==1
replace edubeforemar=1 if collegeabove==1
replace edubeforemar=1 if primary==1
replace edubeforemar=1 if middle==1
replace edubeforemar=1 if dropout==1
replace edubeforemar=1 if unmarried==1 

tab edubeforemar,m

	*highest education achieved after marriage: 正在读
replace edubeforemar=0 if edubeforemar==. & a7b==1


replace edubeforemar=0 if edubeforemar==. & edu==3 & age<19
replace edubeforemar=1 if edubeforemar==. & edu==3 & age>18 

replace edubeforemar=0 if edubeforemar==. & (a7a==9|a7a==10) & age<22
replace edubeforemar=1 if edubeforemar==. & (a7a==9|a7a==10) & age>21

replace edubeforemar=0 if edubeforemar==. & (a7a==11|a7a==12) & age<23 
replace edubeforemar=1 if edubeforemar==. & (a7a==11|a7a==12) & age>22



label variable edubeforemar "If highest educational level was attained before marriage"
lab val edubeforemar yesno
tab edubeforemar,m

//Highest education before marriage
replace edu=edu-1 if edubeforemar==0

tab edu if gender==0 & resid==0 & reform==1  //extreme value
replace edu=3 if gender==0 & resid==0 & reform==1 & edu==4

/*
  Since the CGSS2010, CGSS2012, CGSS2013, and CGSS2015 fail to provide the exact education that respondents had before marriage, I construct the variable with the information of when getting married, when receiving highest educational degree, if currently enrolled in school and if having first marriage. For the missing values, I make assumptions that those whose educational levels are primary school, middle school, and graduate school, or who are illiteracy and dropouts achieved their highest educational levels before marriage. Education for observations who achieved highest educational levels before married is a one-level reduction from the current educational level.
*/

tab edu if gender==1 & resid==1 & reform==1 & married==1
tab edu if gender==1 & resid==1 & reform==2 & married==1
tab edu if gender==1 & resid==1 & reform==3 & married==1
tab edu if gender==1 & resid==0 & reform==1 & married==1
tab edu if gender==1 & resid==0 & reform==2 & married==1
tab edu if gender==1 & resid==0 & reform==3 & married==1
tab edu if gender==0 & resid==1 & reform==1 & married==1
tab edu if gender==0 & resid==1 & reform==2 & married==1
tab edu if gender==0 & resid==1 & reform==3 & married==1
tab edu if gender==0 & resid==0 & reform==1
tab edu if gender==0 & resid==0 & reform==2 & married==1
tab edu if gender==0 & resid==0 & reform==3 & married==1



********************************************************************************
//If Enrolled in School at marriage
tab a7b,m
tab a7b, nolab
recode a7b 1=1 *=0, gen (enrollment)


tab mar_degr,m
recode a7a 1/3=1 4=2 5/8=3 9/13=4 *=., gen (edu4)


	*When people's college degree is achieved after marriage within 4 years, enrolled in school before marriage
tab a7a,m
tab a7a, nolab
gen mar_col=0
replace mar_col=1 if (a7a==11|a7a==12) & (mar_degr==-1|mar_degr==-2|mar_degr==-3|mar_degr==-4)
tab mar_col

	*When people's junior college degree is achieved after marriage within 3 years, enrolled in school before marriage
replace mar_jcol=1 if (a7a==9|a7a==10) & (mar_degr==-1|mar_degr==-2|mar_degr==-3)
tab mar_jcol	

	*When people's senior high degree is achieved after marriage within 3 years, enrolled in school before marriage
gen mar_high=0
replace mar_high=1 if (edu4==3) & (mar_degr==-1|mar_degr==-2|mar_degr==-3)
tab mar_high

	*When people's master or PHD is achieved after marriage within 3 years, enrolled in school before marriage
gen colabove=0
replace colabove=1 if (a7a==13) & (mar_degr==-1|mar_degr==-2|mar_degr==-3)
tab colabove

	*unmarried and enrolled in school, enrolled in school before marriage
gen emar=0
replace emar=1 if married==0 & enrollment==1
tab emar


	*highest education achieved before marriage: primary or below education
	*not enrolled in school before marriage
gen eprimary=0
replace eprimary=1 if edu4==1
tab eprimary

	* highest education achieved before marriage: middle school 
	*not enrolled in school before marriage
gen emiddle=0
replace emiddle=1 if edu4==2
tab emiddle

	*highest education achieved before marriage: dropout
	*not enrolled in school before marriage
tab a7b
tab a7b, nolab
gen edropout=0
replace edropout=1 if a7b==2|a7b==3
tab edropout


gen enbeforemar=0  //0 is assumed as not enrolled

replace enbeforemar=1 if mar_degr==0
replace enbeforemar=1 if mar_col==1 & edubeforemar==1
replace enbeforemar=1 if mar_jcol==1 & edubeforemar==1
replace enbeforemar=1 if mar_high==1 & edubeforemar==1
replace enbeforemar=1 if colabove==1 & edubeforemar==1
replace enbeforemar=1 if emar==1 & edubeforemar==1 


replace enbeforemar=1 if (a7b==4 & enbeforemar==0 & married==1) & (edu4==3) & (age>15 & age<19) & (edubeforemar==1)

replace enbeforemar=1 if (a7b==4 & enbeforemar==0 & married==1) & (a7a==9|a7a==10) & (age>18 & age<22) & edubeforemar==1

replace enbeforemar=1 if (a7b==4 & enbeforemar==0 & married==1) & (a7a==11|a7a==12) & (age>18 & age<23) & (edubeforemar==1)

tab enbeforemar,m

replace enrollment=enbeforemar

tab enrollment
label variable enrollment "enrolled in school at marriage"
lab val enrollment yesno
tab enrollment,m

/*
//Work status
gen danwei=.
replace danwei=3 if a59k==1 & 
replace danwei=1 if a59k>1 & a59k!=.
replace danwei=1 if a60k>1 & a60k!=.
replace danwei=2 if a58==2 | a58==3 | a58==4 | a58==6
replace danwei=2 if a58==5

label variable danwei "Work status"
label define danwei 1 "1: employed in nonstate sector" 2 "2: unemployed" 3 "3: employed in state sector"
label value danwei danwei
*/

//Ethnicity
tab a4,m
tab a4, nolab
gen ethn =.
replace ethn = 0 if a4 == 1
replace ethn =1 if a4 > 1
label define ethn 1 "1: minority" 0 "0: majority"
label variable ethn "Ethnicity"
lab val ethn ethn
tab ethn,m

//Employment of parent when respondent was 14
tab a89d,m
tab a89d,nolab
gen femploy14=a89d
replace femploy14=. if a89d==17
replace femploy14=. if a89d<0
recode femploy14 (11/16 2 =1) (1 3/10=2) 

replace femploy14=2 if a89g>0 & a89g!=. & a89g!=5 & femploy14==.
replace femploy14=2 if a89h>0 & a89h<6 & femploy14==.

tab a90d,m
tab a90d,nolab
gen memploy14=a90d
replace memploy14=. if a90d==17
replace memploy14=. if a90d<0
recode memploy14 (11/16 2 =1) (1 3/10=2) 

replace memploy14=2 if a90g>0 & a90g!=. & a90g!=5 & memploy14==.
replace memploy14=2 if a90h>0 & a90h<6 & memploy14==.
tab memploy14,m

replace femploy14=memploy14 if femploy14==.
replace femploy14=2 if femploy14==1 & memploy14==2

tab femploy14,m

*out of labor includes those who were dead, disabled, retired, and enrolled in school
*employed includes both full-time employment, self employment, and part-time emolyment
*unemployed includes those who were full-time farmers, who lost jobs, and who were housekeepers

/*
tab a89d,m
tab a89d,nolab
gen femp=a89d
replace femp=. if a89d==17
replace femp=. if a89d<0
recode femp 11/16=1 2=2 3/5=3 1 6/10=4 

tab a90d,m
tab a90d,nolab
gen memp=a90d
replace memp=. if a90d==17
replace memp=. if a90d<0
recode memp 11/16=1 2=2 3/5=3 1 6/10=4  

tab memp if femp==.
replace femp=memp if femp==.
replace femp=memp if femp==1 & memp>1 & memp!=.
replace femp=memp if femp==2 & memp>2 & memp!=.
replace femp=memp if femp==3 & memp>3 & memp!=.

tab femp,m
label define femploy14 1 "1: unemployed" 2 "2: agriculture" 3 "3: part-time" 2 "2: full-time"
label variable femploy14 "Parent's employment status when you were 14"
lab val femploy14 femploy14
*/



//at least one parent was employed

label define femploy14 1 "1: unemployed" 2 "2: employed" 
label variable femploy14 "Parent's employment status when you were 14"
lab val femploy14 femploy14


recode femploy14 1=0 2=1 
tab femploy14
label variable femploy14 "If parent was employed when respondent at age 14"
lab val femploy14 yesno
tab femploy14,m

//schooling year of father
tab a89b,m
tab a89b,nolab

gen fysch=0 if a89b==1
replace fysch=3 if a89b==2
replace fysch=6 if a89b==3
replace fysch=9 if a89b==4
replace fysch=12 if a89b==5|a89b==6|a89b==7|a89b==8
replace fysch=15 if a89b==9|a89b==10
replace fysch=16 if a89b==11|a89b==12
replace fysch=19 if a89b==13


gen mysch=0 if a90b==1
replace mysch=3 if a90b==2
replace mysch=6 if a90b==3
replace mysch=9 if a90b==4
replace mysch=12 if a90b==5|a90b==6|a90b==7|a90b==8
replace mysch=15 if a90b==9|a90b==10
replace mysch=16 if a90b==11|a90b==12
replace mysch=19 if a90b==13

replace fysch=mysch if fysch==.
replace fysch=mysch if mysch>fysch & mysch!=. & fysch!=.

tab fysch,m
sum fysch

replace fysch=4.95 if fysch==.
label variable fysch "Parent's year of schooling"


//party membership
tab a89c
gen fparty=a89c==1
label define fparty 1 "1: party" 0 "0: no"
label variable fparty "Parent's party membership"
lab val fparty fparty

tab a90c
gen mparty=a90c==1
tab mparty,m

replace fparty=1 if fparty==0 & mparty==1
tab fparty,m


//region
rename s41 province
recode province 1=31 2=53 3=15 4=11 5=22 6=51 7=12 8=64  9=34 10=37 11=14 12=44 ///
		13=45 14=65 15=32 16=36 17=13 18=41 19=33 20=46 21=42 ///
		22=43 23=62 24=35 25=54 26=52 27=21 28=50 29=61 30=63 31=23
*create value label 
lab def pv_label 11 "beijing" 12 "tianjin" 13 "heibei" 14 "shanxi" 15 "inner-mongolia" ///
		21 "liaoning" 22 "jilin" 23 "heilongjiang" 31 "shanghai"  32 "jiangsu" 33 "zhejiang" ///
		34 "anhui" 35 "fujian" 36 "jiangxi" 37 "shangdong" 41 "henan" 42 "hubei" 43 "hunan" ///
		44 "guandong" 45 "guanxi" 46 "hainan" 50 "chongqing" 51 "sichuan" 52 "guizhou" ///
		53 "yunnan" 54 "tibet" 61 "shaanxi" 62 "gansu" 63 "qinghai"  64 "ningxia" 65 "xingjiang" 
*assign value label to province 
lab val province pv_label

gen region=4
replace region=1 if province==21|province==22|province==23
replace region=2 if province==11|province==12|province==13|province==31|province==32|province==33| ///
                    province==35|province==37|province==44|province==46
replace region=3 if province==14|province==34|province==36|province==41|province==42|province==43

label define region 1 "1: Northeastern" 2 "2: Eastern" 3 "3: Central" 4 "4: Western"
label variable region "Economic regions"
lab val region region
tab region,m




des age married gender hukou resid edu enrollment ethn femploy14 fysch fparty reform region

/*
              storage   display    value
variable name   type    format     label      variable label
---------------------------------------------------------------------------------------------------
age             float   %9.0g                 Age at marriage or age at interview
married         float   %12.0g     married    Marital status
gender          float   %9.0g      gender     Gender
hukou           float   %9.0g      hukou      household status at marriage
resid           float   %9.0g      resid      Current residence
edu             float   %19.0g     edu        Highest educational level before marriage
enrollment      float   %9.0g      yesno      enrolled in school at marriage
ethn            float   %11.0g     ethn       Ethnicity
femploy14       float   %13.0g     yesno      If parent was employed when respondent at age 14
fysch           float   %9.0g                 Parent's year of schooling
fparty          float   %9.0g      fparty     Parent's party membership
reform          float   %34.0g     reform     Birth cohort based on economic reform periods
region          float   %15.0g     region     Economic regions


*/

save "Thesis Datasets",replace

********************************************************************************


******************************Descriptive Statistics****************************


use "Thesis Datasets",clear

drop if age<15

replace weight=WEIGHT if year==2010

gen anasample2= (age!=.) &(married!=.) &(gender!=.) &(hukou!=.) &(resid!=.) &(edu!=.) &(enrollment!=.) &(ethn!=.) &(femploy14!=.) &(fysch!=.) &(reform!=.) &(fparty!=.) &(weight!=.)

drop if anasample2==0

keep age married gender hukou resid edu enrollment ethn femploy14 fysch fparty reform weight anasample2 region




//urban male
tabstat age fysch if gender==1 & resid==1 [aw=weight], by(reform) stat(mean sd count)
bysort reform: sum age fysch if gender==1 & resid==1 [aw=weight]

foreach var of varlist married edu enrollment hukou ethn femploy14 fparty {
	dis _newline(2) as text "variable=`var'" _newline(1)
	tab `var' reform if gender==1 & resid==1 [aw=weight], col
	}


//rural male
tabstat age fysch if gender==1 & resid==0 [aw=weight], by(reform) stat(mean sd count)
bysort reform: sum age fysch if gender==1 & resid==0 [aw=weight]

foreach var of varlist married edu enrollment hukou ethn femploy14 fparty {
	dis _newline(2) as text "variable=`var'" _newline(1)
	tab `var' reform if gender==1 & resid==0 [aw=weight], col
	}


//urban female
tabstat age fysch if gender==0 & resid==1 [aw=weight], by(reform) stat(mean sd count)
bysort reform: sum age fysch if gender==0 & resid==1 [aw=weight]

foreach var of varlist married edu enrollment hukou ethn femploy14 fparty {
	dis _newline(2) as text "variable=`var'" _newline(1)
	tab `var' reform if gender==0 & resid==1 [aw=weight], col
	}


//rural female
tabstat age fysch if gender==0 & resid==0 [aw=weight], by(reform) stat(mean sd count)
bysort reform: sum age fysch if gender==0 & resid==0 [aw=weight]

foreach var of varlist married edu enrollment hukou ethn femploy14 fparty {
	dis _newline(2) as text "variable=`var'" _newline(1)
	tab `var' reform if gender==0 & resid==0 [aw=weight], col
	}



****************************Kaplan-Meier Survival Curves************************

use "Thesis Datasets",clear

drop if age<15

replace weight=WEIGHT if year==2010

gen anasample2= (age!=.) &(married!=.) &(gender!=.) &(hukou!=.) &(resid!=.) &(edu!=.) &(enrollment!=.) &(ethn!=.) &(femploy14!=.) &(fysch!=.) &(reform!=.) &(fparty!=.) &(weight!=.)

drop if anasample2==0

keep age married gender hukou resid edu enrollment ethn femploy14 fysch fparty reform weight anasample2 region

gen id = _n

stset age [pw=weight], id(id) failure(married)

//pre vs. early vs. late & urban vs. rural & male vs. female 
#delimit ;
sts graph if gender==1 & resid==1 & reform==1 & anasample2==1, by(edu) title("Pre-reform Urban Men",size(huge) color(black)) graphregion(color(white))
	xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) noorigin tmax(40) xscale(lw(medthick))
	ytitle(Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
	legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))	 
	plot1 (lc(black) connect(direct) lp (vshortdash) lw(medthick)) plot2 (lc(black) connect(direct) lp (dash) lw(medthick)) 
	plot3 (lc(black) connect(direct) lp (longdash) lw(medthick)) plot4 (lc(black) connect(direct) lp (solid) lw(medthick))
;

graph save Graph "a.gph",replace

#delimit ;
sts graph if gender==1 & resid==1 & reform==2 & anasample2==1, by(edu) title("Early-reform Urban Men",size(huge) color(black)) graphregion(color(white))
	xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) noorigin tmax(40) xscale(lw(medthick))
	ytitle(Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
	legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))	 
	plot1 (lc(black) connect(direct) lp (vshortdash) lw(medthick)) plot2 (lc(black) connect(direct) lp (dash) lw(medthick)) 
	plot3 (lc(black) connect(direct) lp (longdash) lw(medthick)) plot4 (lc(black) connect(direct) lp (solid) lw(medthick))
;

graph save Graph "b.gph",replace

#delimit ;
sts graph if gender==1 & resid==1 & reform==3 & anasample2==1, by(edu) title("Late-reform Urban Men",size(huge) color(black)) graphregion(color(white))
	xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) noorigin tmax(40) xscale(lw(medthick))
	ytitle(Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
	legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))	 
	plot1 (lc(black) connect(direct) lp (vshortdash) lw(medthick)) plot2 (lc(black) connect(direct) lp (dash) lw(medthick)) 
	plot3 (lc(black) connect(direct) lp (longdash) lw(medthick)) plot4 (lc(black) connect(direct) lp (solid) lw(medthick))
;

graph save Graph "c.gph",replace

#delimit ;
sts graph if gender==1 & resid==0 & reform==1 & anasample2==1, by(edu) title("Pre-reform Rural Men",size(huge) color(black)) graphregion(color(white))
	xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) noorigin tmax(40) xscale(lw(medthick))
	ytitle(Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
	legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))	 
	plot1 (lc(black) connect(direct) lp (vshortdash) lw(medthick)) plot2 (lc(black) connect(direct) lp (dash) lw(medthick)) 
	plot3 (lc(black) connect(direct) lp (longdash) lw(medthick)) plot4 (lc(black) connect(direct) lp (solid) lw(medthick))
;

graph save Graph "d.gph",replace

#delimit ;
sts graph if gender==1 & resid==0 & reform==2 & anasample2==1, by(edu) title("Early-reform Rural Men",size(huge) color(black)) graphregion(color(white))
	xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) noorigin tmax(40) xscale(lw(medthick))
	ytitle(Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
	legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))	 
	plot1 (lc(black) connect(direct) lp (vshortdash) lw(medthick)) plot2 (lc(black) connect(direct) lp (dash) lw(medthick)) 
	plot3 (lc(black) connect(direct) lp (longdash) lw(medthick)) plot4 (lc(black) connect(direct) lp (solid) lw(medthick))
;

graph save Graph "e.gph",replace

#delimit ;
sts graph if gender==1 & resid==0  & reform==3 & anasample2==1, by(edu) title("Late-reform Rural Men",size(huge) color(black)) graphregion(color(white))
	xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) noorigin tmax(40) xscale(lw(medthick))
	ytitle(Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
	legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))	 
	plot1 (lc(black) connect(direct) lp (vshortdash) lw(medthick)) plot2 (lc(black) connect(direct) lp (dash) lw(medthick)) 
	plot3 (lc(black) connect(direct) lp (longdash) lw(medthick)) plot4 (lc(black) connect(direct) lp (solid) lw(medthick))
;

graph save Graph "f.gph",replace

#delimit ;
sts graph if gender==0 & resid==1 & reform==1 & anasample2==1, by(edu) title("Pre-reform Urban Women",size(huge) color(black)) graphregion(color(white))
	xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) noorigin tmax(40) xscale(lw(medthick))
	ytitle(Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
	legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))	 
	plot1 (lc(black) connect(direct) lp (vshortdash) lw(medthick)) plot2 (lc(black) connect(direct) lp (dash) lw(medthick)) 
	plot3 (lc(black) connect(direct) lp (longdash) lw(medthick)) plot4 (lc(black) connect(direct) lp (solid) lw(medthick))
;

graph save Graph "g.gph",replace

#delimit ;
sts graph if gender==0 & resid==1 & reform==2 & anasample2==1, by(edu) title("Early-reform Urban Women",size(huge) color(black)) graphregion(color(white))
	xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) noorigin tmax(40) xscale(lw(medthick))
	ytitle(Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
	legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))	 
	plot1 (lc(black) connect(direct) lp (vshortdash) lw(medthick)) plot2 (lc(black) connect(direct) lp (dash) lw(medthick)) 
	plot3 (lc(black) connect(direct) lp (longdash) lw(medthick)) plot4 (lc(black) connect(direct) lp (solid) lw(medthick))
;

graph save Graph "h.gph",replace

#delimit ;
sts graph if gender==0 & resid==1 & reform==3 & anasample2==1, by(edu) title("Late-reform Urban Women",size(huge) color(black)) graphregion(color(white))
	xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) noorigin tmax(40) xscale(lw(medthick))
	ytitle(Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
	legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))	 
	plot1 (lc(black) connect(direct) lp (vshortdash) lw(medthick)) plot2 (lc(black) connect(direct) lp (dash) lw(medthick)) 
	plot3 (lc(black) connect(direct) lp (longdash) lw(medthick)) plot4 (lc(black) connect(direct) lp (solid) lw(medthick))
;

graph save Graph "i.gph",replace

#delimit ;
sts graph if gender==0 & resid==0 & reform==1 & anasample2==1, by(edu) title("Pre-reform Rural Women",size(huge) color(black)) graphregion(color(white))
	xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) noorigin tmax(40) xscale(lw(medthick))
	ytitle(Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
	legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))	 
	plot1 (lc(black) connect(direct) lp (vshortdash) lw(medthick)) plot2 (lc(black) connect(direct) lp (dash) lw(medthick)) 
	plot3 (lc(black) connect(direct) lp (longdash) lw(medthick)) 
;

graph save Graph "j.gph",replace

#delimit ;
sts graph if gender==0 & resid==0  & reform==2 & anasample2==1, by(edu) title("Early-reform Rural Women",size(huge) color(black)) graphregion(color(white))
	xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) noorigin tmax(40) xscale(lw(medthick))
	ytitle(Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
	legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))	 
	plot1 (lc(black) connect(direct) lp (vshortdash) lw(medthick)) plot2 (lc(black) connect(direct) lp (dash) lw(medthick)) 
	plot3 (lc(black) connect(direct) lp (longdash) lw(medthick)) plot4 (lc(black) connect(direct) lp (solid) lw(medthick))
;

graph save Graph "k.gph",replace

#delimit ;
sts graph if gender==0 & resid==0 & reform==3 & anasample2==1, by(edu) title("Late-reform Rural Women",size(huge) color(black)) graphregion(color(white))
	xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) noorigin tmax(40) xscale(lw(medthick))
	ytitle(Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
	legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))	 
	plot1 (lc(black) connect(direct) lp (vshortdash) lw(medthick)) plot2 (lc(black) connect(direct) lp (dash) lw(medthick)) 
	plot3 (lc(black) connect(direct) lp (longdash) lw(medthick)) plot4 (lc(black) connect(direct) lp (solid) lw(medthick))
;

graph save Graph "l.gph",replace

gr combine "a.gph" "b.gph" "c.gph" "d.gph" "e.gph" "f.gph", col(3) ysize(6) xsize(12) graphregion(color(white)) iscale(*0.8)
graph save Graph "cohort_residence_men.gph",replace

gr combine "g.gph" "h.gph" "i.gph" "j.gph" "k.gph" "l.gph", col(3) ysize(6) xsize(12) graphregion(color(white)) iscale(*0.8)
graph save Graph "cohort_residence_women.gph",replace


****************************************discrete-time logit regression********************************************************************************************************

use "Thesis Datasets",clear

drop if age<15

replace weight=WEIGHT if year==2010

gen anasample2= (age!=.) &(married!=.) &(gender!=.) &(hukou!=.) &(resid!=.) &(edu!=.) &(enrollment!=.) &(ethn!=.) &(femploy14!=.) &(fysch!=.) &(reform!=.) &(fparty!=.) &(weight!=.)

drop if anasample2==0

keep age married gender hukou resid edu enrollment ethn femploy14 fysch fparty reform weight anasample2 region

gen id = _n

stset age, id(id) failure(married)


//Age spline function

stsplit tt, at(15(1)90)

gen expo = _t - _t0
tabstat _d expo, stats(sum) by (tt)


mkspline m1 22 m2 26 m3 31 m4 = tt

mkspline w1 20 w2 26 w3 31 w4 = tt

*We obtain chi-square test statistics from such nested models for the null hypothesis that a particular variable
*has the same effect on marriage entry across the three cohorts

//pre-reform urban male
logit _d m1-m4 i.edu i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==1 & reform==1 [pw=weight]
outreg2 using "logit.xls", replace dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (pre-reform urban male) label

//early-reform urban male
quietly logit _d m1-m4 i.edu i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==1 & reform==2 [pw=weight]
outreg2 using "logit.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (early-reform urban male) label

//late-reform urban male
quietly logit _d m1-m4 i.edu i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==1 & reform==3
outreg2 using "logit.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (late-reform urban male) label

//pre-reform rural male
quietly logit _d m1-m4 i.edu i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==0 & reform==1 [pw=weight]
outreg2 using "logit.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (pre-reform rural male) label

//early-reform rural male
quietly logit _d m1-m4 i.edu i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==0 & reform==2 [pw=weight]
outreg2 using "logit.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (early-reform rural male) label

//late-reform rural male
quietly logit _d m1-m4 i.edu i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==0 & reform==3 [pw=weight]
outreg2 using "logit.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (late-reform rural male) label


//pre-reform urban female
quietly logit _d w1-w4 i.edu i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==0 & resid==1 & reform==1 [pw=weight]
outreg2 using "logit.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (pre-reform urban female) label

//early-reform urban female
quietly logit _d w1-w4 i.edu i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==0 & resid==1 & reform==2 [pw=weight]
outreg2 using "logit.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (early-reform urban female) label

//late-reform urban female
quietly logit _d w1-w4 i.edu i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==0 & resid==1 & reform==3 [pw=weight]
outreg2 using "logit.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (late-reform urban female) label

//pre-reform rural female
quietly logit _d w1-w4 i.edu i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==0 & resid==0 & reform==1 [pw=weight]
outreg2 using "logit.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (pre-reform rural female) label

//early-reform rural female
quietly logit _d w1-w4 i.edu i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==0 & resid==0 & reform==2 [pw=weight]
outreg2 using "logit.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (early-reform rural female) label

//late-reform rural female
quietly logit _d w1-w4 i.edu i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==0 & resid==0 & reform==3 [pw=weight]
outreg2 using "logit.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (late-reform rural female) label



/*
//Chi2

//pre-reform urban male
logit _d m1-m4 if gender==1 & resid==1 & reform==1
gen pum1=_b[m1] if gender==1 & resid==1 & reform==1
predict pum1 if gender==1 & resid==1 & reform==1

//early-reform urban male
logit _d m1-m4 if gender==1 & resid==1 & reform==2
gen eum1=_b[m1] if gender==1 & resid==1 & reform==2
predict eum1 if gender==1 & resid==1 & reform==2

//late-reform urban male
logit _d m1-m4 if gender==1 & resid==1 & reform==3
gen lum1=_b[m1] if gender==1 & resid==1 & reform==3
predict lum1 if gender==1 & resid==1 & reform==3


egen um1 = rowmax(pum1 eum1 lum1)
tab um1 reform,chi2


/pre-reform urban male
logit _d m1-m4 i.edu i.enrollment i.hukou i.hukouchange fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==1 & reform==1

//early-reform urban male
logit _d m1-m4 i.edu i.enrollment i.hukou i.hukouchange fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==1 & reform==2

//late-reform urban male
logit _d m1-m4 i.edu i.enrollment i.hukou i.hukouchange fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==1 & reform==3

*/

******************discrete-time logit regression with interactions********************************************************************************************************

//1 pre-reform urban male
quietly logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==1 & reform==1 [pw=weight]
outreg2 using "logit2.xls", replace dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (pre-reform urban male) label

//2 early-reform urban male
quietly logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==1 & reform==2 [pw=weight]
outreg2 using "logit2.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (early-reform urban male) label

//3 late-reform urban male
quietly logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==1 & reform==3 [pw=weight]
outreg2 using "logit2.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (late-reform urban male) label

//4 pre-reform rural male
quietly logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==0 & reform==1 [pw=weight]
outreg2 using "logit2.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (pre-reform rural male) label

//5 early-reform rural male
quietly logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==0 & reform==2 [pw=weight]
outreg2 using "logit2.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (early-reform rural male) label

//6 late-reform rural male
quietly logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==0 & reform==3 [pw=weight]
outreg2 using "logit2.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (late-reform rural male) label

//7 pre-reform urban female
quietly logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==0 & resid==1 & reform==1 [pw=weight]
outreg2 using "logit2.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (pre-reform urban female) label

//8 early-reform urban female
quietly logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==0 & resid==1 & reform==2 [pw=weight]
outreg2 using "logit2.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (early-reform urban female) label

//9 late-reform urban female
quietly logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==0 & resid==1 & reform==3 [pw=weight]
outreg2 using "logit2.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (late-reform urban female) label

//10 pre-reform rural female
quietly logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==0 & resid==0 & reform==1 [pw=weight]
outreg2 using "logit2.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (pre-reform rural female) label

//11 early-reform rural female
quietly logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==0 & resid==0 & reform==2 [pw=weight]
outreg2 using "logit2.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (early-reform rural female) label

//12 late-reform rural female
logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==0 & resid==0 & reform==3 [pw=weight]
outreg2 using "logit2.xls", append dec(3) alpha(0.05, 0.10) symbol(*, +) ctitle (late-reform rural female) label


*****************************predicted survival probability***************************************************************************************************************
//pre-reform urban male
logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==1 & reform==1 [pw=weight]

margins edu, at(enrollment=0 hukou=1 (mean)fysch femploy14=0 fparty=0 ethn=0) gen(pre1)

bysort id (id): gen spre11 = exp(sum(ln(1-pre11))) if gender==1 & resid==1 & reform==1
bysort id (id): gen spre12 = exp(sum(ln(1-pre12))) if gender==1 & resid==1 & reform==1
bysort id (id): gen spre13 = exp(sum(ln(1-pre13))) if gender==1 & resid==1 & reform==1
bysort id (id): gen spre14 = exp(sum(ln(1-pre14))) if gender==1 & resid==1 & reform==1


#delimit ;
twoway (line spre11 age if age<41,sort lcolor(black) lwidth(medthick) lpattern(vshortdash)) 
	   (line spre12 age if age<41,sort lcolor(black) lwidth(medthick) lpattern(dash))
	   (line spre13 age if age<41,sort lcolor(black) lwidth(medthick) lpattern(longdash))
	   (line spre14 age if age<41,sort lcolor(black) lwidth(medthick) lpattern(solid)), 
title("Pre-reform Urban Men",size(huge) color(black)) graphregion(color(white))
xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) xscale(lw(medthick))
ytitle(Predicted Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	   ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))
;
graph save Graph "1.gph",replace


//early-reform urban male
logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==1 & reform==2 [pw=weight]

margins edu, at(enrollment=0 hukou=1 (mean)fysch femploy14=0 fparty=0 ethn=0) gen(ear1)

bysort id (id): gen sear11 = exp(sum(ln(1-ear11))) if gender==1 & resid==1 & reform==2
bysort id (id): gen sear12 = exp(sum(ln(1-ear12))) if gender==1 & resid==1 & reform==2
bysort id (id): gen sear13 = exp(sum(ln(1-ear13))) if gender==1 & resid==1 & reform==2
bysort id (id): gen sear14 = exp(sum(ln(1-ear14))) if gender==1 & resid==1 & reform==2

#delimit ;
twoway (line sear11 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(vshortdash)) 
	   (line sear12 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(dash))
	   (line sear13 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(longdash))
	   (line sear14 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(solid)), 
title("Early-reform Urban Men",size(huge) color(black)) graphregion(color(white))
xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) xscale(lw(medthick))
ytitle(Predicted Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	   ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))
;
graph save Graph "2.gph",replace


//late-reform urban male
logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==1 & reform==3 [pw=weight]

margins edu, at(enrollment=0 hukou=1 (mean)fysch femploy14=0 fparty=0 ethn=0) gen(lat1)

/*
margins edu, at(enrollment=0 hukou=1 (mean)fysch femploy14=0 fparty=0 ethn=0)
marginsplot
*/

bysort id (id): gen slat11 = exp(sum(ln(1-lat11))) if gender==1 & resid==1 & reform==3
bysort id (id): gen slat12 = exp(sum(ln(1-lat12))) if gender==1 & resid==1 & reform==3
bysort id (id): gen slat13 = exp(sum(ln(1-lat13))) if gender==1 & resid==1 & reform==3
bysort id (id): gen slat14 = exp(sum(ln(1-lat14))) if gender==1 & resid==1 & reform==3

#delimit ;
twoway (line slat11 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(vshortdash)) 
	   (line slat12 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(dash))
	   (line slat13 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(longdash))
	   (line slat14 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(solid)), 
title("Late-reform Urban Men",size(huge) color(black)) graphregion(color(white))
xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) xscale(lw(medthick))
ytitle(Predicted Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	   ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))
;
graph save Graph "3.gph",replace


//pre-reform rural male
logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==0 & reform==1 [pw=weight]

margins edu, at(enrollment=0 hukou=1 (mean)fysch femploy14=0 fparty=0 ethn=0) gen(pre2)

bysort id (id): gen spre21 = exp(sum(ln(1-pre21))) if gender==1 & resid==0 & reform==1
bysort id (id): gen spre22 = exp(sum(ln(1-pre22))) if gender==1 & resid==0 & reform==1
bysort id (id): gen spre23 = exp(sum(ln(1-pre23))) if gender==1 & resid==0 & reform==1
bysort id (id): gen spre24 = exp(sum(ln(1-pre24))) if gender==1 & resid==0 & reform==1

#delimit ;
twoway (line spre21 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(vshortdash)) 
	   (line spre22 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(dash))
	   (line spre23 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(longdash))
	   (line spre24 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(solid)), 
title("Pre-reform Rural Men",size(huge) color(black)) graphregion(color(white))
xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) xscale(lw(medthick))
ytitle(Predicted Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	   ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))
;
graph save Graph "4.gph",replace


//early-reform rural male
logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==0 & reform==2 [pw=weight]

margins edu, at(enrollment=0 hukou=1 (mean)fysch femploy14=0 fparty=0 ethn=0) gen(ear2)

bysort id (id): gen sear21 = exp(sum(ln(1-ear21))) if gender==1 & resid==0 & reform==2
bysort id (id): gen sear22 = exp(sum(ln(1-ear22))) if gender==1 & resid==0 & reform==2
bysort id (id): gen sear23 = exp(sum(ln(1-ear23))) if gender==1 & resid==0 & reform==2
bysort id (id): gen sear24 = exp(sum(ln(1-ear24))) if gender==1 & resid==0 & reform==2

#delimit ;
twoway (line sear21 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(vshortdash)) 
	   (line sear22 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(dash))
	   (line sear23 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(longdash))
	   (line sear24 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(solid)), 
title("Early-reform Rural Men",size(huge) color(black)) graphregion(color(white))
xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) xscale(lw(medthick))
ytitle(Predicted Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	   ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))
;
graph save Graph "5.gph",replace


//late-reform rural male
logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==1 & resid==0 & reform==3 [pw=weight]

margins edu, at(enrollment=0 hukou=1 (mean)fysch femploy14=0 fparty=0 ethn=0) gen(lat2)

bysort id (id): gen slat21 = exp(sum(ln(1-lat21))) if gender==1 & resid==0 & reform==3
bysort id (id): gen slat22 = exp(sum(ln(1-lat22))) if gender==1 & resid==0 & reform==3
bysort id (id): gen slat23 = exp(sum(ln(1-lat23))) if gender==1 & resid==0 & reform==3
bysort id (id): gen slat24 = exp(sum(ln(1-lat24))) if gender==1 & resid==0 & reform==3


#delimit ;
twoway (line slat21 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(vshortdash)) 
	   (line slat22 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(dash))
	   (line slat23 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(longdash))
	   (line slat24 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(solid)), 
title("Late-reform Rural Men",size(huge) color(black)) graphregion(color(white))
xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) xscale(lw(medthick))
ytitle(Predicted Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	   ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))
;
graph save Graph "6.gph",replace



//pre-reform urban female
logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==0 & resid==1 & reform==1 [pw=weight]

margins edu, at(enrollment=0 hukou=1 (mean)fysch femploy14=0 fparty=0 ethn=0) gen(pre3)

bysort id (id): gen spre31 = exp(sum(ln(1-pre31))) if gender==0 & resid==1 & reform==1
bysort id (id): gen spre32 = exp(sum(ln(1-pre32))) if gender==0 & resid==1 & reform==1
bysort id (id): gen spre33 = exp(sum(ln(1-pre33))) if gender==0 & resid==1 & reform==1
bysort id (id): gen spre34 = exp(sum(ln(1-pre34))) if gender==0 & resid==1 & reform==1


#delimit ;
twoway (line spre31 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(vshortdash)) 
	   (line spre32 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(dash))
	   (line spre33 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(longdash))
	   (line spre34 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(solid)), 
title("Pre-reform Urban Women",size(huge) color(black)) graphregion(color(white))
xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) xscale(lw(medthick))
ytitle(Predicted Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	   ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))
;
graph save Graph "7.gph",replace


//early-reform urban female
logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==0 & resid==1 & reform==2 [pw=weight]


margins edu, at(enrollment=0 hukou=1 (mean)fysch femploy14=0 fparty=0 ethn=0) gen(ear3)

bysort id (id): gen sear31 = exp(sum(ln(1-ear31))) if gender==0 & resid==1 & reform==2
bysort id (id): gen sear32 = exp(sum(ln(1-ear32))) if gender==0 & resid==1 & reform==2
bysort id (id): gen sear33 = exp(sum(ln(1-ear33))) if gender==0 & resid==1 & reform==2
bysort id (id): gen sear34 = exp(sum(ln(1-ear34))) if gender==0 & resid==1 & reform==2


#delimit ;
twoway (line sear31 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(vshortdash)) 
	   (line sear32 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(dash))
	   (line sear33 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(longdash))
	   (line sear34 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(solid)), 
title("Early-reform Urban Women",size(huge) color(black)) graphregion(color(white))
xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) xscale(lw(medthick))
ytitle(Predicted Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	   ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))
;
graph save Graph "8.gph",replace


//late-reform urban female
logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==0 & resid==1 & reform==3 [pw=weight]

margins edu, at(enrollment=0 hukou=1 (mean)fysch femploy14=0 fparty=0 ethn=0) gen(lat3)

bysort id (id): gen slat31 = exp(sum(ln(1-lat31))) if gender==0 & resid==1 & reform==3
bysort id (id): gen slat32 = exp(sum(ln(1-lat32))) if gender==0 & resid==1 & reform==3
bysort id (id): gen slat33 = exp(sum(ln(1-lat33))) if gender==0 & resid==1 & reform==3
bysort id (id): gen slat34 = exp(sum(ln(1-lat34))) if gender==0 & resid==1 & reform==3

#delimit ;
twoway (line slat31 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(vshortdash)) 
	   (line slat32 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(dash))
	   (line slat33 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(longdash))
	   (line slat34 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(solid)), 
title("Late-reform Urban Women",size(huge) color(black)) graphregion(color(white))
xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) xscale(lw(medthick))
ytitle(Predicted Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	   ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))
;
graph save Graph "9.gph",replace



//pre-reform rural female
logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==0 & resid==0 & reform==1 [pw=weight]

margins edu, at(enrollment=0 hukou=1 (mean)fysch femploy14=0 fparty=0 ethn=0) gen(pre4)

bysort id (id): gen spre41 = exp(sum(ln(1-pre41))) if gender==0 & resid==0 & reform==1
bysort id (id): gen spre42 = exp(sum(ln(1-pre42))) if gender==0 & resid==0 & reform==1
bysort id (id): gen spre43 = exp(sum(ln(1-pre43))) if gender==0 & resid==0 & reform==1

gen spre44=.

#delimit ;
twoway (line spre41 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(vshortdash)) 
	   (line spre42 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(dash))
	   (line spre43 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(longdash))
	   (line spre44 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(solid)),
title("Pre-reform Rural Women",size(huge) color(black)) graphregion(color(white))
xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) xscale(lw(medthick))
ytitle(Predicted Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	   ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))
;
graph save Graph "10.gph",replace



//early-reform rural female
logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==0 & resid==0 & reform==2 [pw=weight]

margins edu, at(enrollment=0 hukou=1 (mean)fysch femploy14=0 fparty=0 ethn=0) gen(ear4)

bysort id (id): gen sear41 = exp(sum(ln(1-ear41))) if gender==0 & resid==0 & reform==2
bysort id (id): gen sear42 = exp(sum(ln(1-ear42))) if gender==0 & resid==0 & reform==2
bysort id (id): gen sear43 = exp(sum(ln(1-ear43))) if gender==0 & resid==0 & reform==2
bysort id (id): gen sear44 = exp(sum(ln(1-ear44))) if gender==0 & resid==0 & reform==2

#delimit ;
twoway (line sear41 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(vshortdash)) 
	   (line sear42 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(dash))
	   (line sear43 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(longdash))
	   (line sear44 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(solid)), 
title("Early-reform Rural Women",size(huge) color(black)) graphregion(color(white))
xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) xscale(lw(medthick))
ytitle(Predicted Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	   ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))
;
graph save Graph "11.gph",replace


//late-reform rural female
logit _d m1-m4 c.age i.edu edu#c.age i.enrollment i.hukou fysch i.femploy14 i.fparty i.ethn if gender==0 & resid==0 & reform==3 [pw=weight]

margins edu, at(enrollment=0 hukou=1 (mean)fysch femploy14=0 fparty=0 ethn=0) gen(lat4)

/*
margins edu, at(enrollment=0 hukou=1 (mean)fysch femploy14=0 fparty=0 ethn=0)
marginsplot
*/

bysort id (id): gen slat41 = exp(sum(ln(1-lat41))) if gender==0 & resid==0 & reform==3
bysort id (id): gen slat42 = exp(sum(ln(1-lat42))) if gender==0 & resid==0 & reform==3
bysort id (id): gen slat43 = exp(sum(ln(1-lat43))) if gender==0 & resid==0 & reform==3
bysort id (id): gen slat44 = exp(sum(ln(1-lat44))) if gender==0 & resid==0 & reform==3

#delimit ;
twoway (line slat41 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(vshortdash)) 
	   (line slat42 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(dash))
	   (line slat43 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(longdash))
	   (line slat44 age if age<41, sort lcolor(black) lwidth(medthick) lpattern(solid)), 
title("Late-reform Rural Women",size(huge) color(black)) graphregion(color(white))
xtitle(Age in Years,size(medlarge) margin(vsmall)) xlab(15(5)40) xscale(lw(medthick))
ytitle(Predicted Survivor Probability,size(medlarge) margin(vsmall)) ylab(0.00(0.25)1.00, angle(horizontal)) ylabel(,nogrid) yscale(lw(medthick))
legend(label(1 "Primary School") label(2 "Middle School") label(3 "High School") label(4 "College")
	   ring(0) position(2) rows(4) xoffset(2) yoffset(-6) rowgap(minuscule) margin(zero) size(medium) color(none) region(lcolor(none) color(none)))
;
graph save Graph "12.gph",replace


gr combine "1.gph" "2.gph" "3.gph" "4.gph" "5.gph" "6.gph", col(3) ysize(6) xsize(12) graphregion(color(white)) iscale(*0.8)
graph save Graph "Predicted cohort_residence_men.gph",replace

gr combine "7.gph" "8.gph" "9.gph" "10.gph" "11.gph" "12.gph", col(3) ysize(6) xsize(12) graphregion(color(white)) iscale(*0.8)
graph save Graph "Predicted cohort_residence_women.gph",replace

*********************************Age Spline function****************************

#delimit ;
twoway (function y= -9.928 + 0.374*x, xline(21) sort(id) range(15 21))
(function y = -9.928 + 0.269*x, xline(25) sort(id) range(21 25))  
(function y = -9.928 + -0.008*x, xline(30) sort(id) range(25 30))
(function y = -9.928 + -0.190*x, sort(id) range(30 40))
;

#delimit ;
twoway (function y= -13.220 + 0.550*x, xline(21) sort(id) range(15 21))
(function y = -13.220 + 0.182*x, xline(25) sort(id) range(21 25))  
(function y = -13.220 + -0.131*x, xline(30) sort(id) range(25 30))
(function y = -13.220 + -0.185*x, sort(id) range(30 40))
;

#delimit ;
twoway (function y= -14.967 + 0.607*x, xline(21) sort(id) range(15 21))
(function y = -14.967 + 0.271*x, xline(25) sort(id) range(21 25))  
(function y = -14.967 + -0.058*x, xline(30) sort(id) range(25 30))
(function y = -14.967 + -0.418*x, sort(id) range(30 40))
;



#delimit ;
twoway (function y= -8.990 + 0.337*x, xline(21) sort(id) range(15 21))
(function y = -8.990 + 0.086*x, xline(25) sort(id) range(21 25))  
(function y = -8.990 + -0.170*x, xline(30) sort(id) range(25 30))
(function y = -8.990 + -0.179*x, sort(id) range(30 40))
;

#delimit ;
twoway (function y= -13.866 + 0.585*x, xline(21) sort(id) range(15 21))
(function y = -13.866 + -0.143*x, xline(25) sort(id) range(21 25))  
(function y = -13.866 + -0.196*x, xline(30) sort(id) range(25 30))
(function y = -13.866 + -0.138*x, sort(id) range(30 40))
;

#delimit ;
twoway (function y= -13.314 + 0.541*x, xline(21) sort(id) range(15 21))
(function y = -13.314 + 0.039*x, xline(25) sort(id) range(21 25))  
(function y = -13.314 + -0.164*x, xline(30) sort(id) range(25 30))
(function y = -13.314 + -0.294*x, sort(id) range(30 40))
;




#delimit ;
twoway (function y= -6.702 + 0.263*x, xline(21) sort(id) range(15 21))
(function y = -6.702 + 0.286*x, xline(25) sort(id) range(21 25))  
(function y = -6.702 + -0.230*x, xline(30) sort(id) range(25 30))
(function y = -6.702 + -0.166*x, sort(id) range(30 40))
;

#delimit ;
twoway (function y= -14.185 + 0.651*x, xline(21) sort(id) range(15 21))
(function y = -14.185 + 0.253*x, xline(25) sort(id) range(21 25))  
(function y = -14.185 + -0.312*x, xline(30) sort(id) range(25 30))
(function y = -14.185 + -0.212*x, sort(id) range(30 40))
;

#delimit ;
twoway (function y= -12.956 + 0.580*x, xline(21) sort(id) range(15 21))
(function y = -12.956 + 0.323*x, xline(25) sort(id) range(21 25))  
(function y = -12.956 + -0.303*x, xline(30) sort(id) range(25 30))
(function y = -12.956 + -0.096*x, sort(id) range(30 40))
;




#delimit ;
twoway (function y= 0.300*x, xline(21) sort(id) range(15 21))
(function y = 0.147*x, xline(25) sort(id) range(21 25))  
(function y = -0.286*x, xline(30) sort(id) range(25 30))
(function y = -0.085*x, sort(id) range(30 40))
;

#delimit ;
twoway (function y= -12.869 + 0.603*x, xline(21) sort(id) range(15 21))
(function y = -12.869 + 0.139*x, xline(25) sort(id) range(21 25))  
(function y = -12.869 + -0.344*x, xline(30) sort(id) range(25 30))
(function y = -12.869 + -0.109*x, sort(id) range(30 40))
;

#delimit ;
twoway (function y= -11.783 + 0.550*x, xline(21) sort(id) range(15 21))
(function y = -11.783 + 0.173*x, xline(25) sort(id) range(21 25))  
(function y = -11.783 + -0.309*x, xline(30) sort(id) range(25 30))
(function y = -11.783 + -0.148*x, sort(id) range(30 40))
;


























