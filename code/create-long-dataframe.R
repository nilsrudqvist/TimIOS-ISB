library(tidyverse)
clin <- read_tsv("../data/Combined_Clinical.df.tsv")
ge <- read_tsv("../data/Combined_GE.df.tsv")
gem <- as.matrix(ge[,2:ncol(ge)]) ; rownames(gem) <- ge$Gene
## ge samples in natural numeric order, clin samples in alphanumeric sort
clin$sample <- factor(clin$sample,levels=colnames(gem))
ge.long <- gather(ge,sample,value,-Gene)
ge.long$sample <- factor(ge.long$sample,levels=colnames(gem))
df <- left_join(clin,ge.long,by="sample")
df <- df %>% mutate(log10_value=log10(value+0.01))
dataset.summary.stats <- df %>% group_by(dataset) %>% 
  summarize(median=median(log10_value,na.rm=T),mad=mad(log10_value,na.rm=T),
            mean=mean(log10_value,na.rm=T),sd=sd(log10_value,na.rm=T))
# scale by standardization
dfext <- right_join(df,dataset.summary.stats,by="dataset") %>% mutate(scaled_value=(log10_value-mean)/sd)
# scale by median only 
#dfext <- right_join(df,dataset.summary.stats,by="dataset") %>% #mutate(scaled_value=log10_value/median)
df.all <- dfext
save(df.all,file="data/df.all.RData")

