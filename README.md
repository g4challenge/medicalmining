# Medical mining

## Timeline
- 26.05: db insert document (Pati) and link it with Streamgraph (Tschigo)
- 02.06: LDAvis speedup(Lukas) and link with frontend (Tschigo)

-> 02.06 finished Project, 02.06 to 14.06 Final Report

## First setup:
- Checkout the project
- start the index.html in folder eyes_lda
- R code is not well structured (and pretty useless without an R IDE <http://rstudio.com>
- visualization is very basic
- integrate the more sophisticated version from sievert (LDAviz)


## Imports

- on linux (ubuntu 14.04) apt-get install libxml2-dev libmpfr4 libmpfr-dev
- install gnu mp 
- install gnu scientific library gsl

- devtools::install_github("kshirley/LDAtools")
- devtools::install_github("cpsievert/LDAvis")
- devtools::install_github("benmarwick/LDAviz")


- install.packages("shiny")
- install.packages("shinydashboard")


- install.packages("topicmodels")
- install.packages("servr")
- install.packages("tm")
- install.packages("Rmpfr")
- install.packages("SnowballC")
- install.packages("RJSONIO")
- install.packages("RCurl")
- install.packages("XML")
- install.packages("stringr")
- install.packages("rmongodb")


Note:
	on a mac you have to install gsl (brew install gsl)

Note:
    Gitlab sometimes ... (just for online commit test...)


- devtools::install_github("hrbrmstr/streamgraph")

