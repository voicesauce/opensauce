# snack f0
f0.dat <- read.csv("~/analysis/ps_f0.csv", header = T)
items <- c("Filename", "Label", "seg_Start", "seg_End")
snack.fields <- grep("sF0*", names(f0.dat))
items <- c(items, names(f0.dat[snack.fields]))
f0 <- f0.dat[items]
rm(f0.dat, items, snack.fields)

snack_segs <- grep("sF0_mean00*", names(f0))
f0.segs <- f0[snack_segs]
cont <- cbind(f0.segs[1,], f0.segs[2,], f0.segs[3,], f0.segs[4,])
rm(snack_segs)

timeseq <- function(s){
  begin <- s$seg_Start
  end <- s$seg_End
  diff <- end - begin
  sequence <- seq(begin, end, diff/8)
  return(sequence)
}

times0 <- timeseq(f0[1,])
times1 <- timeseq(f0[2,])
times2 <- timeseq(f0[3,])
times3 <- timeseq(f0[4,])
times <- c(times0, times1, times2, times3)
rm(times0, times1, times2, times3)

plot(times, cont)