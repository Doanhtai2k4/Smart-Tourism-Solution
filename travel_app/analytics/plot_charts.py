import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime

# Avoid unicode errors on Windows stdout
import sys
try:
    sys.stdout.reconfigure(encoding='utf-8')
except AttributeError:
    pass

# Paths
BASE_DIR = os.path.dirname(__file__)
DATA_DIR = os.path.join(BASE_DIR, 'data')
CHARTS_DIR = os.path.join(BASE_DIR, 'charts')
os.makedirs(CHARTS_DIR, exist_ok=True)

CLUSTERED_USERS_FILE = os.path.join(DATA_DIR, 'users_with_clusters.csv')
ACTIVITIES_FILE = os.path.join(DATA_DIR, 'activities.csv')

print("Starting visualization engine...")

# Load datasets
if not os.path.exists(CLUSTERED_USERS_FILE) or not os.path.exists(ACTIVITIES_FILE):
    raise FileNotFoundError("Clustered users data or activities data is missing! Run generate_data.py and train_model.py first.")

df_users = pd.read_csv(CLUSTERED_USERS_FILE)
df_activities = pd.read_csv(ACTIVITIES_FILE)

# Style configuration for premium aesthetic
plt.style.use('seaborn-v0_8-whitegrid' if 'seaborn-v0_8-whitegrid' in plt.style.available else 'default')
plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['figure.facecolor'] = '#FCFDFE'
plt.rcParams['axes.facecolor'] = '#FCFDFE'
plt.rcParams['axes.edgecolor'] = '#E2E8F0'
plt.rcParams['axes.grid'] = True
plt.rcParams['grid.color'] = '#EDF2F7'
plt.rcParams['grid.linestyle'] = '--'
plt.rcParams['grid.linewidth'] = 0.6
plt.rcParams['text.color'] = '#1A202C'
plt.rcParams['axes.labelcolor'] = '#2D3748'
plt.rcParams['xtick.color'] = '#4A5568'
plt.rcParams['ytick.color'] = '#4A5568'

# Harmonious Color Palette
palette = {
    'primary': '#4F46E5',    # Indigo
    'secondary': '#06B6D4',  # Teal/Cyan
    'accent': '#F59E0B',     # Amber
    'danger': '#EF4444',     # Red
    'success': '#10B981',    # Emerald
    'purple': '#8B5CF6',     # Purple
    'grey': '#64748B'        # Slate Grey
}

cluster_colors = {
    'Luxury Elites': '#8B5CF6',           # Purple
    'Active Budget Backpackers': '#10B981',# Emerald
    'Standard Vacationers': '#4F46E5',     # Indigo
    'Occasional / Churned': '#EF4444'      # Red
}

def remove_spines(ax):
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_color('#CBD5E1')
    ax.spines['bottom'].set_color('#CBD5E1')

# -------------------------------------------------------------------------
# CHART 1: Demographics (Age and Nationality)
# -------------------------------------------------------------------------
print("Plotting Chart 1: Demographics...")
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))

# Left: Age distribution with a beautiful gradient histogram
n, bins, patches = ax1.hist(df_users['age'], bins=20, color=palette['primary'], alpha=0.8, rwidth=0.85, edgecolor='none')
# Gradient-like coloring
for i, patch in enumerate(patches):
    fraction = i / len(patches)
    patch.set_facecolor(plt.cm.cool(fraction * 0.5 + 0.2))

ax1.set_title("Age Distribution of Users", fontsize=14, fontweight='bold', pad=15, color='#0F172A')
ax1.set_xlabel("Age", fontsize=11, labelpad=8)
ax1.set_ylabel("Count of Users", fontsize=11, labelpad=8)
remove_spines(ax1)

# Right: Nationality distribution (horizontal bar chart)
nat_counts = df_users['nationality'].value_counts().sort_values(ascending=True)
colors = [palette['grey'], palette['accent'], palette['danger'], palette['success'], palette['secondary'], palette['primary']]
bars = ax2.barh(nat_counts.index, nat_counts.values, color=colors[-len(nat_counts):], height=0.6, alpha=0.9)
ax2.set_title("User Breakdown by Nationality", fontsize=14, fontweight='bold', pad=15, color='#0F172A')
ax2.set_xlabel("Number of Users", fontsize=11, labelpad=8)
remove_spines(ax2)

# Add values to the horizontal bars
for bar in bars:
    width = bar.get_width()
    ax2.text(width + 8, bar.get_y() + bar.get_height()/2, f'{int(width)}', 
             va='center', ha='left', fontsize=10, fontweight='bold', color='#334155')

plt.tight_layout()
fig.savefig(os.path.join(CHARTS_DIR, 'demographics.png'), dpi=300, bbox_inches='tight')
plt.close(fig)

# -------------------------------------------------------------------------
# CHART 2: Travel Preferences by Budget Range
# -------------------------------------------------------------------------
print("Plotting Chart 2: Travel Preferences...")
fig, ax = plt.subplots(figsize=(10, 6))

# Pivot table: Preferred travel styles vs Budget range
pref_pivot = pd.crosstab(df_users['preferred_travel_style'], df_users['budget_range'], normalize='index') * 100
# Reorder columns
pref_pivot = pref_pivot[['Low', 'Medium', 'High']]

# Plotting stacked horizontal bar chart
pref_pivot.plot(kind='barh', stacked=True, color=[palette['success'], palette['primary'], palette['accent']], alpha=0.9, ax=ax, width=0.6)

ax.set_title("Travel Style Preferences by Budget Level", fontsize=15, fontweight='bold', pad=20, color='#0F172A')
ax.set_xlabel("Percentage (%)", fontsize=12, labelpad=8)
ax.set_ylabel("Travel Style", fontsize=12, labelpad=8)
ax.legend(title="Budget Level", frameon=True, facecolor='#FCFDFE', edgecolor='#E2E8F0')
remove_spines(ax)

# Add text percentage labels inside the stacked bars
for p in ax.patches:
    width, height = p.get_width(), p.get_height()
    x, y = p.get_xy()
    if width > 8: # Only show if slice is large enough
        ax.text(x + width/2, y + height/2, f'{width:.1f}%', 
                va='center', ha='center', fontsize=9, color='white', fontweight='bold')

plt.tight_layout()
fig.savefig(os.path.join(CHARTS_DIR, 'travel_preferences.png'), dpi=300, bbox_inches='tight')
plt.close(fig)

# -------------------------------------------------------------------------
# CHART 3: Spending Analysis by Persona / Cluster
# -------------------------------------------------------------------------
print("Plotting Chart 3: Spending Analysis...")
fig, ax = plt.subplots(figsize=(10, 6))

# Calculate average spend per cluster
avg_spend = df_users.groupby('cluster_name')['total_spend'].mean().sort_values(ascending=True)

# Format to VND millions
avg_spend_mil = avg_spend / 1_000_000

colors = [cluster_colors[name] for name in avg_spend.index]
bars = ax.bar(avg_spend.index, avg_spend_mil, color=colors, alpha=0.85, width=0.55, edgecolor='none')

ax.set_title("Average Travel Spend per User Segment", fontsize=15, fontweight='bold', pad=20, color='#0F172A')
ax.set_ylabel("Average Spend (Million VND)", fontsize=12, labelpad=10)
ax.set_xlabel("User Segment", fontsize=12, labelpad=10)
remove_spines(ax)

# Value annotations on top of bars
for bar in bars:
    height = bar.get_height()
    ax.text(bar.get_x() + bar.get_width()/2, height + 0.3, f'{height:.2f}M VND', 
             va='bottom', ha='center', fontsize=10, fontweight='bold', color='#1E293B')

plt.xticks(rotation=15)
plt.tight_layout()
fig.savefig(os.path.join(CHARTS_DIR, 'spending_analysis.png'), dpi=300, bbox_inches='tight')
plt.close(fig)

# -------------------------------------------------------------------------
# CHART 4: User Activities Trend
# -------------------------------------------------------------------------
print("Plotting Chart 4: Activity Trends...")
fig, ax = plt.subplots(figsize=(12, 6))

df_activities['dt_timestamp'] = pd.to_datetime(df_activities['timestamp'])
df_activities['year_month'] = df_activities['dt_timestamp'].dt.to_period('M')

# Group by Month
monthly_acts = df_activities.groupby('year_month').size()
monthly_acts_index = [str(x) for x in monthly_acts.index]

ax.plot(monthly_acts_index, monthly_acts.values, color=palette['primary'], linewidth=3, 
        marker='o', markersize=8, markerfacecolor=palette['secondary'], markeredgecolor='white', markeredgewidth=2)

ax.fill_between(monthly_acts_index, monthly_acts.values, color=palette['primary'], alpha=0.1)

ax.set_title("User Activities Trend Over Time (Monthly)", fontsize=15, fontweight='bold', pad=20, color='#0F172A')
ax.set_xlabel("Time (Year-Month)", fontsize=12, labelpad=8)
ax.set_ylabel("Total Number of Activities", fontsize=12, labelpad=8)
remove_spines(ax)

plt.xticks(rotation=30)
plt.tight_layout()
fig.savefig(os.path.join(CHARTS_DIR, 'activity_trends.png'), dpi=300, bbox_inches='tight')
plt.close(fig)

# -------------------------------------------------------------------------
# CHART 5: K-Means Clusters with PCA 2D Projection
# -------------------------------------------------------------------------
print("Plotting Chart 5: Cluster Visualization (PCA)...")
fig, ax = plt.subplots(figsize=(10, 7.5))

# Scatter plot for each cluster
for cluster_name, color in cluster_colors.items():
    cluster_df = df_users[df_users['cluster_name'] == cluster_name]
    ax.scatter(cluster_df['pca_x'], cluster_df['pca_y'], 
               color=color, label=cluster_name, alpha=0.7, edgecolors='white', linewidths=0.5, s=60)

ax.set_title("User Segmentation via K-Means Clustering (2D PCA Projection)", fontsize=14, fontweight='bold', pad=20, color='#0F172A')
ax.set_xlabel("Principal Component 1", fontsize=11, labelpad=8)
ax.set_ylabel("Principal Component 2", fontsize=11, labelpad=8)
ax.legend(title="User Segments", frameon=True, facecolor='#FCFDFE', edgecolor='#E2E8F0', loc='best')
remove_spines(ax)

# Draw neat grid lines
ax.grid(True, which='both', linestyle=':', alpha=0.5)

plt.tight_layout()
fig.savefig(os.path.join(CHARTS_DIR, 'user_segmentation.png'), dpi=300, bbox_inches='tight')
plt.close(fig)

print("All charts exported successfully to the charts/ directory!")
