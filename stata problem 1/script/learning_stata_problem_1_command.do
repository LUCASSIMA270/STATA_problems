cd "C:\Users\lucas\OneDrive\Desktop\S2\Statistical software for empirical projects\learning_stata_problem_1

clear

****************************************************************************** PROBLEM SET 1.2
*******************************************************************************

import excel "Data\Source\TOUR_1.xls", sheet("Feuil1") firstrow cellrange (A4) clear

* Importation du document excel des données relatives au premier tour de l'éléction présidentielle de 2017.

collapse (sum) Inscrits Votants, by(Codedudépartement Libellédudépartement)

* Aggrégation des données en additionnant les varaibles Inscrits et Votants par Codedudépartement et Libellédudépartement. On obtient alors le nombre totals d'inscrits et de votants au premier tour de l'élection présidentielle.

rename Votants votants_first_round 
rename Inscrits inscrits_first_round

save "tour1_agg.dta"

* Renomme simplement les colonnes.

import excel "Data\Source\TOUR_2.xls", sheet("Feuil1") firstrow cellrange (A4) clear

* Importation du document excel des données relatives au second tour de l'éléction présidentielle de 2017.

collapse (sum) Inscrits Votants (sum) Voix AD, by(Codedudépartement Libellédudépartement)

* Aggrégation des données en additionnant des varaibles Inscrits et Votants ainsi que les colonnes AD et Voix représentant les votes pour Macron et Lepen lors du second tour par Codedudépartement et Libellédudépartement. On obtient alors le nombre totals d'inscrits et de votants au second tour de l'élection présidentielle.

rename Votants votants_second_round
rename Inscrits inscrits_second_round
rename AD vote_LePen
rename Voix vote_Macron

save "tour2_agg.dta"

* Renomme les colonnes. 

merge 1:1 Codedudépartement using "tour1_agg.dta"
drop _merge

* Fusion des nouvelles données du premier tour avec les nouvelles données du second tour. 

gen TauxParticipation_T1 = votants_first_round / inscrits_first_round * 100
* Génère le taux de participation du premier tour en pourcentage. 
gen TauxParticipation_T2 = votants_second_round / inscrits_second_round * 100
* Génère le taux de participation du second tour.
gen VariationParticipation = TauxParticipation_T2 - TauxParticipation_T1
* Génère le taux de variation de participation entre le second et le premier tour.
gen Part_LePen = vote_LePen / (vote_LePen + vote_Macron) * 100
* Génère le part de vote reçu pour LePen au second tour contre Macron.
gen Part_Macron = vote_Macron / (vote_LePen + vote_Macron) * 100
* Génère la part de vote reçu pour Macron au second tour contre LePen.

* a) Did the number of registered voters change between the two rounds? If yes, by how much on average ?

gen VariationInscrits = inscrits_second_round - inscrits_first_round
* Génère la variation d'inscrits entre le seconde tour et le premier tour.
sum VariationInscrits, detail
* Affiche quelques statistiques supplémentaires relatives à cette variation notamment la moyenne. 

* b)  What are the départements in which Le Pen received the 5 highest vote shares ?

sort Part_LePen
* Triage par ordre croissant des données collectées de LePen. 
list Libellédudépartement Part_LePen in -5/-1
* Et delà, elle prend les 5 scores de LePen les plus élevées 

* LePen a reçu le plus de votes en : 
* 103. |      Ardennes   49.27044% |
* 104. |  Corse-du-Sud    49.4119% |
* 105. |   Haute-Marne   49.51912% |
* 106. | Pas-de-Calais    52.0551% |
* 107. |         Aisne   52.91083% |


* c) In which département did turnout vary the most between the two round? Which are the 3 départements in which turnout varied the less ?

gen ValAbsVariationTauxParticipation = abs(VariationParticipation)
* Transformation des variation du taux de participation en valeurs absolues. 
sort ValAbsVariationTauxParticipation
* Triage par ordre croissant.
list Libellédudépartement ValAbsVariationTauxParticipation in -2/-1
* Affiche le département où la variation a le plus augmenté entre les deux tours : Martinique : 10.37504%.
list Libellédudépartement ValAbsVariationTauxParticipation in 1/3
* Affiche les trois départements où la participation a le moins varié : Saint-Pierre-et-Miquelon : 1.06081%, Haute-Saône : 1.292656% et Territoire de Belfort   1.668716%.

* d) What is the national (aggregate) result of the (second round) vote ?

gen TotalVotes = vote_LePen + vote_Macron
* Création d'une nouvelle variable regroupant le nombre total de votes entre LePen et Macron au second tour2_agg.  
egen Total_VotesNational = total(TotalVotes)
egen Total_LePenNational = total(vote_LePen)
egen Total_MacronNational = total(vote_Macron)

gen Part_LePen_National = Total_LePenNational / Total_VotesNational * 100
* Calcul de la part des votes de LePen sur le total des votes au niveau national.
gen Part_Macron_National = Total_MacronNational / Total_VotesNational * 100
* Calcul de la part des votes de LePen sur le total des votes au niveau national. 

display "Résultat national - Le Pen: " Part_LePen_National "% | Macron: " Part_Macron_National "%"
* A	ffiche avec un texte les résultats correspondants. 

* Résultat national - Le Pen: 33.90036% | Macron: 66.09964%.