import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.patches import Patch, Rectangle

df1 = pd.read_csv("./cMYC/SCLC_N_cMYC_shared_peaks_annstats.txt", sep="\t")
df1["Sample"] = "Shared peaks"

df2 = pd.read_csv("./cMYC/unique_H2171_cMYC_peaks_annstats.txt", sep="\t")
df2["Sample"] = "Unique to H2171"

df3 = pd.read_csv("./cMYC/unique_H82_cMYC_peaks_annstats.txt", sep="\t")
df3["Sample"] = "Unique to H82"

df4 = pd.read_csv("./cMYC/unique_H524_cMYC_peaks_annstats.txt", sep="\t")
df4["Sample"] = "Unique to H524"

# Background genome coverage
background_genome_coverage = {
    "3UTR": 0.75,
    "TTS": 1.09,
    "Exon": 1.23,
    "Intron": 40.47,
    "Intergenic": 54.85,
    "Promoter": 1.21,
    "5UTR": 0.09,
    "Other": 0.31
}

bg_df = pd.DataFrame([
    {"Sample": "Background", "Category": k, "Number of peaks": v}
    for k, v in background_genome_coverage.items()
])

df = pd.concat([df1, df2, df3, df4], ignore_index=True)
df["Category"] = df["Annotation"].apply(lambda x: x if x in background_genome_coverage else "Other")
df = pd.concat([df, bg_df], ignore_index=True)

grouped = df.groupby(["Sample", "Category"])["Number of peaks"].sum().reset_index()
grouped["Total"] = grouped.groupby("Sample")["Number of peaks"].transform("sum")
grouped["Proportion (%)"] = (grouped["Number of peaks"] / grouped["Total"]) * 100

order = ["3UTR", "Promoter", "Exon", "Intron", "5UTR", "TTS", "Intergenic", "Other"]
sample_order = ["Background", "Shared peaks", "Unique to H2171", "Unique to H82", "Unique to H524"]
grouped["Category"] = pd.Categorical(grouped["Category"], categories=order, ordered=True)
grouped["Sample"] = pd.Categorical(grouped["Sample"], categories=sample_order, ordered=True)

pivot = grouped.pivot(index="Sample", columns="Category", values="Proportion (%)").fillna(0)
pivot = pivot.loc[sample_order, order]

# Color map
category_colors = {
    "3UTR": "lightblue",
    "Promoter": "lightgreen",
    "Exon": "orange",
    "Intron": "pink",
    "5UTR": "yellow",
    "TTS": "purple",
    "Intergenic": "gray",
    "Other": "lightgray"
}

plt.figure(figsize=(6, 5))
x = range(len(pivot))
bottom = [0] * len(pivot)

# Draw each category segment
for cat in order:
    values = pivot[cat].values
    color = category_colors.get(cat, "lightgray")

    bars = plt.bar(
        x, values, bottom=bottom,
        width=0.8,
        color=color,
        edgecolor='black',
        linewidth=1.0,
        zorder=2,
        label=cat
    )

    for i, bar in enumerate(bars):
        sample = pivot.index[i]
        height = bar.get_height()
        if height > 0 and (
            (cat in ["Intron", "Intergenic"]) or
            (cat == "Promoter" and sample != "Background")
        ):
            plt.text(
                bar.get_x() + bar.get_width() / 2,
                bar.get_y() + height / 2,
                f"{height:.1f}%",
                ha='center', va='center',
                fontsize=10, color='black'
            )

    bottom = [b + v for b, v in zip(bottom, values)]

# Draw dotted outline over the full "Background" bar
bg_index = sample_order.index("Background")
total_height = pivot.loc["Background"].sum()
plt.gca().add_patch(Rectangle(
    (bg_index - 0.4, 0), 0.8, total_height,
    fill=False,
    edgecolor='black',
    linewidth=3,
    linestyle=(0, (2, 2)),
    zorder=3
))

plt.xticks(x, pivot.index, rotation=45, fontsize=8)
plt.ylabel("Proportion of Total Peaks (%)/ Proportion of Genome (%)", fontsize=8)
plt.title("c-Myc Peak Distribution vs. Genome Coverage", fontsize=10)

handles = [Patch(facecolor=category_colors[cat], edgecolor='black', label=cat) for cat in order]
handles.insert(0, Patch(facecolor='white', edgecolor='black', linestyle='--', label='Genome coverage'))
plt.legend(handles=handles, title="Annotation", bbox_to_anchor=(1.05, 1), loc='upper left', fontsize=7)

plt.tight_layout()
plt.savefig("stacked_bar_cMYC_colored_with_dotted_background_fixed.png", dpi=600)
