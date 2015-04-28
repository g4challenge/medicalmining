# Medical mining

## First setup:
- Checkout the project
- start the index.html in folder eyes_lda
- R code is not well structured (and pretty useless without an R IDE <http://rstudio.com>
- visualization is very basic
- integrate the more sophisticated version from sievert (LDAviz)


## Imports


- devtools::install_github("kshirley/LDAtools")
- devtools::install_github("cpsievert/LDAvis")
- devtools::install_github("benmarwick/LDAviz")


- install.packages("shiny")
- install.packages("topicmodels")
- install.packages("tm")
- install.packages("Rmpfr")
- install.packages("SnowballC")
- install.packages("RJSONIO")
- install.packages("RCurl")
- install.packages("XML")
- install.packages("stringr")
- install.packages("rmongodb")

or


- install.packages(c(shiny, topicmodels, tm, Rmpfr, SnowballC, RJSONIO, RCurl, XML, stringr, rmongodb))


Note:
	on a mac you have to install gsl (brew install gsl)