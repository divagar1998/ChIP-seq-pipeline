import pandas as pd
import matplotlib.pyplot as plt
import numpy as np


data = {
    "GO Term": [
        "Chemical Synaptic Transmission",
        "Anterograde Trans-Synaptic Signaling",
        "Regulation of Neuron Projection Development",
        "Potassium Ion Transmembrane Transport",
        "Regulation of Long-Term Synaptic Depression",
        "Potassium Ion Transport",
        "Regulation of DNA-templated Transcription",
        "Generation of Neurons",
        "Regulation of Postsynaptic Membrane Potential",
        "Chemical Synaptic Transmission, Postsynaptic"
    ],
    "p-value": [
        2.514e-9,
        0.000006479,
        0.004565,
        0.004565,
        0.006172,
        0.006172,
        0.006840,
        0.006840,
        0.006840,
        0.006840
    ]
}

df = pd.DataFrame(data)

df["-log10(p-value)"] = -np.log10(df["p-value"])

df = df.sort_values("-log10(p-value)", ascending=True)

plt.figure(figsize=(6, 3))
bars = plt.barh(
    df["GO Term"],
    df["-log10(p-value)"],
    #color="lightgray",
    color=["lightgray" if term == "Regulation of DNA-templated Transcription" else "lightblue" for term in df["GO Term"]],
    edgecolor="black",
    linewidth=1.5
)

ax = plt.gca()
'''
labels = ax.get_yticklabels()
for label in labels:
    if label.get_text() == "Neuron Differentiation":
        label.set_fontweight('bold')

neuron_genes = ["IRX1, EMX1,", "EMX2, MEF2C,", "GLI2, ISL2,","ATOH1"]
gene_text = "\n".join(neuron_genes)

for bar, term in zip(bars, df["GO Term"]):
    if term == "Neuron Differentiation":
        neuron_bar = bar
        break

# Get bar position and height
x = neuron_bar.get_width()
y = neuron_bar.get_y() + neuron_bar.get_height() / 2

# Get index of Notch row
neuron_index = df.index[df["GO Term"] == "Neuron Differentiation"][0]
neuron_value = df.loc[neuron_index, "-log10(p-value)"]

# Annotate genes next to the bar
plt.text(
    x + 0.3,      # x-position slightly right of the bar
    y,            # y-position at the same bar
    gene_text,              # text block
    va='center',
    fontsize=6,
    bbox=dict(facecolor='lightblue', edgecolor='black', boxstyle='round,pad=0.3')
)
'''
plt.xlabel("-log10(adj. p-value)", fontsize=8)
plt.tick_params(axis='x', labelsize=6) 
plt.tick_params(axis='y', labelsize=7) 
plt.title("Top 10 GO Biological Process 2025", fontsize=10)
plt.grid(axis="x", linestyle="--", alpha=0.5)
plt.tight_layout()
plt.savefig("~/watanabe/Divagar/chromhmm/E5_to_E2_E3_go.png", dpi=600)
