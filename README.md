# A large-scale *in silico* replication project of ecological and evolutionary studies


## Transparency declaration

The authors affirms that the manuscript is an honest, accurate, and transparent account of the study being reported, and no important
aspects of the study have been omitted.

## Reproducibility declaration

This reporsitory contains all data and code that can be used to reproduce all results reported in the following manuscript:

> Yefeng Yang, Erik van Zwet, Nikolaos Ignatiadis, Shinichi Nakagawa. A large-scale in silico replication project of ecological and evolutionary studies. 2024.


## General instructions for reproducibility

We provide both the `R` code and `Julia` code. 

Firstly, we use the `R` code (see `R` folder) to fit the mixture model described in the manuscript and get the point estimate regarding the replicability reported in the manuscript.

Secondly, we use the estimates derived from the fitted mixture model (via `R`) as the input as the `Julia` code (see `Julia` folder) to reproduce the point estimates obtained in `R` and compute the 95% confidence interval. 

Thirdly, we export both the point estimate and 95% confidence interval from `Julia` and use `R` to make figures.


## Structure

The repository contains 5 folders:

- `data`

- `Julia`

- `R`

- `func`
 
- `figure`

  
### `data` folder

The `data` folder includes three sub-folders:

`data/main` contains raw data for reproducing the main analyses.

`data/sensitivity` containing raw data for reproducing the sensitivity analyses.

`data/model` contains model estimates from the `R` and `Julia` code for reproducing the figures reported in the main text and supplementary materials.


### `Julia` folder

The `Julia` folder includes give `.jl` files:

`Julia/julia_main_data.jl` contains the `Julia` scripts used to reproduce all results (in terms of both point estimates and confidence intervals) shown in the main text. 

`Julia/julia_SMD.jl` contains the `Julia` scripts used to reproduce all supplementary results related to the main dataset using standardized mean difference (SMD) as the effect size measure. 

`Julia/julia_lnRR.jl` contains the `Julia` scripts used to reproduce all supplementary results related to the main dataset using log response ratio (lnRR) as the effect size measure. 

`Julia/julia_Zr.jl` contains the `Julia` scripts used to reproduce all supplementary results related to the main dataset using Fisher's r-to-Zr (*Zr*) as the effect size measure. 

`Julia/julia_independent_datar.jl` contains the `Julia` scripts used to reproduce all supplementary results related to the independent dataset dataset (see `data/sensitivity`). 

The confidence interval is based on the Dvoretzky-Kiefer-Wolfowitz *F*-Localization approach, implemented in the `Julia` package [`Empirikos.jl`](https://github.com/nignatiadis/Empirikos.jl).

### `R` folder

The `R` folder includes three `.rmd` files:

`R/main.Rmd` contains the `R` scripts used to reproduce all results (in terms of the point estimate) shown in the main text. 

`R/sensitivity.Rmd` contains the `R` scripts used to reproduce all supplementary results (in terms of the point estimate). 

`R/figure.Rmd` contains the `R` scripts used to reproduce all figures shown in the main text. 

`R/SI figure.Rmd` contains the `R` scripts used to reproduce all supplementary figures corresponding to the sensitivity analyses.

Note that the data (or, more precisely, confidence intervals) used by `R/figure.Rmd` and `R/SI figure.Rmd` are producded via the `Julia` package [`Empirikos.jl`](https://github.com/nignatiadis/Empirikos.jl) (see the folder `Julia`). 


### `func` folder

The `func` folder includes the custom `R` functions used for model fitting and visualizations.

### `figure`

The `figure` folder includes the main figure (from `R/figure.Rmd`) and supplementary figure (from `R/SI figure.Rmd`) reported in the manuscript.


## Licence

The files in this dataset are licensed under the Creative Commons Attribution 4.0 International License (to view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/).

## General correspondence

- Dr. Yefeng Yang

Evolution & Ecology Research Centre (EERC), 
School of Biological, Earth and Environmental Sciences (BEES), 
The University of New South Wales, Sydney, Australia

Email: yefeng.yang1@unsw.edu.au

- Professor Shinichi Nakagawa, PhD

Evolution & Ecology Research Centre (EERC), 
School of Biological, Earth and Environmental Sciences (BEES), 
The University of New South Wales, Sydney, Australia 

Email: s.nakagawa@unsw.edu.au.  

## Correspondence regarding the code

- Dr. Yefeng Yang

Evolution & Ecology Research Centre (EERC), 
School of Biological, Earth and Environmental Sciences (BEES), 
The University of New South Wales, Sydney, Australia

Email: yefeng.yang1@unsw.edu.au

- Dr. Erik van Zwet

Department of Biomedical Data Sciences,
Leiden University Medical Center, Leiden, The Netherlands

Email: e.w.van_zwet@lumc.nl


- Dr. Nikolaos Ignatiadis

Department of Statistics and Data Science Institute, 
University of Chicago, Chicago, IL, USA

Email: nikos.ignatiadis01@gmail.com
