---
title: "Explore response data!"
output: 
  html_document:
    toc: yes
    toc_depth: 2
---

######################################################################
### Harmonize datasets from Auslander et al/IMPRES data repository ###
######################################################################

### Assumptions ###
# Gene data columns are ordered according to patient number
# Collected the response information for the VanAllen2015 dataset from publication: http://science.sciencemag.org/highwire/filestream/635465/field_highwire_adjunct_files/2/TableS2_Revised.xlsx
# Collected the response information for the Riaz2017 dataset from publication https://ars.els-cdn.com/content/image/1-s2.0-S0092867417311224-mmc2.xlsx 
# All data without information on when sample was taken is assumed to be pre-tx

### Questions ###
### Chen2016 dataset, both CTLA4 and PD1 treatment, and unclear to me what the response is from each patient. 

### LOAD PREQs -----------------------------------------------------------
.packages <- c("seqLogo",'nVennR', "seqLogo", 'Logolas', 'Rtsne','rSEQ', 'Peptides', 'xCell', 'reshape', 'RforProteomics', 'gplots', 'plyr', 'dplyr', 'tcR', 'popbio', 'randomForestSRC', 'cgdsr', 'matrixStats', 'corrplot', 'gdata', 'Biostrings', 'phangorn', 'ggtree', 'ggplot2', 'gridExtra', 'grid', 'treetio', 'biomaRt', 'gespeR', "divo", 'rgl', 'openxlsx',"survival", "survminer",'ggfortify', 'PerformanceAnalytics')
lapply(.packages, require, character.only = TRUE)
source("~/Dropbox/Delade mappar/SPETZrudqvist lab/R/Nils/R scripts/copy.to.clipboard.FUN.R") # load function to copy-paste dataframes, matrixes etc

### List RData objects from folder -----------------
files <- list.files("~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/", pattern = 'RData')

```{r echo=FALSE, warning=FALSE, message=F}
### Harmoinze datasets ----------------------------------------------------
## Prat2017 dataset (PMID 28487385) --------------------
load(paste("~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/", files[3], sep = "")); Prat2017 <- FELIP; rm(FELIP)

# Add dataset name to sample vector and add pt vector
Prat2017$sample <- paste("Prat2017", Prat2017$sample, sep = "_")

# Create Prat2017 clinical data.frame
Prat2017_Clinical.df <- data.frame(do.call(cbind, Prat2017[1:5]))
Prat2017_Clinical.df$sex <- do.call(rbind,(lapply(Prat2017_Clinical.df$sex, function(x) {gsub("Sex: ", "", x)})))
Prat2017_Clinical.df$drug <- do.call(rbind,(lapply(Prat2017_Clinical.df$drug, function(x) {gsub("drug: ", "", x)})))
Prat2017_Clinical.df$PFS <- do.call(rbind,(lapply(Prat2017_Clinical.df$PFS, function(x) {gsub("pfs: ", "", x)})))
Prat2017_Clinical.df$PFS <- do.call(rbind,(lapply(Prat2017_Clinical.df$PFS, function(x) {gsub("pfs: ", "", x)})))
Prat2017_Clinical.df$response <- as.character(Prat2017_Clinical.df$response)
Prat2017_Clinical.df$dataset <- as.factor('Prat2017')
Prat2017_Clinical.df$treatment <- as.factor('PD1')
Prat2017_Clinical.df$OS <- NA
Prat2017_Clinical.df$vital_status <- NA
Prat2017_Clinical.df$patient <- Prat2017_Clinical.df$sample
Prat2017_Clinical.df <- Prat2017_Clinical.df[,c('sample','patient','response','vital_status','OS','PFS','dataset','treatment')]

# Create Prat2017 GE data.frame
Prat2017_GE.df <- data.frame(Prat2017$genes, matrix(Prat2017$GE, nrow = 12951, ncol = 25))
Prat2017_GE.df[Prat2017_GE.df == 0] <- NA
names(Prat2017_GE.df) <- c('Gene', Prat2017$sample)

# Write data.frames
#write.table(x = Prat2017_Clinical.df, file = "~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/Prat2017_Clinical.tsv", sep = "\t", row.names = F)
#write.table(x = Prat2017_GE.df, file = "~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/Prat2017_GE.tsv", sep = "\t", row.names = F)
```

## Hugo2016 dataset --------------------
load(paste("~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/", files[2], sep = "")); Hugo2016 <- HUGO; rm(HUGO)

# Add dataset name to sample vector and add pt vector
Hugo2016$sample <- paste("Hugo2016", Hugo2016$sample, sep = "_")

# Create Hugo2016 clinical data.frame
Hugo2016_Clinical.df <- data.frame(do.call(cbind, Hugo2016[3:6]))
names(Hugo2016_Clinical.df) <- c('response','sample', 'vital_status', 'OS')
Hugo2016_Clinical.df$dataset <- as.factor('Hugo2016')
Hugo2016_Clinical.df$treatment <- as.factor('PD1')
Hugo2016_Clinical.df$response <- do.call(rbind,(lapply(Hugo2016_Clinical.df$response, function(x) {gsub("Complete Response", "CR", x)}))); table(Hugo2016_Clinical.df$response)
Hugo2016_Clinical.df$response <- do.call(rbind,(lapply(Hugo2016_Clinical.df$response, function(x) {gsub("Partial Response", "PR", x)}))); table(Hugo2016_Clinical.df$response)
Hugo2016_Clinical.df$response <- do.call(rbind,(lapply(Hugo2016_Clinical.df$response, function(x) {gsub("Progressive Disease", "PD", x)}))); table(Hugo2016_Clinical.df$response)
Hugo2016_Clinical.df$PFS <- NA
Hugo2016_Clinical.df$patient <- Hugo2016_Clinical.df$sample
Hugo2016_Clinical.df <- Hugo2016_Clinical.df[,c('sample','patient','response','vital_status','OS','PFS','dataset','treatment')]
summary(Hugo2016_Clinical.df)

# Create Hugo2016 GE data.frame
Hugo2016_GE.df <- data.frame(Hugo2016[2], Hugo2016[1])
names(Hugo2016_GE.df) <- c('Gene', Hugo2016$sample)

# Write data.frames
#write.table(x = Hugo2016_Clinical.df, file = "~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/Hugo2016_Clinical.tsv", sep = "\t", row.names = F)
#write.table(x = Hugo2016_GE.df, file = "~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/Hugo2016_GE.tsv", sep = "\t", row.names = F)


## TCGA dataset --------------------
load(paste("~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/", files[5], sep = "")); TCGA <- SKCM; rm(SKCM)

# Add dataset name to sample vector
TCGA$sample <- paste("TCGA", TCGA$sample, sep = "_")

# Create TCGA clinical data.frame
TCGA_Clinical.df <- data.frame(do.call(cbind, TCGA[1:3])); head(TCGA_Clinical.df)
names(TCGA_Clinical.df) <- c('sample','drug', 'response'); head(TCGA_Clinical.df)
TCGA_Clinical.df$treatment <- as.factor('CTLA4')
TCGA_Clinical.df$dataset <- as.factor('TCGA')
TCGA_Clinical.df$response <- do.call(rbind,(lapply(TCGA_Clinical.df$response, function(x) {gsub("Complete Response", "CR", x)}))); table(TCGA_Clinical.df$response)
TCGA_Clinical.df$response <- do.call(rbind,(lapply(TCGA_Clinical.df$response, function(x) {gsub("Partial Response", "PR", x)}))); table(TCGA_Clinical.df$response)
TCGA_Clinical.df$response <- do.call(rbind,(lapply(TCGA_Clinical.df$response, function(x) {gsub("Stable Disease", "SD", x)}))); table(TCGA_Clinical.df$response)
TCGA_Clinical.df$response <- do.call(rbind,(lapply(TCGA_Clinical.df$response, function(x) {gsub("Clinical Progressive Disease", "PD", x)}))); table(TCGA_Clinical.df$response)
TCGA_Clinical.df$response[!TCGA_Clinical.df$response == 'CR' & !TCGA_Clinical.df$response == 'PR' & !TCGA_Clinical.df$response == 'SD' & !TCGA_Clinical.df$response == 'PD'] <- NA
TCGA_Clinical.df$vital_status <- NA
TCGA_Clinical.df$OS <- NA
TCGA_Clinical.df$PFS <- NA
TCGA_Clinical.df$patient <- TCGA_Clinical.df$sample
TCGA_Clinical.df <- TCGA_Clinical.df[,c('sample','patient','response','vital_status','OS','PFS','dataset','treatment')]

# Create TCGA GE data.frame
TCGA_GE.df <- data.frame(TCGA$genes, matrix(TCGA$GE,nrow = 12951,ncol = 19))
names(TCGA_GE.df) <- c('Gene', TCGA$sample)

# Write data.frames
#write.table(x = TCGA_Clinical.df, file = "~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/TCGA_Clinical.tsv", sep = "\t", row.names = F)
#write.table(x = TCGA_GE.df, file = "~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/TCGA_GE.tsv", sep = "\t", row.names = F)


## Riaz2017 dataset --------------------
load(paste("~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/", files[4], sep = "")); Riaz2017 <- TIMCHAN; rm(TIMCHAN)

# Add dataset name to sample vector
Riaz2017$sample <- paste("Riaz2017", Riaz2017$sample, sep = "_")

# Create Riaz2017 clinical data.frame 
Riaz2017_Clinical.df <- data.frame(do.call(cbind, Riaz2017[c(1:2)])); head(Riaz2017_Clinical.df)
names(Riaz2017_Clinical.df) <- c('sample','patient'); head(Riaz2017_Clinical.df)
Riaz2017_tmp <- read.xls("~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/Riaz2017_response_data_from_pub.xlsx")
Riaz2017_Clinical.df <- merge(Riaz2017_Clinical.df, Riaz2017_tmp, all.x = T, by = 'patient'); rm(Riaz2017_tmp)
Riaz2017_Clinical.df$treatment <- as.factor('PD1')
Riaz2017_Clinical.df$dataset <- as.factor('Riaz2017')
Riaz2017_Clinical.df$vital_status <- ifelse(Riaz2017_Clinical.df$dead.T.alive.F == T, 'dead', 'alive')
Riaz2017_Clinical.df$PFS <- NA
Riaz2017_Clinical.df$patient <- paste("Riaz2017", Riaz2017_Clinical.df$patient, sep = "_")
Riaz2017_Clinical.df$response <- as.character(Riaz2017_Clinical.df$response)
Riaz2017_Clinical.df <- Riaz2017_Clinical.df[,c('sample','patient','response','vital_status','OS','PFS','dataset','treatment')]

# Create Riaz2017 GE data.frame
Riaz2017_GE.df <- data.frame(Riaz2017$genes, matrix(Riaz2017$GE, nrow = 12951, ncol = 118))
names(Riaz2017_GE.df) <- c('Gene', Riaz2017$sample)

# Write data.frames
#write.table(x = Riaz2017_Clinical.df, file = "~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/Riaz2017_Clinical.tsv", sep = "\t", row.names = F)
#write.table(x = Riaz2017_GE.df, file = "~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/Riaz2017_GE.tsv", sep = "\t", row.names = F)


## VanAllen2015 dataset --------------------
load(paste("~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/", files[6], sep = "")); VanAllen2015 <- VANALLEN; rm(VANALLEN)

# Edit sample names and add dataset names to samples
VanAllen2015$sample <- as.factor(do.call(rbind, strsplit(as.vector(VanAllen2015$sample), "[.]"))[,2])
VanAllen2015$sample <- do.call(rbind,(lapply(VanAllen2015$sample, function(x) {gsub("IPI_", "", x)})))
VanAllen2015$sample <- paste("VanAllen2015", VanAllen2015$sample, sep = "_")

# Create VanAllen2015 clinical data.frame
VanAllen2015_Clinical.df <- data.frame(do.call(cbind, VanAllen2015[4:6])); head(VanAllen2015_Clinical.df)
names(VanAllen2015_Clinical.df) <- c('OS', 'PFS','sample'); head(VanAllen2015_Clinical.df)
VanAllen2015_Clinical.df$treatment <- as.factor('CTLA4')
VanAllen2015_Clinical.df$dataset <- as.factor('VanAllen2015')
VanAllen2015_Clinical.df$drug <- as.factor('Ipilimumab')
VanAllen2015_tmp <- read.xls("~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/VanAllen2015_response_data_from_pub.xlsx"); VanAllen2015_tmp <- VanAllen2015_tmp[c(1,4)]; VanAllen2015_tmp$patient <- paste("VanAllen2015", VanAllen2015_tmp$patient, sep = "_")
VanAllen2015_Clinical.df <- merge(VanAllen2015_Clinical.df, VanAllen2015_tmp, all.x = T, by.x = 'sample', by.y = 'patient'); rm(VanAllen2015_tmp)
names(VanAllen2015_Clinical.df)[7] <- c('response')
VanAllen2015_Clinical.df$patient <- VanAllen2015_Clinical.df$sample
VanAllen2015_Clinical.df$vital_status <- NA
VanAllen2015_Clinical.df$response <- as.character(VanAllen2015_Clinical.df$response)
VanAllen2015_Clinical.df <- VanAllen2015_Clinical.df[,c('sample','patient','response','vital_status','OS','PFS','dataset','treatment')]
head(VanAllen2015_Clinical.df)

# Create VanAllen2015 GE data.frame
VanAllen2015_GE.df <- data.frame(VanAllen2015$genes, matrix(VanAllen2015$GE, nrow = 12951, ncol = 42))
names(VanAllen2015_GE.df) <- c('Gene', as.vector(as.character(VanAllen2015$sample)))

# Write data.frames
#write.table(x = VanAllen2015_Clinical.df, file = "~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/VanAllen2015_Clinical.tsv", sep = "\t", row.names = F)
#write.table(x = VanAllen2015_GE.df, file = "~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/VanAllen2015_GE.tsv", sep = "\t", row.names = F)


## Chen2016 dataset - NOT FINISHED --------------------
load(paste("~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/", files[1], sep = "")); Chen2016 <- WARGO; rm(WARGO)

# Add dataset name to sample vector
Chen2016$sample <- paste("Chen2016", Chen2016$sample, sep = "_")

# Create Chen2016 clinical data.frame
Chen2016_Clinical.df <- data.frame(do.call(cbind, Chen2016[3:6]))
#names(Chen2016_Clinical.df) <- c('timepoint', 'PFS','sample'); head(Chen2016_Clinical.df)

# Create Chen2016 GE data.frame
Chen2016_GE.df <- data.frame(Chen2016[1], Chen2016[2])
names(Chen2016_GE.df) <- c('Gene', Chen2016$sample)

# Write data.frames
#write.table(x = Chen2016_Clinical.df, file = "~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/Chen2016_Clinical.tsv", sep = "\t", row.names = F)
#write.table(x = Chen2016_GE.df, file = "~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/Chen2016_GE.tsv", sep = "\t", row.names = F)

### Combine datasets ------------------------------------------------------
## Clinical data ---------------
Combined_Clinical.df <- Reduce(function(x, y) merge(x, y, all=TRUE), list(Hugo2016_Clinical.df,Prat2017_Clinical.df,Riaz2017_Clinical.df,TCGA_Clinical.df,VanAllen2015_Clinical.df))
Combined_Clinical.df$timepoint <- ifelse(grepl(pattern = "_On", x = Combined_Clinical.df$sample, fixed = T), 'on', 'pre')
Combined_Clinical.df$CTLA4 <- ifelse(Combined_Clinical.df$treatment == 'CTLA4', 'yes', 'no')
Combined_Clinical.df$PD1 <- ifelse(Combined_Clinical.df$treatment == 'PD1', 'yes', 'no')
Combined_Clinical.df$objective_response <- ifelse(Combined_Clinical.df$response == 'CR' | Combined_Clinical.df$response == 'PR', 'responder', ifelse(Combined_Clinical.df$response == 'PD', 'nonresponder',NA))

## GE data ---------------
Combined_GE.df <- Reduce(function(x, y) merge(x, y, all=TRUE), list(Hugo2016_GE.df,Prat2017_GE.df,Riaz2017_GE.df,TCGA_GE.df,VanAllen2015_GE.df))

# Plot 
pdf("~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/Combined_GE.df.pdf", width = 25)
boxplot(log10(Combined_GE.df[,-1]+1)[1:100,], las=2, outline = T, medlwd = 0, outcol="white", ylab = "log10(Combined_GE.df[,-1]+1)", cex = 0.1, pars=list(par(mar=c(8,8,4,2), cex.axis = 0.5)))
dev.off()

# Write data.frames
#write.table(x = Combined_Clinical.df, file = "~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/Combined_Clinical.df.tsv", sep = "\t", row.names = F)
#write.table(x = Combined_GE.df, file = "~/Dropbox/Delade mappar/TimIOs-ISB collab/Datasets from IMPRES manuscript/Combined_GE.df.tsv", sep = "\t", row.names = F)



