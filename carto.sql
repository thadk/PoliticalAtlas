SELECT round(CAST(all20pop_s as NUMERIC),0) as all20pop_s_round,

round(CAST(rur20pop_s as NUMERIC),0) as rur20pop_s_round,

round(CAST(adu20pop_s as NUMERIC),0) as adu20pop_s_round,

TO_CHAR(all20pop_s, '9,999,999,999') as all20pop_s_round_ca,

TO_CHAR(adu20pop_s, '9,999,999,999') as adu20pop_s_round_ca,

TO_CHAR(rur20pop_s, '9,999,999,999') as rur20pop_s_round_ca,

TO_CHAR(all20pop_m, '9,999,999,999') as all20pop_mean_round_ca,

log(rurdense+0.00000001) as logrurdense,

concat(name_2, ', ', name_1, ', ',name_0) as nicename,

africareg as africaregi,

* FROM continents_levels2_afr_pop_density
