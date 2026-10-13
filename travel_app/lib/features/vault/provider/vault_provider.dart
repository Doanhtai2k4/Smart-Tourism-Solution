import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/document_model.dart';
import '../repository/vault_repository.dart';

final tripDocumentsProvider = StreamProvider.family<List<TravelDocumentModel>, String>((ref, tripId) {
  return ref.watch(vaultRepositoryProvider).watchDocuments(tripId);
});

final vaultActionsProvider = Provider((ref) => VaultActions(ref));

class VaultActions {
  final Ref _ref;
  VaultActions(this._ref);

  Future<void> uploadAndSaveDocument({
    required String tripId,
    required String title,
    required DocumentType type,
    required File file,
  }) async {
    final repository = _ref.read(vaultRepositoryProvider);
    
    // 1. Upload file
    final fileUrl = await repository.uploadFile(tripId, file);
    
    // 2. Save metadata
    final document = TravelDocumentModel(
      id: const Uuid().v4(),
      tripId: tripId,
      title: title,
      fileUrl: fileUrl,
      fileName: file.path.split('/').last,
      type: type,
      uploadedAt: DateTime.now(),
    );
    
    await repository.saveDocument(document);
  }

  Future<void> deleteDocument(TravelDocumentModel document) async {
    await _ref.read(vaultRepositoryProvider).deleteDocument(document);
  }
}
