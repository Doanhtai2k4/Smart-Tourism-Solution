import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/emergency_model.dart';
import '../repository/emergency_repository.dart';

final tripEmergencyProvider = StreamProvider.family<EmergencyModel?, String>((ref, tripId) {
  return ref.watch(emergencyRepositoryProvider).watchEmergencyInfo(tripId);
});

final emergencyActionsProvider = Provider((ref) => EmergencyActions(ref));

class EmergencyActions {
  final Ref _ref;
  EmergencyActions(this._ref);

  Future<void> updateInfo(EmergencyModel info) async {
    await _ref.read(emergencyRepositoryProvider).updateEmergencyInfo(info);
  }

  Future<void> setInitialLocalNumbers(String tripId) async {
    // Demo: Giả định các số mặc định nếu chưa có
    final initialInfo = EmergencyModel(
      tripId: tripId,
      localNumbers: const [
        EmergencyContact(name: "Cảnh sát", phone: "113"),
        EmergencyContact(name: "Cứu thương", phone: "115"),
        EmergencyContact(name: "PCCC", phone: "114"),
      ],
    );
    await updateInfo(initialInfo);
  }
}
