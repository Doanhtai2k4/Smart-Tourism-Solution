import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/provider/auth_providers.dart';
import '../models/message_model.dart';
import '../repository/group_chat_repository.dart';

part 'group_chat_provider.g.dart';

@riverpod
GroupChatRepository groupChatRepository(Ref ref) {
  return GroupChatRepository(firestore: ref.watch(firebaseFirestoreProvider));
}

@riverpod
Stream<List<MessageModel>> groupMessages(Ref ref, String tripId) {
  return ref.watch(groupChatRepositoryProvider).getMessages(tripId);
}
