import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:travel_app/features/auth/provider/auth_providers.dart';
import 'package:travel_app/features/discovery/repositories/favorites_repository.dart';
import 'package:travel_app/shared/models/destination_model.dart';

part 'favorites_provider.g.dart';

@riverpod
Stream<bool> isFavorite(Ref ref, String destinationId) {
  final user = ref.watch(userInfoProvider);
  if (user == null) return Stream.value(false);

  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.isFavoriteStream(
    userId: user.uid,
    destinationId: destinationId,
  );
}

@riverpod
Stream<List<DestinationModel>> favoriteDestinations(Ref ref) {
  final user = ref.watch(userInfoProvider);
  if (user == null) return Stream.value([]);

  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.getFavoriteDestinationsStream(user.uid);
}
