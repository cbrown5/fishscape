# Fish habitat Kobe plot
# CJ Brown 2017-08-15
# v2 has change in q

rm(list = ls())

library(ggplot2)
library(dplyr)

schafmodr <- function(t, yinit,Finit, r, k, q, x, a, Fmsy, which.mgmt = "bmsy"){
    y <- numeric(t)
	y[1] <- yinit
	Catch <- rep(NA, t)
	Fmort <- numeric(t)
	Fmort[1] <- Finit

	for(i in 1:(t-1)){
        if (which.mgmt == "bmsy"){
        Fmort[i+1] <- Fmort[i] * (y[i]/(a*K/2))^x #model where Bsmy is target
            } else {
         Fmort[i+1] <- Fmort[i] * (Fmsy/Fmort[i])^x #model where Fmsy is target
        }
        Catch[i] <- Fmort[i] * q[i] * y[i]
        y[i+1] <- y[i] + r[i] * y[i]*(1-(y[i]/k[i])) - Catch[i]
	}
    return(list(y = y, Fmort = Fmort, Catch = Catch))
}

#Function to specify exponential decline in a parameter to a limit
explimfun <- function(t, arate, mindec){
    initf <- exp(arate * t)
    (initf + mindec) - (initf*mindec)
}

#
# Simulations
#
K <- 3
rbase <- 0.3
qbase <- 1
Emax <- 0.4
Fmsy <- rbase/(qbase*2)
Bmsy <- K/2
MSY <- rbase*K/4
tmax <-75
a <- 1 # if this is 1 then Bmey (target biomass)= Bmsy.
x <- 0.2
Finit <- 0.2
Yinit <- Bmsy/2


rnochange <- rep(rbase, tmax)# * exp(rnorm(tmax,sd=0.5))
rdecline <- rbase * explimfun(1:tmax, -0.08, 0.5)
Fmsyr <- rdecline[tmax]/(qbase*2)
Knochange <- rep(K, tmax)
Kdecline <- K * explimfun(1:tmax, -0.08, 0.5)
BmsyK <- Kdecline[tmax]/2
qnochange <- rep(qbase, tmax)
qincrease <- qbase * explimfun(1:tmax, -0.05, 2) #q doubles
# plot(qincrease)
Fmsyq <- rbase/(qincrease[tmax]*2)

nbase_bmsy <- schafmodr(tmax, Yinit,Finit, rnochange, Knochange, qnochange, x, a, Fmsy)
nbase <- schafmodr(tmax, Yinit,Finit, rnochange, Knochange, qnochange, x, a, Fmsy, which.mgmt = "fmsy")
nrdecline_bmsy <- schafmodr(tmax, Yinit,Finit, rdecline, Knochange, qnochange, x, a, Fmsy)
nrdecline <- schafmodr(tmax, Yinit,Finit, rdecline, Knochange, qnochange, x, a, Fmsy, which.mgmt = "fmsy")
nkdecline_bmsy <- schafmodr(tmax, Yinit,Finit, rnochange, Kdecline, qnochange, x, a, Fmsy)
nkdecline <- schafmodr(tmax, Yinit,Finit, rnochange, Kdecline, qnochange, x, a, Fmsy, which.mgmt = "fmsy")

nqincrease_bmsy <- schafmodr(tmax, Yinit,Finit, rnochange, Knochange, qincrease, x, a, Fmsy)
nqincrease <- schafmodr(tmax, Yinit,Finit, rnochange, Knochange, qincrease, x, a, Fmsy, which.mgmt = "fmsy")
#
# Plot Kobe plot
#
mycols <- colorRampPalette(c("grey80", "grey10"))

xlabel <- -0.1
ylabel <- 2.15
cexlab <- 1.2
ymax <- 2

 # dev.new(width = 8, height = 15)
ppi <- 300
  png(filename = "~/Code/fishscape/GlobalFishStatus/results/kobe-plot.png", res = ppi,
      width = 6*ppi, height = 12*ppi)

par(mfrow = c(4,2), mar = c(4,5,2,1))

plot(nbase_bmsy$y/Bmsy, nbase_bmsy$Fmort/Fmsy, cex = 1, xlab = expression(B/B[MSY]), ylab = expression(F/F[MSY]),col = mycols(tmax), pch = 16, xlim = c(0, 2), ylim = c(0, ymax), xaxs = "i", yaxs = "i")
abline(h = 1, lwd = 2, col = "grey", lty = 2)
abline(v = 1, lwd = 2, col = "grey", lty = 2)
text(xlabel, ylabel, "(a)", xpd = NA, font = 2, cex = cexlab)
text(1, ylabel, expression(paste("Management targets B" [MSY],"")), xpd = NA)

plot(nbase$y/Bmsy, nbase$Fmort/Fmsy, cex = 1, xlab = expression(B/B[MSY]), ylab = expression(F/F[MSY]),col = mycols(tmax), pch = 16, xlim = c(0, 2), ylim = c(0, ymax), xaxs = "i", yaxs = "i")
abline(h = 1, lwd = 2, col = "grey", lty = 2)
abline(v = 1, lwd = 2, col = "grey", lty = 2)
text(xlabel, ylabel, "(b)", xpd = NA, font = 2, cex = cexlab)
text(1, ylabel, expression(paste("Management targets F" [MSY],"")), xpd = NA)
# arrows(nkdecline$y[70]/Bmsy, nkdecline$Fmort[70]/Fmsy, 0.3, 1, len = 0.1)

plot(nkdecline_bmsy$y/Bmsy, nkdecline_bmsy$Fmort/Fmsy, cex = 1, xlab = expression(B/B[MSY]), ylab = expression(F/F[MSY]),col = mycols(tmax), pch = 16, xlim = c(0, 2), ylim = c(0, ymax), xaxs = "i", yaxs = "i")
abline(h = 1, lwd = 2, col = "grey", lty = 2)
abline(v = 1, lwd = 2, col = "grey", lty = 2)
abline(h = 1, col = "black", lty = 3, lwd = 0.8)
abline(v = BmsyK/Bmsy, col = "black", lty = 3, lwd = 0.8)
points(nkdecline_bmsy$y/Bmsy, nkdecline_bmsy$Fmort/Fmsy, cex = 1, pch = 16, col = mycols(tmax))
text(xlabel, ylabel, "(c)", xpd = NA, font = 2, cex = cexlab)
arrows(nkdecline_bmsy$y[70]/Bmsy, nkdecline_bmsy$Fmort[70]/Fmsy, 1, 0, len = 0.1)

plot(nkdecline$y/Bmsy, nkdecline$Fmort/Fmsy, cex = 1, xlab = expression(B/B[MSY]), ylab = expression(F/F[MSY]),col = mycols(tmax), pch = 16, xlim = c(0, 2), ylim = c(0, ymax), xaxs = "i", yaxs = "i")
abline(h = 1, lwd = 2, col = "grey", lty = 2)
abline(v = 1, lwd = 2, col = "grey", lty = 2)
abline(h = 1, col = "black", lty = 3, lwd = 0.8)
abline(v = BmsyK/Bmsy, col = "black", lty = 3, lwd = 0.8)
points(nkdecline$y/Bmsy, nkdecline$Fmort/Fmsy, cex = 1,col = mycols(tmax), pch = 16)
text(xlabel, ylabel, "(d)", xpd = NA, font = 2, cex = cexlab)
# arrows(nkdecline$y[70]/Bmsy, nkdecline$Fmort[70]/Fmsy, 0.3, 1, len = 0.1)

plot(nrdecline_bmsy$y/Bmsy, nrdecline_bmsy$Fmort/Fmsy, cex = 1, xlab = expression(B/B[MSY]), ylab = expression(F/F[MSY]),col = mycols(tmax), pch = 16, xlim = c(0, 2), ylim = c(0, ymax), xaxs = "i", yaxs = "i")
abline(h = 1, lwd = 2, col = "grey", lty = 2)
abline(v = 1, lwd = 2, col = "grey", lty = 2)
abline(v = 1, col = "black", lty=3, lwd=0.8)
abline(h = Fmsyr/Fmsy, col = "black", lty=3, lwd=0.8)
points(nrdecline_bmsy$y/Bmsy, nrdecline_bmsy$Fmort/Fmsy, cex = 1,col = mycols(tmax), pch = 16)
text(xlabel, ylabel, "(e)", xpd = NA, font = 2, cex = cexlab)

plot(nrdecline$y/Bmsy, nrdecline$Fmort/Fmsy, cex = 1, xlab = expression(B/B[MSY]), ylab = expression(F/F[MSY]),col = mycols(tmax), pch = 16, xlim = c(0, 2), ylim = c(0, ymax), xaxs = "i", yaxs = "i")
abline(h = 1, lwd = 2, col = "grey", lty = 2)
abline(v = 1, lwd = 2, col = "grey", lty = 2)
abline(v = 1, col = "black", lty=3, lwd=0.8)
abline(h = Fmsyr/Fmsy, col = "black", lty=3, lwd=0.8)
points(nrdecline$y/Bmsy, nrdecline$Fmort/Fmsy, cex = 1,col = mycols(tmax), pch = 16)
text(xlabel, ylabel, "(f)", xpd = NA, font = 2, cex = cexlab)
arrows(nrdecline$y[70]/Bmsy, nrdecline$Fmort[70]/Fmsy, 0.1, 1, len = 0.1)


plot(nqincrease_bmsy$y/Bmsy, nqincrease_bmsy$Fmort/Fmsy, cex = 1, xlab = expression(B/B[MSY]), ylab = expression(F/F[MSY]),col = mycols(tmax), pch = 16, xlim = c(0, 2), ylim = c(0, ymax), xaxs = "i", yaxs = "i")
abline(h = 1, lwd = 2, col = "grey", lty = 2)
abline(v = 1, lwd = 2, col = "grey", lty = 2)
abline(v = 1, col = "black", lty=3, lwd=0.8)
abline(h = Fmsyq/Fmsy, col = "black", lty=3, lwd=0.8)
points(nqincrease_bmsy$y/Bmsy, nqincrease_bmsy$Fmort/Fmsy, cex = 1,col = mycols(tmax), pch = 16)
text(xlabel, ylabel, "(g)", xpd = NA, font = 2, cex = cexlab)

plot(nqincrease$y/Bmsy, nqincrease$Fmort/Fmsy, cex = 1, xlab = expression(B/B[MSY]), ylab = expression(F/F[MSY]),col = mycols(tmax), pch = 16, xlim = c(0, 2), ylim = c(0, ymax), xaxs = "i", yaxs = "i")
abline(h = 1, lwd = 2, col = "grey", lty = 2)
abline(v = 1, lwd = 2, col = "grey", lty = 2)
abline(v = 1, col = "black", lty=3, lwd=0.8)
abline(h = Fmsyq/Fmsy, col = "black", lty=3, lwd=0.8)
points(nqincrease$y/Bmsy, nqincrease$Fmort/Fmsy, cex = 1,col = mycols(tmax), pch = 16)
text(xlabel, ylabel, "(h)", xpd = NA, font = 2, cex = cexlab)
arrows(nqincrease$y[70]/Bmsy, nqincrease$Fmort[70]/Fmsy, 0.05, 1, len = 0.1)


 dev.off()
