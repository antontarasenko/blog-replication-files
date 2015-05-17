clear

use input/leaderboards.dta
mkdir output

gen splitat = strpos(source, "_public_leaderboard.csv")
gen competition = substr(source, 1, splitat - 1)
encode competition, g(cid)

egen t_competition = tag(competition)
egen n_submissions_ct = count(teamid), by(competition teamid)

gen dt = clock(submissiondate, "MDYhms")
format dt %tc
lab var dt "Date and time"

gen is_desc = 1
lab var is_desc "Are scores ranked in descending order?"

gen nn_submissions_ct = -n_submissions_ct

byso competition nn_submissions_ct teamid (dt): replace is_desc = 0 if score[1] > score[_N]
byso competition (nn_submissions_ct): replace is_desc = is_desc[1]

egen last_submission_dt = max(dt), by(competition teamid)
format last_submission_dt %tc
gen remained_days = ( last_submission_dt - dt ) / 86400000
egen cut_score_remained_days = cut(remained_days), at(0(1)30) label
egen a_score_cdc = mean(score), by(competition cut_score_remained_days)
egen sd_score_cdc = sd(score), by(competition cut_score_remained_days)
egen t_cd = tag(competition cut_score_remained_days)

lab var a_score_cdc "Mean score for submissions"
lab var cut_score_remained_days "Days before the last submission"
foreach id of num 5 { // 5 10 27 32 50 {
	serrbar a_score_cdc sd_score_cdc cut_score_remained_days if t_cd & cid == `id', ///
	ti("Progress over time in competition #`id'") ///
	name(kaggle_progress_`id', replace)
	grex output/kaggle_progress_`id'
}

byso competition teamid (dt): drop if _n != _N

hist n_submissions_ct if n_submissions_ct < 15, d freq $grf ///
ti("Number of submissions per team in a competition") ///
name(kaggle_submissions_per_team, replace)
grex output/kaggle_submissions_per_team


gen sscore = .
replace sscore = -score if is_desc
replace sscore = score if !is_desc

gen place = .
byso competition (sscore): replace place = _n
byso competition (sscore): gen fraction2first = 100 * sscore / sscore[1]
lab var fraction2first "Score in % of the first place"

tw connected fraction2first place, msize(vsmall) || sc fraction2first place if n_submissions_ct > 5 || if competition == "ClaimPredictionChallenge", ///
$grf leg(on lab(1 "all participants") lab(2 "> 5 submissions")) ///
ti("Ranking in a single competition") name(kaggle_ranking, replace)
grex output/kaggle_ranking

xtset cid place

xtline fraction2first if place <= 25 & inrange(fraction2first, 95, 105), ov $grf ti("Kaggle competitions: The winner's handicap") name("kaggle_winners_handicap", replace)
grex output/kaggle_winners_handicap

hist fraction2first if inrange(fraction2first, 50, 150), $grf bin(100) ///
xline(100) text( .05 75 "higher score is better" "competitions" ) text( .05 125 "lower score is better" "competitions" ) ///
ti("Kaggle competitions: Participants by score") name(kaggle_scores_kde, replace)
grex output/kaggle_scores_kde

mer 1:m teamid using input/teams

drop if missing(cid)

egen n_userid_competition = count(userid), by(competition)
drop if n_userid_competition < 500
byso userid cid (dt): drop if _n != _N
keep place userid cid

reshape wide place, i(userid) j(cid)

foreach i of varlist place* {
	loc vname = "Place in #" + substr("`i'", 6, .)
	lab var `i' "`vname'" // "Place in competition #" // + substr("`i'", 6, .)
}

gr matrix place* , msize(vsmall) ///
ti("Kaggle competitions: Correlation between places") ///
name(kaggle_place_matrix, replace)
grex output/kaggle_place_matrix

corr place*

