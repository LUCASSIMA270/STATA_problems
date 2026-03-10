# STATA_problems

📊 STATA-problems: Econometric Analysis & Data Management
A Collection of Empirical Problem Sets from the "Learning Stata" Course

This repository contains a series of econometric and data management projects developed using Stata. These assignments focus on cleaning large-scale administrative datasets, merging multi-source information, and implementing rigorous statistical models to answer economic and social questions.
📂 Repository Overview
1️⃣ Problem Set 1.2: 2017 French Presidential Election

An analysis of the 2017 French Presidential election results at the municipal and département levels.

    Key Tasks: Data construction for registered voters and turnout across both rounds.

    Analysis: Comparison of Macron and Le Pen vote shares in the second round and calculation of turnout shifts.

    Findings: Identification of the départements with the highest support for Le Pen and calculation of national aggregate results.

2️⃣ Problem Set 2: Crime & Population Dynamics in France

This project investigates crime trends reported to the French National Police (PN) and Gendarmerie (GN) between 2012 and 2021.

    Methodology: Merging crime datasets with Insee municipality-level population data to normalize results.

    Analysis: Identification of the top 3 départements for theft-related crimes and visualization of national-level yearly series.

    ⚠️ Note on Files: Due to technical constraints, files 1 and 3 are currently missing from the Data/Temp/ folder.

3️⃣ Problem Set 3: Trust, Education, and GDP Growth

A study on the relationship between institutional trust and economic performance using global data.

    Data Sources: World Bank GDP per capita (2000–2023) and the World Values Survey (WVS) waves 6 and 7.

    Econometrics: Implementation of OLS regressions and Country Fixed Effects models to isolate the impact of trust on growth.

    Visualization: Graphing GDP evolution by quartiles of trust in institutions.

    ⚠️ Note on Sources: The raw WVS6 and WVS7 source files are not included in the repository due to their large file size [User input].

🛠️ Technical Stack

    Software: Stata (Do-files, .dta datasets, .gph graphics).

    Frameworks: High-dimensional fixed effects, linear regression, and dynamic data cleaning.

    Exports: Results exported in LaTeX (.tex) and Excel (.xls) formats for academic reporting.

📂 Directory Structure

Following the standard academic directory structure:

    Data/: Subdivided into Source/, Temp/, and Final/.

    Programs/: Numbered Do-files indicating execution order.

    Out/: Dedicated folder for saved tables and graphics.
