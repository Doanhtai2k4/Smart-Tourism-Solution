import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:travel_app/core/constants/firebase_constant.dart';
import 'package:travel_app/core/failure.dart';
import 'package:travel_app/core/type_def.dart';
import 'package:travel_app/shared/models/travel_db_model.dart';
import 'package:travel_app/features/auth/provider/auth_providers.dart';
part 'search_repository.g.dart';

@riverpod
SearchRepository searchRepository(Ref ref) {
  return SearchRepository(firestore: ref.read(firebaseFirestoreProvider));
}

class SearchRepository {
  final FirebaseFirestore _firestore;

  SearchRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference get _trips =>
      _firestore.collection(FirebaseConstant.trips);

  FutureEither<List<TravelDbModel>> searchTrips({
    required String userId,
    required String query,
  }) async {
    try {
      final trimmedQuery = query.trim();
      debugPrint(
        'Raw query: "$query", Trimmed query: "$trimmedQuery", User ID: $userId',
      );

      if (trimmedQuery.isEmpty) {
        debugPrint('Empty query for user $userId, returning empty list');
        return right([]);
      }

      final normalizedQuery = trimmedQuery.toLowerCase();
      debugPrint('Normalized query: "$normalizedQuery"');

      // Fetch all user trips and filter client-side to avoid composite index issues
      final snapshot = await _trips
          .where('userId', isEqualTo: userId)
          .limit(30)
          .get();

      debugPrint('Total docs for user: ${snapshot.docs.length}');

      final trips = snapshot.docs
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final destinationLowerCase =
                data['destinationLowerCase'] as String? ?? '';
            return destinationLowerCase.contains(normalizedQuery);
          })
          .take(20)
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            try {
              return TravelDbModel.fromJson(data);
            } catch (e) {
              debugPrint(
                'Error parsing document ${doc.id} for user $userId: $e',
              );
              return null;
            }
          })
          .whereType<TravelDbModel>()
          .toList();

      debugPrint(
        'Found ${trips.length} trips for user $userId with query: $trimmedQuery',
      );
      return right(trips);
    } on FirebaseException catch (e) {
      debugPrint(
        'Firestore error searching trips for user $userId: ${e.code} - ${e.message}',
      );
      return left(Failure(e.message ?? 'Failed to search trips'));
    } catch (e, stack) {
      debugPrint(
        'General error searching trips for user $userId: $e\nStack: $stack',
      );
      return left(Failure('Failed to search trips: $e'));
    }
  }
}
