# A large-scale in silico replication project of ecological and evolutionary studies


## Transparency declaration

The authors affirms that the manuscript is an honest, accurate, and transparent account of the study being reported; that no important
aspects of the study have been omitted.

## Data, code, and materials transparency

This reporsitory contains all data and code (both in `R` and `Julia`)  used to reproduce the results reported in the following manuscript:

> Yefeng Yang, Erik van Zwet, Nikolaos Ignatiadis, Shinichi Nakagawa. A large-scale in silico replication project of ecological and evolutionary studies. 2024.

## General instructions for reproducibility

xxx


## Structure

The repository contains 5 folders:

- `data`

- `R`

- `Julia`

- `func`
 
- `figure`

  
### `data` folder

The `data` folder includes three sub-folders:

`data/main` contains raw data for reproducing the main analyses.

`data/sensitivity` containing raw data for reproducing the sensitivity analyses.

`data/model` contains model estimates from the `R` and `Julia` code for reproducing the figures reported in the main text and supplementary materials.

### `R` folder

The `R` folder includes three `.rmd` files:

`R/main.Rmd` contains the R scripts used to reproduce all results (in terms of point estimates) shown in the main text. 

`R/sensitivity.Rmd` contains the R scripts used to reproduce all results (in terms of point estimates) shown in the supplementary materials. 

`R/figure.Rmd` contains the R scripts used to reproduce all figures shown in the main text. 

`R/SI figure.Rmd` contains the R scripts used to reproduce all supplementary figures corresponding to the sensitivity analyses.

Note that the data (or, more precisely, confidence intervals) used by `R/figure.Rmd` and `R/SI figure.Rmd` are producded [`Empirikos.jl`](https://github.com/nignatiadis/Empirikos.jl), a `Julia` package implementing Dvoretzky-Kiefer-Wolfowitz F-Localization approach to compute confidence intervals for nonparametric Empirical Bayes. 


### `Function` folder

The `Function` folder includes all the custom R functions used to generate the sample figures shown in the main text.



## Licence

The files in this dataset are licensed under the Creative Commons Attribution 4.0 International License (to view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/).

## Contact

- Dr. Yefeng Yang

Evolution & Ecology Research Centre, EERC
School of Biological, Earth and Environmental Sciences, BEES
The University of New South Wales, Sydney, Australia

Email: yefeng.yang1@unsw.edu.au

- Professor Shinichi Nakagawa, PhD, FRSN

Evolution & Ecology Research Centre, EERC
School of Biological, Earth and Environmental Sciences, BEES. 
The University of New South Wales, Sydney, Australia  

Email: s.nakagawa@unsw.edu.au.  
