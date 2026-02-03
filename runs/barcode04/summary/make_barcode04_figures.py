import os
import pandas as pd
import matplotlib.pyplot as plt

BASE = os.path.expanduser("~/results/barcode04/summary")
OUTDIR = os.path.join(BASE, "figures")
os.makedirs(OUTDIR, exist_ok=True)

def read_two_col_tsv(path, col1, col2):
    df = pd.read_csv(path, sep="\t", header=None, names=[col1, col2])
    df[col1] = df[col1].astype(str).str.strip()
    df[col2] = pd.to_numeric(df[col2], errors="coerce").fillna(0).astype(int)
    return df

def save_fig(fig, name):
    png_path = os.path.join(OUTDIR, f"{name}.png")
    pdf_path = os.path.join(OUTDIR, f"{name}.pdf")
    fig.savefig(png_path, dpi=300, bbox_inches="tight")
    fig.savefig(pdf_path, bbox_inches="tight")
    plt.close(fig)
    print(f"Saved: {png_path}")
    print(f"Saved: {pdf_path}")

# Figure 1: AMR by molecule type
df_mol = read_two_col_tsv(os.path.join(BASE, "amr_by_molecule_type.tsv"), "molecule_type", "count") \
    .sort_values("count", ascending=False)

fig, ax = plt.subplots()
ax.bar(df_mol["molecule_type"], df_mol["count"])
ax.set_title("Barcode04: AMR hits by molecule type")
ax.set_xlabel("Molecule type")
ax.set_ylabel("Number of AMR hits")
save_fig(fig, "barcode04_amr_by_molecule_type")

# Figure 2: AMR by drug class
df_dc = read_two_col_tsv(os.path.join(BASE, "amr_by_drug_class.tsv"), "drug_class", "count") \
    .sort_values("count", ascending=True)

fig, ax = plt.subplots(figsize=(8, max(4, 0.35 * len(df_dc))))
ax.barh(df_dc["drug_class"], df_dc["count"])
ax.set_title("Barcode04: AMR hits by drug class")
ax.set_xlabel("Count")
ax.set_ylabel("Drug class")
save_fig(fig, "barcode04_amr_by_drug_class")

# Figure 3: AMR by resistance mechanism
df_mech = read_two_col_tsv(os.path.join(BASE, "amr_by_mechanism.tsv"), "mechanism", "count") \
    .sort_values("count", ascending=True)

fig, ax = plt.subplots(figsize=(8, max(4, 0.35 * len(df_mech))))
ax.barh(df_mech["mechanism"], df_mech["count"])
ax.set_title("Barcode04: AMR hits by resistance mechanism")
ax.set_xlabel("Count")
ax.set_ylabel("Resistance mechanism")
save_fig(fig, "barcode04_amr_by_mechanism")
