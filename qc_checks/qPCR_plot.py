import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

qpcr_samples = {
    "H209_L-MYC_ChIP_1":[0.129126589,0.056226225,0.007274005,0.004485691,0.004355233],
    "H209_L-MYC_ChIP_2":[0.005994747,0.012930892,1.35523E-06,0.001581063,0.00207448],
    "H209_L-MYC_ChIP_3":[0.017300597,0.127509679,0.050309184,0.005361921,0.004571761],
    "H209_L-MYC_ChIP_5":[np.nan,0.017181093,np.nan,0.000937724,0.000693876],
    "CORL88_L-MYC_ChIP_2":[np.nan,0.109345488,np.nan,0.002853534,0.003464747]
}

fold_enrichment_apex1_hbg2 = []
fold_enrichment_rpl35_hbg2 = []
fold_enrichment_eif2a_hbg2 = []
fold_enrichment_rcl1_hbg2 = []

for key in qpcr_samples.keys():
    fold_enrichment_apex1_hbg2.append(qpcr_samples[key][0]/qpcr_samples[key][4])
    fold_enrichment_rpl35_hbg2.append(qpcr_samples[key][1]/qpcr_samples[key][4])
    fold_enrichment_eif2a_hbg2.append(qpcr_samples[key][2]/qpcr_samples[key][4])
    fold_enrichment_rcl1_hbg2.append(qpcr_samples[key][3]/qpcr_samples[key][4])

plt.figure(figsize=(10, 6))

bar_width = 0.20  
x_pos = np.arange(len(qpcr_samples)) 

plt.bar(x_pos - 1.5 * bar_width, np.log10(fold_enrichment_apex1_hbg2), color='blue', alpha=0.7, label='APEX1/HBG2', width=bar_width)
plt.bar(x_pos - 0.5 * bar_width, np.log10(fold_enrichment_rpl35_hbg2), color='green', alpha=0.7, label='RPL35/HBG2', width=bar_width)
plt.bar(x_pos + 0.5 * bar_width, np.log10(fold_enrichment_eif2a_hbg2), color='orange', alpha=0.7, label='EIF2A/HBG2', width=bar_width)
plt.bar(x_pos + 1.5 * bar_width, np.log10(fold_enrichment_rcl1_hbg2), color='red', alpha=0.7, label='RCL1/HBG2', width=bar_width)

plt.xticks(x_pos, qpcr_samples.keys(), rotation=45)

# Add title and labels
plt.title('Fold Enrichment of Positive Loci Over Negative Locus')
plt.xlabel('ChIP Samples')
plt.ylabel('Log10 of Fold Enrichment')
plt.ylim(-1,3)
plt.legend(title='Loci')
plt.tight_layout()
plt.savefig('./plots/lmyc_qpcr_enrichment.png', dpi=600)

