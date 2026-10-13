import os
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA

import sys
try:
    sys.stdout.reconfigure(encoding='utf-8')
except AttributeError:
    pass

# Paths
BASE_DIR = os.path.dirname(__file__)
DATA_DIR = os.path.join(BASE_DIR, 'data')
USERS_FILE = os.path.join(DATA_DIR, 'users.csv')
ACTIVITIES_FILE = os.path.join(DATA_DIR, 'activities.csv')
OUTPUT_FILE = os.path.join(DATA_DIR, 'users_with_clusters.csv')

print("Starting machine learning workflow...")

# 1. Load data
if not os.path.exists(USERS_FILE) or not os.path.exists(ACTIVITIES_FILE):
    raise FileNotFoundError("Missing data files! Run generate_data.py first.")

df_users = pd.read_csv(USERS_FILE)
df_activities = pd.read_csv(ACTIVITIES_FILE)

print(f"Loaded {len(df_users)} users and {len(df_activities)} activity records.")

# 2. Feature Engineering from activities
print("Performing feature engineering from user activity logs...")

# Aggregating activity metrics per user
activity_features = df_activities.groupby('user_id').agg(
    total_spend=('spend_amount', 'sum'),
    total_activities=('activity_id', 'count'),
    avg_session_duration=('session_duration_minutes', 'mean'),
    num_bookings=('activity_type', lambda x: sum(x.isin(['book_hotel', 'book_flight']))),
    avg_rating=('rating', 'mean')
).reset_index()

# Fill NaN in avg_rating with a default or middle value (e.g. 4.0) or 0
activity_features['avg_rating'] = activity_features['avg_rating'].fillna(4.0)

# Merge back with demographics
df_merged = pd.merge(df_users, activity_features, on='user_id', how='left')

# Inactive users might have NaN activity metrics if they had 0 activities (though we generated at least 2)
df_merged['total_spend'] = df_merged['total_spend'].fillna(0.0)
df_merged['total_activities'] = df_merged['total_activities'].fillna(0)
df_merged['avg_session_duration'] = df_merged['avg_session_duration'].fillna(0.0)
df_merged['num_bookings'] = df_merged['num_bookings'].fillna(0)
df_merged['avg_rating'] = df_merged['avg_rating'].fillna(4.0)

# 3. Select features for Clustering
# We will use demographics + activity behavior
features_to_use = [
    'age', 
    'average_trip_duration', 
    'total_spend', 
    'total_activities', 
    'avg_session_duration', 
    'num_bookings'
]

X = df_merged[features_to_use]

# 4. Standardize features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# 5. Train KMeans Clustering
num_clusters = 4
print(f"Training KMeans model with K={num_clusters} clusters...")
kmeans = KMeans(n_clusters=num_clusters, random_state=42, n_init=10)
df_merged['cluster'] = kmeans.fit_predict(X_scaled)

# 6. Interpret clusters and assign business names programmatically
# We can look at average spend and activity count to profile them:
cluster_profiles = df_merged.groupby('cluster').agg(
    avg_spend=('total_spend', 'mean'),
    avg_acts=('total_activities', 'mean'),
    avg_age=('age', 'mean'),
    avg_dur=('average_trip_duration', 'mean')
).reset_index()

print("\nCluster Profiles (Averages):")
print(cluster_profiles)

# Programmatic profiling names based on spend and activity metrics
# Let's map cluster indices to names based on their relative ranks:
# Cluster with highest average spend -> "Luxury Elites"
# Cluster with low spend but very high activities -> "Active Backpackers"
# Cluster with low spend and low activities -> "Churned/Occasional Users"
# Cluster with medium spend and medium activities -> "Standard Vacationers"

profiles = sorted(cluster_profiles.to_dict('records'), key=lambda x: x['avg_spend'])

# Assigning labels
cluster_name_map = {}
# Smallest spend is Churned/Occasional
cluster_name_map[profiles[0]['cluster']] = "Occasional / Churned"
# Highest spend is Luxury
cluster_name_map[profiles[3]['cluster']] = "Luxury Elites"

# For the middle two, let's distinguish by activity counts
middle_1 = profiles[1]
middle_2 = profiles[2]

if middle_1['avg_acts'] > middle_2['avg_acts']:
    cluster_name_map[middle_1['cluster']] = "Active Budget Backpackers"
    cluster_name_map[middle_2['cluster']] = "Standard Vacationers"
else:
    cluster_name_map[middle_1['cluster']] = "Standard Vacationers"
    cluster_name_map[middle_2['cluster']] = "Active Budget Backpackers"

df_merged['cluster_name'] = df_merged['cluster'].map(cluster_name_map)

# 7. Apply PCA for 2D visualization plotting later
print("Applying PCA to reduce dimensionality to 2D for visualization...")
pca = PCA(n_components=2, random_state=42)
pca_components = pca.fit_transform(X_scaled)

df_merged['pca_x'] = pca_components[:, 0]
df_merged['pca_y'] = pca_components[:, 1]

# Save cluster mappings to CSV
df_merged.to_csv(OUTPUT_FILE, index=False, encoding='utf-8')
print(f"Workflow complete. Saved clustered users data to {OUTPUT_FILE}")
print("Cluster name mapping assigned:")
for k, v in cluster_name_map.items():
    print(f"  Cluster {k}: {v}")
