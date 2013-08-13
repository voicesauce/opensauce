ps_f0 <- read.csv("ps_f0.csv", header = TRUE)
vox_f0 <- read.csv("vox_f0.csv", header = TRUE)
items <- grep("sF0*", names(ps_f0))
f0.ps <- ps_f0[items]
f0.vox <- vox_f0[items]
f0.diff <- f0.ps - f0.vox
f0 <- rbind(diff=f0.diff, vox=f0.vox, ps=f0.ps)
print(f0.diff)