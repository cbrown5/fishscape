# Map global change in fish habitats and dependence of stocks on declinign habitats.
# CJ Brown 21 July 2017

rm(list = ls())
 setwd("C:/Documents/Code/fishscape")

library(rgdal)
library(RColorBrewer)
library(magrittr)
library(leaflet)
library(PlotTools)

# ---------------
# Load data
# ---------------
dat <- read.csv("data-raw/fishscapemap/fao_sp_at_risk.csv")
fao <- readOGR("data-raw/FAO_AREAS","FAO_AREAS")
fao_major <- subset(fao, F_LEVEL == "MAJOR") %>%
    merge(dat, by.x = "F_CODE", by.y = "FAOArea")
spdat <- read.csv("data-raw/sp_points.csv")

thisproj <- CRS("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")

#Habitat types to plot
habtypes <- c("coral", "macroalgae", "mangrove", "seagrass")

#Remove cold water coral species
fao_rm <- c(48, 58)
irow <- fao_major@data$F_CODE %in% fao_rm
fao_major@data[irow,'SpAtRisk'] <- 0
# ---------------
# Transforms
# ---------------
faoplot <- spTransform(fao_major, thisproj)
fao_major@data$perc_risk <- 100 * (fao_major@data$SpAtRisk / fao_major@data$SpTotal)
#spplot(faoplot, "SpAtRisk")

coordinates(spdat) <- ~Lon + Lat
proj4string(spdat) <- "+init=epsg:4326"
spdat2 <- spTransform(spdat, thisproj)
spdat3 <- subset(spdat2, HabitatType %in% habtypes)

# ---------------
# Plot
# ---------------
zrange <- c(-1, 101)
Purples <- RColorBrewer::brewer.pal(9,"Purples")
colfun <- colorBin(Purples, domain = zrange, bins = 5)
mycols <- colfun(fao_major@data$perc_risk)
width <- 8
ppi <- 300
asp <- 2

#png('results/global-map.png',
 #       width = width * ppi*asp, height = width*ppi, res = ppi, antialias = 'none')

pdf('results/global-map.pdf',
    width = width *asp, height = width)

par(mar = c(1,1,1,6))
plot(faoplot, col = mycols, lwd = 0.1, bg = "white")
#plot(spdat3, add = T, col = "white", bg = "black", cex = 0.6, pch = 21)
plot(spdat3, add = T, col = "black", cex = 1.1, pch = 21, bg = PlotTools::hexalpha("white", 0.5))

colbreaks <- seq(0,100, by = 20)
mycols <- colfun(seq(2.5, 97.5, by = 20))
fields::image.plot(legend.only = TRUE, zlim = zrange,
    breaks = colbreaks,
    col = mycols, legend.width = 2, smallplot = c(0.9, 0.95, 0.5, 0.82),
    axis.args =
        list(cex.axis = 1.2),
    legend.args = list(
    text = "Stocks at risk (%)",
    side = 3, line = 0.5, cex=1.2))

legend(x = 12007672, y = 9007619, legend = "Observations of \n fish habitat associations",
    pch = 1, col = "black", xpd = NA, bty = 'n', cex = 1.2)

dev.off()
