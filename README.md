# Medical mining

This tool allows you to create and control topic models. It works best with LDA and lets you visualize the results using LDAvis.

## First setup:
- Checkout the project
- install all packages required
- start the shiny application by run app

## Import your data
To import your own data, all it needs is to be a list of documents.

**Minimal example**:

    data <- list("this is my example text","here i talk about the weather")
    
Edit this in the file **tmscriptFacade.R**


## Installation

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
- install.packages("rmongodb") # (only if you want to use MongoDB)


Note:
	on a mac you have to install gsl (brew install gsl)

You can also try to use the started streamgraph visualization to visualize topics along time, but this is under development.
- devtools::install_github("hrbrmstr/streamgraph")

