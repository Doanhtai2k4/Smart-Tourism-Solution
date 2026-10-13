import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/document_model.dart';

final vaultRepositoryProvider = Provider((ref) => VaultRepository());

class VaultRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _dio = Dio();

  Stream<List<TravelDocumentModel>> watchDocuments(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('vault')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TravelDocumentModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
      }).toList();
    });
  }

  Future<String> uploadFile(String tripId, File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(
        '${ApiConstants.baseDomain}/api/v1/upload',
        data: formData,
      );

      if (response.data['status'] == 'success') {
        // Trả về URL tuyệt đối để app có thể hiển thị được ngay
        return '${ApiConstants.baseDomain}${response.data['url']}';
      } else {
        throw Exception(response.data['message'] ?? 'Upload thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi khi tải file lên server: $e');
    }
  }

  Future<void> saveDocument(TravelDocumentModel document) async {
    await _firestore
        .collection('trips')
        .doc(document.tripId)
        .collection('vault')
        .add(document.toJson());
  }

  Future<void> deleteDocument(TravelDocumentModel document) async {
    // Lưu ý: Hiện tại backend chưa viết endpoint xóa file vật lý, 
    // tạm thời chỉ xóa metadata trên Firestore.
    await _firestore
        .collection('trips')
        .doc(document.tripId)
        .collection('vault')
        .doc(document.id)
        .delete();
  }
}
