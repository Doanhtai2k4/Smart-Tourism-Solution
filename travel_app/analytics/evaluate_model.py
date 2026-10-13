import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score

import sys
try:
    sys.stdout.reconfigure(encoding='utf-8')
except AttributeError:
    pass

# Paths
BASE_DIR = os.path.dirname(__file__)
DATA_DIR = os.path.join(BASE_DIR, 'data')
CHARTS_DIR = os.path.join(BASE_DIR, 'charts')
USERS_FILE = os.path.join(DATA_DIR, 'users.csv')
ACTIVITIES_FILE = os.path.join(DATA_DIR, 'activities.csv')

print("Starting model evaluation process...")

# 1. Load and prepare data
df_users = pd.read_csv(USERS_FILE)
df_activities = pd.read_csv(ACTIVITIES_FILE)

# Aggregate activity features per user
activity_features = df_activities.groupby('user_id').agg(
    total_spend=('spend_amount', 'sum'),
    total_activities=('activity_id', 'count'),
    avg_session_duration=('session_duration_minutes', 'mean'),
    num_bookings=('activity_type', lambda x: sum(x.isin(['book_hotel', 'book_flight']))),
    avg_rating=('rating', 'mean')
).reset_index()

activity_features['avg_rating'] = activity_features['avg_rating'].fillna(4.0)

df_merged = pd.merge(df_users, activity_features, on='user_id', how='left')
df_merged['total_spend'] = df_merged['total_spend'].fillna(0.0)
df_merged['total_activities'] = df_merged['total_activities'].fillna(0)
df_merged['avg_session_duration'] = df_merged['avg_session_duration'].fillna(0.0)
df_merged['num_bookings'] = df_merged['num_bookings'].fillna(0)

features_to_use = [
    'age', 
    'average_trip_duration', 
    'total_spend', 
    'total_activities', 
    'avg_session_duration', 
    'num_bookings'
]

X = df_merged[features_to_use]

# Scale features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# 2. Compute WCSS (Inertia) and Silhouette Scores for K=1..10
wcss = []
silhouette_scores = []
k_range_elbow = range(1, 11)
k_range_silhouette = range(2, 11)

print("Calculating WCSS (Inertia) and Silhouette scores for K=1 to 10...")

for k in k_range_elbow:
    kmeans = KMeans(n_clusters=k, random_state=42, n_init=10)
    kmeans.fit(X_scaled)
    wcss.append(kmeans.inertia_)
    
    if k >= 2:
        score = silhouette_score(X_scaled, kmeans.labels_)
        silhouette_scores.append(score)

# 3. Plotting Evaluation Charts
print("Creating premium model evaluation chart...")

# Style configuration
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

palette = {
    'primary': '#4F46E5',    # Indigo
    'secondary': '#06B6D4',  # Teal/Cyan
    'accent': '#EF4444',     # Red (used for highlighting chosen K)
    'emerald': '#10B981',    # Green
}

def remove_spines(ax):
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_color('#CBD5E1')
    ax.spines['bottom'].set_color('#CBD5E1')

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))

# Subplot 1: Elbow Method (WCSS)
ax1.plot(k_range_elbow, wcss, color=palette['primary'], linewidth=3, marker='o', markersize=6, label='WCSS')
# Highlight K=4 with a larger red star
chosen_k = 4
ax1.plot(chosen_k, wcss[chosen_k-1], color=palette['accent'], marker='*', markersize=14, 
         linestyle='None', label=f'Chosen K={chosen_k} (Elbow point)')

ax1.set_title("The Elbow Method (WCSS vs. K)", fontsize=14, fontweight='bold', pad=15, color='#0F172A')
ax1.set_xlabel("Number of Clusters (K)", fontsize=11, labelpad=8)
ax1.set_ylabel("Inertia (Within-Cluster Sum of Squares)", fontsize=11, labelpad=8)
ax1.set_xticks(list(k_range_elbow))
ax1.legend(frameon=True, facecolor='#FCFDFE', edgecolor='#E2E8F0')
remove_spines(ax1)

# Annotate Elbow
ax1.annotate('Elbow Point (K=4)\nOptimal trade-off', 
             xy=(chosen_k, wcss[chosen_k-1]), 
             xytext=(chosen_k + 0.8, wcss[chosen_k-1] + (max(wcss) - min(wcss)) * 0.15),
             arrowprops=dict(facecolor='#4A5568', shrink=0.08, width=1.5, headwidth=6, headlength=6),
             fontsize=10, fontweight='bold', color='#475569')

# Subplot 2: Silhouette Score vs K
ax2.plot(list(k_range_silhouette), silhouette_scores, color=palette['emerald'], linewidth=3, marker='o', markersize=6, label='Silhouette Score')
# Highlight K=4 with a larger red star
ax2.plot(chosen_k, silhouette_scores[chosen_k-2], color=palette['accent'], marker='*', markersize=14, 
         linestyle='None', label=f'Chosen K={chosen_k} Score')

ax2.set_title("Silhouette Coefficient vs. K", fontsize=14, fontweight='bold', pad=15, color='#0F172A')
ax2.set_xlabel("Number of Clusters (K)", fontsize=11, labelpad=8)
ax2.set_ylabel("Silhouette Score (Higher is Better)", fontsize=11, labelpad=8)
ax2.set_xticks(list(k_range_silhouette))
ax2.legend(frameon=True, facecolor='#FCFDFE', edgecolor='#E2E8F0')
remove_spines(ax2)

# Value label for chosen K score
chosen_score = silhouette_scores[chosen_k-2]
ax2.text(chosen_k + 0.2, chosen_score - 0.015, f'Score: {chosen_score:.4f}', 
         fontsize=10, fontweight='bold', color='#EF4444')

plt.tight_layout()
eval_chart_path = os.path.join(CHARTS_DIR, 'model_evaluation.png')
fig.savefig(eval_chart_path, dpi=300, bbox_inches='tight')
plt.close(fig)

print(f"Model evaluation complete! Evaluation chart saved to {eval_chart_path}")
