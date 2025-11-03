import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


df = pd.read_csv("top3_strains.tsv", sep="\t")


df_melted = pd.melt(
    df,
    id_vars=["Sample"],
    value_vars=["Strain1", "Strain2", "Strain3"],
    var_name="StrainRank",
    value_name="Strain"
)


perc_melted = pd.melt(
    df,
    id_vars=["Sample"],
    value_vars=["Perc1", "Perc2", "Perc3"],
    var_name="PercRank",
    value_name="Percentage"
)


df_long = df_melted.copy()
df_long["Percentage"] = perc_melted["Percentage"].astype(float)


plt.figure(figsize=(14, 6))
sns.barplot(
    data=df_long,
    x="Sample",
    y="Percentage",
    hue="Strain"
)
plt.xticks(rotation=90)
plt.ylabel("Percentage (%)")
plt.title("Top 3 Strains per Sample")
plt.tight_layout()
plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')

plt.savefig("top3_strains_barplot2.png", dpi=300)
plt.show()