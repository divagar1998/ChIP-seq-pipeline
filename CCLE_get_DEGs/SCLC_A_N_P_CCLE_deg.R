library(limma)
library(dplyr)
library(ggplot2)
library(EnhancedVolcano)



model_csv <- read.csv("~/watanabe/Divagar/CCLE_data/sclc_model.csv")
tpm_csv <- read.csv("~/watanabe/Divagar/CCLE_data/sclc_tpm.csv")

sclc_a <- c("NCIH774","LU143","DMS454","LU165","NCIH748","LU138","NCIH1688","NCIH1417","DMS53","NCIH2029","CORL95","NCIH1105","LU134A","DMS153","NCIH2196","NCIH510","NCIH1836","CORL47","NCIH1184","SCLC22H","NCIH1882","LU139","NCIH1930","COLO668","NCIH1092","NCIH1618","NCIH1876","NCIH1436","CORL88","NCIH209","NCIH528","NCIH345","DMS79","NCIH187","SHP77","NCIH69","NCIH2081","NCIH889","NCIH1963")
sclc_n <- c("CORL279","NCIH1694","LU135","CORL24","DMS273","SCLC21H","NCIH2171","NCIH446","NCIH524","NCIH82")
sclc_p <- c("NCIH2679","NCIH1450","NCIH1048","NCIH211","CORL311","NCIH526")

model_csv_subtyped <- model_csv %>%
    mutate(subtype = case_when(
        StrippedCellLineName %in% sclc_a ~ "SCLC_A",  
        StrippedCellLineName %in% sclc_n ~ "SCLC_N",
        StrippedCellLineName %in% sclc_p ~ "SCLC_P",  
        TRUE ~ NA_character_  
    ))

model_csv_subtyped <- model_csv_subtyped %>% filter(!is.na(subtype))

tpm_csv_filtered <- tpm_csv %>% filter(X %in% model_csv_subtyped$ModelID)
tpm_csv_filtered <- tpm_csv_filtered %>% rename(ModelID = X)


tpm_csv_filtered <- tpm_csv_filtered %>%
    left_join(model_csv_subtyped %>% select(ModelID, subtype, StrippedCellLineName), by = "ModelID")

gene_expr_matrix <- tpm_csv_filtered %>% select(-ModelID, -subtype, -StrippedCellLineName)
colnames(gene_expr_matrix) <- gsub("\\..*", "", colnames(gene_expr_matrix))
design <- model.matrix(~ 0 + tpm_csv_filtered$subtype)
colnames(design) <- c("SCLC_A", "SCLC_N","SCLC_P")

gene_expr_matrix_transposed <- t(gene_expr_matrix)
colnames(gene_expr_matrix_transposed) <- tpm_csv_filtered$ModelID
gene_variances <- apply(gene_expr_matrix_transposed, 1, var)
top_2000_genes <- order(gene_variances, decreasing = TRUE)[1:2000]
gene_expr_matrix_top_2000 <- gene_expr_matrix_transposed[top_2000_genes, ]
colnames(gene_expr_matrix_top_2000) <- tpm_csv_filtered$ModelID

fit1 <- lmFit(gene_expr_matrix_top_2000, design)
contr1 <- makeContrasts(SCLC_A - SCLC_N, levels = colnames(fit1$coefficients))
tmp1 <- contrasts.fit(fit1, contr1)
fit11 <- eBayes(tmp1)
top_table1 <- topTable(fit11, sort.by = "P", n = Inf)

fit2 <- lmFit(gene_expr_matrix_top_2000, design)
contr2 <- makeContrasts(SCLC_A - SCLC_P, levels = colnames(fit2$coefficients))
tmp2 <- contrasts.fit(fit2, contr2)
fit22 <- eBayes(tmp2)
top_table2 <- topTable(fit22, sort.by = "P", n = Inf)

fit3 <- lmFit(gene_expr_matrix_top_2000, design)
contr3 <- makeContrasts(SCLC_N - SCLC_P, levels = colnames(fit3$coefficients))
tmp3 <- contrasts.fit(fit3, contr3)
fit33 <- eBayes(tmp3)
top_table3 <- topTable(fit33, sort.by = "P", n = Inf)

EnhancedVolcano(top_table1,
                lab = top_table1$ID,           
                x = 'logFC',                 
                y = 'adj.P.Val',              
                pCutoff = 0.01,               
                FCcutoff = 2,                 
                pointSize = 3.0,              
                colAlpha = 0.6,               
                legendPosition = 'topright',  
                legendLabSize = 12,          
                axisLabSize = 14,            
                title = "DEGs of SCLC-A compared to SCLC-N", 
                drawConnectors = TRUE,        
                labSize = 5.0,
                max.overlaps = 20,
                subtitle = '',
                ylim = c(0, -log10(10e-20)),
                boxedLabels=TRUE,
                selectLab = c('ASCL1','EPCAM','CDH1','BCL2','MAPK13','FOXA2','DLL1','SOX1','DLL4','FOXA1','SOX2','CALCA','NEUROD1','NEUROD2','NEUROD6','CERKL','MYC','NEUROD4'),
                widthConnectors = 0.5,        
                colConnectors = "black"       
)

ggsave("sclc_a_vs_n_volcano.png", 
       plot = last_plot(),   
       width = 10,           
       height = 8,           
       dpi = 600,            
       units = "in"         
)

EnhancedVolcano(top_table2,
                lab = top_table2$ID,           
                x = 'logFC',                 
                y = 'adj.P.Val',              
                pCutoff = 0.01,               
                FCcutoff = 2,                 
                pointSize = 3.0,              
                colAlpha = 0.6,               
                legendPosition = 'topright',  
                legendLabSize = 12,           
                axisLabSize = 14,             
                title = "DEGs of SCLC-A compared to SCLC-P", 
                drawConnectors = TRUE,        
                labSize = 6.0,
                boxedLabels=TRUE,
                selectLab = c('ASCL1','BEX1','INSM1','SYP','CHGA','CHGB','DLL3','FOXA2','SOX2','DLL4','POU2F3','SOX9','ASCL2'),
                max.overlaps = 20,
                subtitle = '',
                ylim = c(0, -log10(10e-21)),
                widthConnectors = 0.5,        
                colConnectors = "black"       
)

ggsave("sclc_a_vs_p_volcano.png", 
       plot = last_plot(),   
       width = 10,           
       height = 8,           
       dpi = 600,            
       units = "in"         
)

EnhancedVolcano(top_table3,
                lab = top_table3$ID,           
                x = 'logFC',                  
                y = 'adj.P.Val',              
                pCutoff = 0.01,               
                FCcutoff = 2,                 
                pointSize = 3.0,              
                colAlpha = 0.6,               
                legendPosition = 'topright',  
                legendLabSize = 12,          
                axisLabSize = 14,             
                title = "DEGs of SCLC-N compared to SCLC-P", 
                drawConnectors = TRUE,        
                labSize = 6.0,
                max.overlaps = 20,
                boxedLabels=TRUE,
                selectLab = c('NEUROD1','CERKL','BEX1','AKT3','INSM1','SYP','NEUROD6','NEUROD2','NEUROD4','CHGA','POU2F3','BCL2','SOX9','ASCL2','EPCAM'),
                subtitle = '',
                ylim = c(0, -log10(10e-17)),
                widthConnectors = 0.5,        
                colConnectors = "black"       
)

ggsave("sclc_n_vs_p_volcano.png", 
       plot = last_plot(),   
       width = 10, 
       height = 8,                    
       dpi = 600,            
       units = "in"         
)

sclca1_genes <- top_table1[top_table1$logFC > 2 & top_table1$adj.P.Val < 0.01, ]
sclca2_genes <- top_table2[top_table2$logFC > 2 & top_table2$adj.P.Val < 0.01, ]
sclca_genes <- intersect(sclca1_genes$ID, sclca2_genes$ID)

sclcn1_genes <- top_table1[top_table1$logFC < -2 & top_table1$adj.P.Val < 0.01, ]
sclcn2_genes <- top_table3[top_table3$logFC > 2 & top_table3$adj.P.Val < 0.01, ]
sclcn_genes <- intersect(sclcn1_genes$ID, sclcn2_genes$ID)

sclcp1_genes <- top_table2[top_table2$logFC < -2 & top_table2$adj.P.Val < 0.01, ]
sclcp2_genes <- top_table3[top_table3$logFC < -2 & top_table3$adj.P.Val < 0.01, ]
sclcp_genes <- intersect(sclcp1_genes$ID, sclcp2_genes$ID)

write.table(sclca_genes, file = "sclc_a_ccle_degs.txt", row.names = FALSE, col.names = FALSE, quote = FALSE)
write.table(sclcn_genes, file = "sclc_n_ccle_degs.txt", row.names = FALSE, col.names = FALSE, quote = FALSE)
write.table(sclcp_genes, file = "sclc_p_ccle_degs.txt", row.names = FALSE, col.names = FALSE, quote = FALSE)

