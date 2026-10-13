import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:travel_app/features/auth/provider/auth_providers.dart';
import 'package:travel_app/features/search/repository/search_repository.dart';

import '../../../shared/models/travel_db_model.dart';
part 'search_provider.g.dart';

@riverpod
Future<List<TravelDbModel>> searchTrip(Ref ref, String query) async {
  final user = ref.watch(userInfoProvider)!.uid;
  final searchRepository = ref.read(searchRepositoryProvider);
  final result = await searchRepository.searchTrips(userId: user, query: query);
  return result.fold((l) => [], (r) => r);
}
