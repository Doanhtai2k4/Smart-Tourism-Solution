import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:travel_app/core/failure.dart';
import 'package:travel_app/core/type_def.dart';
import '../models/message_model.dart';

class GroupChatRepository {
  final FirebaseFirestore _firestore;

  GroupChatRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference _getMessagesCollection(String tripId) {
    return _firestore.collection('trips').doc(tripId).collection('group_messages');
  }

  Stream<List<MessageModel>> getMessages(String tripId) {
    return _getMessagesCollection(tripId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  FutureVoid sendMessage(String tripId, MessageModel message) async {
    try {
      await _getMessagesCollection(tripId).add(message.toMap());
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Lỗi gửi tin nhắn'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
