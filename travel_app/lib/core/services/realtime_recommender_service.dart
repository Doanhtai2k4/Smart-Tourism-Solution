import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/features/auth/provider/auth_providers.dart';
import 'package:travel_app/shared/models/destination_model.dart';

part 'realtime_recommender_service.g.dart';

/// Real-time In-Session Recommender Service.
/// It tracks user preferences based on current session interactions.
@Riverpod(keepAlive: true)
class RealtimeRecommender extends _$RealtimeRecommender {
  @override
  Map<String, double> build() {
    return {};
  }

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static const String _localKeyPrefix = 'user_recommender_prefs_';

  /// Bulletproof Init: LOAD LOCAL FIRST, then fetch Cloud.
  Future<void> initProfile(String userId) async {
    print('DEBUG: [RealtimeRecommender] Initializing profile for user: $userId');
    
    // 1. FAST LOAD: From Local Cache (SharedPreferences)
    await _loadFromLocal(userId);

    // 2. BACKGROUND LOAD: From Firestore Cloud
    await loadProfileFromCloud(userId);
  }

  /// Load from Local Cache (SharedPreferences)
  Future<void> _loadFromLocal(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('$_localKeyPrefix$userId');
      
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> decoded = json.decode(jsonStr);
        final Map<String, double> localPrefs = decoded.map((key, value) {
          return MapEntry(key, (value as num).toDouble());
        });
        
        // Update state immediately from local
        state = {...localPrefs};
        print('DEBUG: [RealtimeRecommender] LOADED FROM LOCAL cache. Count: ${state.length}');
      }
    } catch (e) {
      print('CRITICAL: [RealtimeRecommender] Error loading from local cache: $e');
    }
  }

  /// Save to Local Cache (SharedPreferences) - Fast & Bulletproof
  Future<void> _saveToLocal(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr = json.encode(state);
      await prefs.setString('$_localKeyPrefix$userId', jsonStr);
      print('DEBUG: [RealtimeRecommender] SAVED TO LOCAL cache successfully.');
    } catch (e) {
      print('CRITICAL: [RealtimeRecommender] Error saving to local cache: $e');
    }
  }

  /// Load user profile from Firestore Cloud.
  Future<void> loadProfileFromCloud(String userId) async {
    print('DEBUG: [RealtimeRecommender] Fetching cloud profile for user: $userId');
    try {
      final doc = await _firestore.collection('user_profiles').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        final rawPrefs = data?['preferences'] as Map<String, dynamic>?;
        
        if (rawPrefs != null) {
          // Convert to Map<String, double> safely
          final Map<String, double> cloudPrefs = rawPrefs.map((key, value) {
            return MapEntry(key, (value as num).toDouble());
          });
          
          // Merge logic: Combine local and cloud if needed, or prefer cloud as primary source of truth
          // For now, cloud replaces/updates everything but we keep the local in sync
          state = {...cloudPrefs};
          
          // Sync back to local to keep them consistent
          await _saveToLocal(userId);
          
          print('DEBUG: [RealtimeRecommender] CLOUD PROFILE FETCHED and applied. Preferences count: ${state.length}');
        }
      }
    } catch (e) {
      print('CRITICAL: [RealtimeRecommender] Error loading preferences from cloud: $e');
    }
  }

  /// Sync the current profile to Firestore Cloud with debouncing.
  void _syncProfileToCloud(String userId) async {
    print('DEBUG: [RealtimeRecommender] Syncing profile to cloud for user: $userId');
    try {
      await _firestore.collection('user_profiles').doc(userId).set({
        'preferences': state,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('DEBUG: [RealtimeRecommender] Profile synced to cloud successfully.');
    } catch (e) {
      print('CRITICAL: [RealtimeRecommender] Error syncing preferences to cloud: $e');
    }
  }

  /// Set initial preferences during onboarding to solve cold start.
  Future<void> setInitialPreferences(
    String userId, {
    required List<String> interests,
    required List<String> suitableFor,
    required String budgetLevel,
  }) async {
    final Map<String, double> initialPreferences = {};

    // Give interests a base weight of 1.5
    for (final interest in interests) {
      initialPreferences[interest] = 1.5;
    }

    // Give suitableFor styles a base weight of 2.0 (strong signal for companionship)
    for (final style in suitableFor) {
      initialPreferences[style] = 2.0;
    }

    // Give budget level a base weight of 2.0 (strong constraint)
    initialPreferences[budgetLevel] = 2.0;

    state = initialPreferences;

    // Save locally
    await _saveToLocal(userId);

    // Sync to Firestore immediately
    await _firestore.collection('user_profiles').doc(userId).set({
      'preferences': state,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Update user preferences based on an interaction with a destination.
  void updatePreferences(DestinationModel destination, {double weight = 1.0}) {
    final Map<String, double> newPreferences = Map.from(state);

    // 1. Process Category
    final category = destination.category ?? 'Uncategorized';
    newPreferences[category] = (newPreferences[category] ?? 0.0) + weight;

    // 2. Process Tags
    for (final tag in destination.tags) {
      newPreferences[tag] = (newPreferences[tag] ?? 0.0) + weight;
    }

    state = newPreferences;

    // 3. Persistence: Local Save (INSTANT)
    final user = ref.read(userInfoProvider);
    if (user != null) {
      _saveToLocal(user.uid);

      // 4. Persistence: Cloud Sync (DEBOUNCED)
      EasyDebounce.debounce(
        'sync-recommender-${user.uid}',
        const Duration(seconds: 3),
        () => _syncProfileToCloud(user.uid),
      );
    }
  }

  /// Calculate a score for a single destination based on current profile.
  double getScore(DestinationModel destination) {
    if (state.isEmpty) return 0.0;

    double score = 0.0;
    final category = destination.category ?? 'Uncategorized';
    if (state.containsKey(category)) {
      score += state[category]!;
    }
    
    // 1. Tags
    for (final tag in destination.tags) {
      if (state.containsKey(tag)) {
        score += state[tag]!;
      }
    }

    // 2. Suitability (Companion)
    for (final suitability in destination.suitableFor) {
      if (state.containsKey(suitability)) {
        score += state[suitability]!;
      }
    }

    // 3. Budget Level
    if (destination.budgetLevel != null && state.containsKey(destination.budgetLevel!)) {
      score += state[destination.budgetLevel!]!;
    }

    return score;
  }

  /// Rank a list of destinations based on current session preferences.
  List<DestinationModel> rankDestinations(List<DestinationModel> allDestinations) {
    if (state.isEmpty) return allDestinations;

    final List<DestinationModel> ranked = List.from(allDestinations);
    ranked.sort((a, b) {
      return getScore(b).compareTo(getScore(a));
    });

    return ranked;
  }

  /// Force an immediate sync to cloud (bypass debounce).
  void forceSync() {
    final user = ref.read(userInfoProvider);
    if (user != null) {
      print('DEBUG: [RealtimeRecommender] Force syncing profile to cloud (LIFECYCLE EVENT)');
      _syncProfileToCloud(user.uid);
    }
  }

  /// Reset the session preferences.
  Future<void> reset() async {
    final user = ref.read(userInfoProvider);
    if (user != null) {
      state = {};
      // Clear local
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_localKeyPrefix${user.uid}');
      
      // Clear cloud
      await _firestore.collection('user_profiles').doc(user.uid).update({
        'preferences': FieldValue.delete(),
      });
      print('DEBUG: [RealtimeRecommender] Preferences reset both locally and in cloud.');
    }
  }
}
