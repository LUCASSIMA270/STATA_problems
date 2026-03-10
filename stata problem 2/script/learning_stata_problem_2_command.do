cd "C:\Users\lucas\OneDrive\Desktop\S2\Statistical software for empirical projects\learning_stata_problem_2"

//////////////////////////////////////////////////////////////////////////////////////////
* Problem_set_2 *
//////////////////////////////////////////////////////////////////////////////////////////

clear

* Boucle pour importer les données pour chaque année de 2012 à 2020
forvalues annee = 2012(1)2020 {
	* Importation des données depuis un fichier Excel
    import excel using "Data\Sources\crime.xlsx", ///
        sheet("Services GN `annee'") firstrow clear
    
    drop if _n==1 | _n==2  // Supprimer les deux premières lignes inutiles

	* Renommage des variables
    rename Année`annee'compagniesdegenda id
    rename Départements crime
    
    local vars_string "id crime" // Variables à exclure de la conversion numérique

    * Conversion des autres variables en numériques
    foreach elt of varlist * {
        if strpos("`vars_string'", "`elt'") == 0 { 
            destring `elt', replace force
        }
    }

	* Identification des variables correspondant aux départements
    local labels ""
    foreach elt of varlist * {
        if strpos("`vars_string'", "`elt'") == 0 {
            local lab : variable label `elt'
            if "`lab'" != "" & strpos("`labels'", "`lab'") == 0 {
                local labels "`labels' `lab'"
            }
        }
    }

    * Somme des colonnes par département
    foreach lab of local labels {
        gen gn`lab' = 0
        foreach var of varlist * {
            if strpos("`vars_string'", "`var'") == 0 {
                local var_label : variable label `var'
                if "`var_label'" == "`lab'" {
                    replace gn`lab' = gn`lab' + `var'
                }
            }
        }
    }

	* Reshape des données pour avoir un format long
	reshape long gn, i(id) j(id_dep) string
	
    gen annee = `annee' // Création d'une variable année

    save "Data\temp\gn_`annee'", replace  // Sauvegarde des données temporaires
}

* Fusion des fichiers annuels GN en un seul fichier
clear
forvalues annee = 2012(1)2020{
    append using "Data\Temp\gn_`annee'"
    erase "Data\Temp\gn_`annee'.dta" // Suppression des fichiers temporaires pour économiser de l'espace
}
order id crime id_dep annee gn
save "Data\Temp\gn_crime_data", replace

* Répétition du processus pour les services de police nationale (PN)
forvalues annee = 2012(1)2020 {
    import excel using "Data\Sources\crime.xlsx", ///
        sheet("Services PN `annee'") firstrow clear
    
    drop if _n==1 | _n==2 // Suppression des premières lignes inutiles

    * Renommage des variables 
    rename Année`annee'servicesdepolice id
    rename Départements crime
    
    local vars_string "id crime" // Variables à exclure de la conversion numérique

    * Conversion des autres variables
    foreach elt of varlist * {
        if strpos("`vars_string'", "`elt'") == 0 { 
            destring `elt', replace force
        }
    }

    * Identification des variables des départements
    local labels ""
    foreach elt of varlist * {
        if strpos("`vars_string'", "`elt'") == 0 {
            local lab : variable label `elt'
            if "`lab'" != "" & strpos("`labels'", "`lab'") == 0 {
                local labels "`labels' `lab'"
            }
        }
    }

    * Somme des colonnes par département
    foreach lab of local labels {
        gen pn`lab' = 0
        foreach var of varlist * {
            if strpos("`vars_string'", "`var'") == 0 {
                local var_label : variable label `var'
                if "`var_label'" == "`lab'" {
                    replace pn`lab' = pn`lab' + `var'
                }
            }
        }
    }

    * Reshape des données pour un format long
    reshape long pn, i(id) j(id_dep) string
    
    gen annee = `annee' // Création d'une variable année

    save "Data\Temp\pn_`annee'", replace  // Sauvegarde des fichiers temporaires
}

* Fusion des fichiers annuels PN en un seul fichier
clear
forvalues annee = 2012(1)2020{
    append using "Data\temp\pn_`annee'"
    erase "Data\Temp\pn_`annee'.dta" // Suppression des fichiers temporaires pour économiser de l'espace
}
order id crime id_dep annee pn
save "Data\Temp\pn_crime_data", replace

* Nettoyage des fichiers GN et PN en gardant les colonnes nécessaires
use "Data\Temp\gn_crime_data.dta", clear
keep id crime id_dep annee gn
save "Data\Temp\gn_crime_data_cleaned.dta", replace

use "Data\Temp\pn_crime_data.dta", clear
keep id crime id_dep annee pn
save "Data\Temp\pn_crime_data_cleaned.dta", replace

* Fusion des données GN et PN
append using "Data\Temp\gn_crime_data_cleaned.dta"

* Agrégation des valeurs par id et type de crime
collapse (sum) pn gn, by(id crime)
gen somme_pn_gn = pn + gn // Création d'une variable somme des crimes GN et PN

//////////////////////////////////////////////////////////////////////////////////////////
* Question A : Identifier les crimes les plus fréquents
//////////////////////////////////////////////////////////////////////////////////////////

sort somme_pn_gn // Trier par nombre total d'infractions

* Suppression des 4 premières lignes pour exclure les crimes les moins fréquents
drop if _n <= 4 

* Affichage des crimes les plus fréquents
list crime somme_pn_gn in -/-1 

* Résultat : Trois crimes principaux recensés et leur fréquence respective.

//////////////////////////////////////////////////////////////////////////////////////////
* Question B : (Ajout des commentaires déjà effectués ci-dessus)
//////////////////////////////////////////////////////////////////////////////////////////

* Sélection des départements 43, 37, 27 et 2 autres aléatoires
keep if id_dep == "43" | id_dep == "37" | id_dep == "27" | id_dep == "50" | id_dep == "13"

* Création du graphique des séries temporelles
twoway (line somme_pn_gn annee if id_dep == "43", lcolor(blue)) ///
       (line somme_pn_gn annee if id_dep == "37", lcolor(red)) ///
       (line somme_pn_gn annee if id_dep == "27", lcolor(green)) ///
       (line somme_pn_gn annee if id_dep == "50", lcolor(orange)) ///
       (line somme_pn_gn annee if id_dep == "13", lcolor(purple)), ///
       title("Évolution des crimes liés aux vols par département") ///
       xlabel(2012(1)2020) ylabel(,angle(0)) legend(order(1 "43" 2 "37" 3 "27" 4 "50" 5 "13"))
