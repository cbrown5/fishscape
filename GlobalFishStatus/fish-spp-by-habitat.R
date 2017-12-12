#
# Various code snippets used for analysis of the RAM Legacy and Fish-Hab datatbases
#
#
# Author: 		A Broadley
# Created:      27 March 2017
# Last Updated:	25 July 2017
#
# Last update: added funtionality to create a csv and map of species at risk in major FAO areas
#
#

library("gdata")
library("rfishbase")
library("tidyr")
library("readxl")
library("dplyr")
library("ggplot2")
library("gridExtra")
library(maptools)
library(gpclib)
library(ggplot2)
library(rgdal)
library(stringr)
require(rgeos)

setwd("/Users/ab/Documents/Griffith/fish-hab-db")


#-------------------------------
# load RAM Legacy (RAML) DB into R
#
# this is the full spreadsheet version of the RAML DB
ram_db<-"RAM-Legacy-spreadsheet-snapshot-20110815.xlsx"

# this is version 3.0 (2015) of the RAML DB, containing assessment data only 
# it has a differnet table/primary/foreign key setup compared to the full RAML DB
ram_db<-"RLSADB_v3_0.xlsx"
sheets<-excel_sheets(ram_db)
n_sheets<-length(sheets)

for (i in 1:n_sheets){
    assign(sheets[i],read_excel(ram_db,sheet=sheets[i]))
}
#-------------------------------


#-------------------------------
# load fish-hab-db_v1 and priority fish stocks (PFS) xls
#
hab_db<-read.csv("fish-hab-db_v1.csv", stringsAsFactors = F)
hab_db<-read.csv("fish-hab-db_v1_no_inland.csv", stringsAsFactors = F)
#-------------------------------


#-------------------------------
# load the priority fish stocks (PFS) xls and filter hab_db to contain only PFS species
#
pfs<-read_excel("pfs.xlsx",sheet=1)

# only need hab_db to contain PFS species
hab_db<-subset(hab_db,hab_db$FishSp %in% tolower(pfs$SCIENTIFICNAME))

# check number of hab_db species against pfs species, they should be equal
# if not run the compare two lists code below
nrow(unique(hab_db[c("FishSp")]))
nrow(unique(pfs[c("SCIENTIFICNAME")]))
#-------------------------------

#-------------------------------
# compare two lists
# show t1 fields that are not in t 
t1<-unique(tolower(stocks$scientificname))
t<-unique(tolower(spts$scientificname))
t1[!t1 %in% t]
#-------------------------------

#-------------------------------
# NOTE: this section is only needed if using the complete database "RAM-Legacy-spreadsheet-snapshot-20110815.xlsx"
# in the assessment only DB "RLSADB_v3_0.xlsx" the tables are already linked 
#
# merge tables from the RAML DB based on primary keys (stockid and assessid)
# remember the merge function uses an inner join by default
#
stocks<-subset(stock,tolower(stock$scientificname) %in% hab_db$FishSp,select=c("stockid","scientificname"))
assess<-subset(assessment,stockid %in% stocks$stockid ,select=c("stockid","assessid"))
stocks<-merge(stocks,assess,by=c("stockid"))
stocks$scientificname<-tolower(stocks$scientificname)

#-------------------------------


#-------------------------------
# aggregate species by habitat for all species in the fish_hab DB not just the PFS

# need to separate Habitat into rows 
hab<-hab_db %>% separate_rows(HabitatType, sep = ";")

# need to remove leading and trailing space for some HabitatTypes
hab$HabitatType<-trimws(hab$HabitatType,"l")
hab$HabitatType<-trimws(hab$HabitatType,"r")

# remove duplicates
sum_fishhab<-unique(hab[c("FishSp","HabitatType")])

# only need these habitats
hab2<-subset(sum_fishhab,grepl("seagrass|reef|coral|macroalgae",HabitatType))

# aggregate by number of species by habitat type
a_hab2<-group_by(hab2,HabitatType) %>% summarize(count=n())

# calculate percent total of species using seagrass|reef|coral|macroalgae habitat of total species
a_hab2$perc_tot<-round(a_hab2$count/length(unique(sum_fishhab$FishSp))*100,1)
#-------------------------------


#-------------------------------
# Function to create the hab2 dataframe that stores the stockid and scientifiname for all PFS species
# by HabitatType. There is a single HabitatType per row for each stockid
# 
createhab2 <- function(){
	# only need hab_db to contain PFS species
	hab_db<-subset(hab_db,hab_db$FishSp %in% tolower(pfs$SCIENTIFICNAME))

	stocks<-subset(stock,tolower(stock$scientificname) %in% hab_db$FishSp,select=c("stockid","scientificname"))
	stocks$scientificname<-tolower(stocks$scientificname)

	# need to separate Habitat into rows 
	hab<-hab_db %>% separate_rows(HabitatType, sep = ";")

	# need to remove leading and trailing space for some HabitatTypes
	hab$HabitatType<-trimws(hab$HabitatType,"l")
	hab$HabitatType<-trimws(hab$HabitatType,"r")

	# combine RAML with FishHab
	ramlhab<-merge(stocks,hab,by.x=c("scientificname"), by.y=c("FishSp"))

	# remove duplicates and narrow columns
	sum_fishhab<-unique(ramlhab[c("scientificname","HabitatType")])

	# only need these habitats
	hab2<-subset(sum_fishhab,grepl("seagrass|reef|coral|macroalgae|mangrove",HabitatType))
}
#-------------------------------



#-------------------------------
# Proportions of HabitatType by PFS species
createhab2()

# aggregate by number of species by habitat type
a_hab2<-group_by(hab2,HabitatType) %>% summarize(count=n())

# calculate percent total of species using seagrass|reef|coral|macroalgae habitat of total species
a_hab2$perc_tot<-round(a_hab2$count/length(unique(stocks$scientificname))*100,1)
#-------------------------------


#-------------------------------
# build a barchart showing habitat types and catch for each species associated with that habitat
# 
# first, filter years and metric tons from timeseries table
# 1999 was most common amongst stocks and species, see below
# define the timeseries metric identifiers. 
# TC=Total catch, TL=Total Landings (landings includes catch + discards), MT=metric tons
# refer to tsmetrics tables for definition of other metric identifiers.
metricsTL<-c("TL-MT","TL-1-MT","TL-2-MT","TL-3-MT","TL-4-MT")
metricsTC<-c("TC-MT","TC-1-MT","TC-2-MT","TC-3-MT","TC-E00")
metric<-c(metricsTL,metricsTC)

# use hab2 here as a filter because we only need stocks with the correct HabitatType
createhab2()
stocks<-subset(stock,tolower(stock$scientificname) %in% hab2$scientificname,select=c("stockid","scientificname"))
subts<-subset(timeseries,(stockid %in% stocks$stockid) & (tsid %in% metric) & tsyear == 1999 & tsvalue != 0,select=c("stockid","assessid","tsid","tsyear","tsvalue"))


# need to add species name to timeseries, using left-outer join in merge (ie. all.x=TRUE)
spts<-merge(subts,stocks,by="stockid", all.x=TRUE)

# spts will contain multiple total landing (TL-MT) and total catch (TC-MT) metric identifiers for some stocks. 
# our preference is to use total landings identifiers first and then use other identifiers as required.
# 
# Loop through metric identifers, any records containing landings will be assigned to spcatch first, other 
# records will be assigned only if a landings record doesn't exist already
#  
temp<-data.frame()
spcatch<-data.frame()
for (i in 1:length(metric)){
    temp<-subset(spts,!stockid %in% spcatch$stockid & tsid==metric[i])
    spcatch<-rbind(spcatch,temp)  
}

# Generate metric tons for species with individual catch numbers only (TC-E00)
# conversion 1kg = 0.001 metric tons
#
# stock_weights.csv created from FishBase and literature (see FishScape supplementary document)#
weights<-read.csv("stock_weights.csv", stringsAsFactors=F)
tce<-merge(spcatch,weights,by=c("stockid","scientificname"),all.x=TRUE)
tce$tsvalue[tce$tsid=="TC-E00"] <- (tce$tsvalue[tce$tsid=="TC-E00"] * tce$weight[tce$tsid=="TC-E00"]) / 1000
tce$weight<-NULL
spcatch<-tce


# aggregate spcatch by species and sum of tsvalue
sptotcatch<-aggregate(tsvalue ~ scientificname, data = spcatch, sum)

# change case of scientificname so sptotcatch can join hab2
sptotcatch$scientificname<-tolower(sptotcatch$scientificname)
sphabcatch<-merge(hab2,sptotcatch,by.x=c("scientificname"), by.y=c("scientificname"), all.x=TRUE)

# Capitalise the first letter of HabitatType, easier to do here than in the barchart
substr(sphabcatch$HabitatType,1,1)<-toupper(substr(sphabcatch$HabitatType,1,1))

# remove species were a metric identifier couldn't be found, this will be typically shown as an NA value
sphabcatch<-sphabcatch %>% drop_na() 

# Summarise by HabitatType
habcatch<-aggregate(tsvalue ~ HabitatType, data = sphabcatch, sum)
habcatch$mt<-round(habcatch$tsvalue/1e+06,2)

# bar chart millions of tons
ggplot(habcatch,aes(x=HabitatType,y=tsvalue/1e+06)) +
geom_bar(stat="identity",fill="grey32",width=0.8) +
labs(x="Habitat Type", y="Total Catch (in millions of Tons)") +
theme_bw() + theme(axis.title.x = element_text(vjust = -1)) +
scale_y_continuous(breaks=seq(0,10,2), expand=c(0,0), limits=c(0,10))


# bar chart % of total 
ggplot(habcatch,aes(x=HabitatType,y=(tsvalue/32631297)*100 )) +
geom_bar(stat="identity",fill="grey32",width=0.8) +
labs(x="Habitat Type", y="Percent of Total Catch") +
theme_bw() + theme(axis.title.x = element_text(vjust = -1)) +
scale_y_continuous(breaks=seq(0,40,10), expand=c(0,0), limits=c(0,40))
#-------------------------------



#-------------------------------
# Need to find which year has the most data available for the maximum number of species and fish stocks.
# use the above code wrapped in loop through years. 
# the output will show the year with the most species with TL or TC in the timeseries table.

metricsTL<-c("TL-MT","TL-1-MT","TL-2-MT","TL-3-MT","TL-4-MT")
metricsTC<-c("TC-MT","TC-1-MT","TC-2-MT","TC-3-MT")
metric<-c(metricsTL,metricsTC)

stocks<-subset(stock,tolower(stock$scientificname) %in% hab2$scientificname,select=c("stockid","scientificname"))

startyear<-1960
endyear<-2016
tempsp<-0

for (year in startyear:endyear){
	subts<-subset(timeseries,(stockid %in% stocks$stockid) & (tsid %in% metric) & tsyear == year & tsvalue != 0,select=c("stockid","assessid","tsid","tsyear","tsvalue"))
	spts<-merge(subts,stocks,by="stockid", all.x=TRUE)
    temp<-data.frame()
	spcatch<-data.frame()
	for (i in 1:length(metric)){
    	temp<-subset(spts,!stockid %in% temp$stockid & tsid==metric[i])
    	spcatch<-rbind(spcatch,temp)  
	}
	nspecies<-nrow(unique(spcatch[c("scientificname")]))
	if(nspecies>=tempsp){
		tempsp<-nspecies
		print(year)
		print(tempsp)
	}
}
#-------------------------------




#-------------------------------
# Calc the total catch 
# similar to above but uses hab_db not hab2 ie. not restricted to certain habitat types.
stocks<-subset(stock,tolower(stock$scientificname) %in% hab_db$FishSp,select=c("stockid","scientificname"))
subts<-subset(timeseries,(stockid %in% stocks$stockid) & (tsid %in% metric) & tsyear == 1999 & tsvalue != 0,select=c("stockid","assessid","tsid","tsyear","tsvalue"))

spts<-merge(subts,stocks,by="stockid", all.x=TRUE)

temp<-data.frame()
spcatch<-data.frame()
for (i in 1:length(metric)){
    temp<-subset(spts,!stockid %in% temp$stockid & tsid==metric[i])
    spcatch<-rbind(spcatch,temp)  
}

weights<-read.csv("stock_weights.csv", stringsAsFactors=F)
tce<-merge(spcatch,weights,by=c("stockid","scientificname"),all.x=TRUE)
tce$tsvalue[tce$tsid=="TC-E00"] <- (tce$tsvalue[tce$tsid=="TC-E00"] * tce$weight[tce$tsid=="TC-E00"]) / 1000
tce$weight<-NULL
spcatch<-tce

spcatch<-spcatch %>% drop_na() 

sum(spcatch$tsvalue)/1e+06
#-------------------------------


#-------------------------------
# create a csv file with columns for the identifier of each FAO region, the number of RAML species using at risk habitats
# (mangroves,seagrass, coral reefs, macro-algae) in that region and the total number of RAML species in that region. 


# need to separate Habitat into rows 
hab<-hab_db %>% separate_rows(HabitatType, sep = ";")

# need to remove leading and trailing space for some HabitatTypes
hab$HabitatType<-trimws(hab$HabitatType,"l")
hab$HabitatType<-trimws(hab$HabitatType,"r")

# remove duplicates
sp_hab<-unique(hab[c("Lat","Lon","FishSp","HabitatType")])

# covert lat and long to spatial points data frame format
coordinates(sp_hab) <- ~ Lon + Lat


#fao<-readShapeSpatial("/Users/ab/Documents/Griffith/fish-hab-db/FAO_AREAS/FAO_AREAS.shp") 
#fao<-readShapePoly("/Users/ab/Documents/Griffith/fish-hab-db/FAO_AREAS/FAO_AREAS.shp") 
fao<-readOGR("/Users/ab/Documents/Griffith/fish-hab-db/FAO_AREAS/FAO_AREAS.shp",stringsAsFactors="FALSE")

# project fao onto the sp_hab to ensure they are using the same projection
proj4string(sp_hab) <- proj4string(fao)

# easier to use data with lowercase 
names(fao)<-tolower(names(fao))

# reformat the spatial data to have major areas (f_area) only 
fao.major <- gUnionCascaded(fao, id=fao@data$f_area)
#fao.major <- fao[fao@data$f_level == "MAJOR", ]

# show the value of the slot ID's
getSpPPolygonsIDSlots(fao.major) 

# get all the points contained within each of the major areas
sp.in.area<-over(fao.major,sp_hab,returnList = TRUE)

# create empty dataframe 
fao.sp.at.risk<-data.frame(FAOArea=character(),SpAtRisk=integer(),SpTotal=integer(),stringsAsFactors=FALSE)

# loop through the named list objects created by the over() function 
# and population the fao.sp.at.risk dataframe
l<-length(sp.in.area)
for (c in 1:l){
	area.name<-names(sp.in.area[c])
	temp<-data.frame(sp.in.area[c])
	colnames(temp)<-c("FishSp","HabitatType")
	
	# count of all species in an FAO area
	tot.count<-nrow(unique(temp[c("FishSp")]))
	
	# count species using at risk habitats
	at.risk<-subset(temp,grepl("seagrass|reef|coral|macroalgae",HabitatType))
	at.risk.count<-nrow(unique(at.risk[c("FishSp")]))
	fao.sp.at.risk<-rbind(fao.sp.at.risk,data.frame(FAOArea=area.name,SpAtRisk=at.risk.count,SpTotal=tot.count))
}

# output csv file
write.csv(fao.sp.at.risk,"fao_sp_at_risk.csv")

# functions used to retrieve data from named/nested list objects
#lapply(temp[1], "[", "FishSp")
#sp.in.area[[1]]$FishSp

plot(fao.major)
points(sp_hab, col = "red", pch = 16, cex = 0.5)

# ggplot version of plot
fao_regions<-readShapeSpatial("FAO_AREAS.shp") 
shape@data$id <- rownames(shape@data)
shape.fort <- fortify(shape, region='id') 
shape.fort<-shape.fort[order(shape.fort$order), ] 
ggplot(data=shape.fort, aes(long, lat, group=group)) + 
    geom_polygon(colour='black',
                 fill='white') +
    theme_bw()
#-------------------------------


		 


