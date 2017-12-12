# Stats from fishscape database
# CJ Brown 2017-11-17

rm(list = ls())

library(ggplot2)
library(dplyr)

setwd("~/Code/fishscape/")

dat <- read.csv("data-raw/fish-hab-db_v1.csv")
pdat <- read.csv("data-raw/priority-fish-stocks.csv")

#
# Filter for RAML stocks
#
ikeep <- dat$FishSp %in% tolower(pdat$SCIENTIFICNAME)
dat2 <- dat[ikeep,]

#
# Summaries
#
nrow(dat2)
table(dat2$ObsType)
length(unique(dat2$CiteKey))

#Numbers of unique habitat type observations
habstr <- paste(names(table(dat2$HabitatType)), collapse =';')
habs <- lapply(strsplit(habstr, split = ";"), trimws)
table(habs)
