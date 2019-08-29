### File Pooling Script
### Author: Sabhrina Gita Aninta
### Start Date: 08/08/2019

### Loading necessary libraries
library(xlsx)
library(dplyr)
library(plyr)
library(stringr)
library(forcats)

### Reading files

regex_xls = "xlsx|xls"
xls <- dir(path = "./input_xlsx", pattern = regex_xls, full.names = TRUE)
samplingEvent<-lapply(xls, read.xlsx, 1)
sE.df<-rbind.fill(samplingEvent)
sE.df<-sE.df[rowSums(is.na(sE.df)) != ncol(sE.df), ]
sE.df<-sE.df[colSums(!is.na(sE.df)) > 0]

occurrences<-lapply(xls, read.xlsx, 2)
occ.df<-rbind.fill(occurrences)
occ.df<-occ.df[rowSums(is.na(occ.df)) != ncol(occ.df), ]
occ.df<-occ.df[colSums(!is.na(occ.df)) > 0]

literature<-lapply(xls, read.xlsx, 3)
lit.df<-rbind.fill(literature)
lit.df<-lit.df[rowSums(is.na(lit.df)) != ncol(lit.df), ]
lit.df<-lit.df[colSums(!is.na(lit.df)) > 0]

mof<-lapply(xls, read.xlsx, 4)
mof.df<-rbind.fill(mof)
mof.df<-mof.df[rowSums(is.na(mof.df)) != ncol(mof.df), ]
mof.df<-mof.df[colSums(!is.na(mof.df)) > 0]