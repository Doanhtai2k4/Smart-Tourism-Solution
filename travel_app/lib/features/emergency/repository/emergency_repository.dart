import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/emergency_model.dart';

final emergencyRepositoryProvider = Provider((ref) => EmergencyRepository());

class EmergencyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<EmergencyModel?> watchEmergencyInfo(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('info')
        .doc('emergency')
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return EmergencyModel.fromJson(doc.data()!);
    });
  }

  Future<void> updateEmergencyInfo(EmergencyModel info) async {
    await _firestore
        .collection('trips')
        .doc(info.tripId)
        .collection('info')
        .doc('emergency')
        .set(info.toJson(), SetOptions(merge: true));
  }
}
