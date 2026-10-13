import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_model.g.dart';

enum DocumentType {
  ticket,
  passport,
  hotel,
  visa,
  insurance,
  other
}

@JsonSerializable()
class TravelDocumentModel extends Equatable {
  final String id;
  final String tripId;
  final String title;
  final String fileUrl;
  final String fileName;
  final DocumentType type;
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime uploadedAt;

  const TravelDocumentModel({
    required this.id,
    required this.tripId,
    required this.title,
    required this.fileUrl,
    required this.fileName,
    required this.type,
    required this.uploadedAt,
  });

  factory TravelDocumentModel.fromJson(Map<String, dynamic> json) => _$TravelDocumentModelFromJson(json);
  Map<String, dynamic> toJson() => _$TravelDocumentModelToJson(this);

  static DateTime _dateTimeFromTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static Timestamp _dateTimeToTimestamp(DateTime date) => Timestamp.fromDate(date);

  @override
  List<Object?> get props => [id, tripId, title, fileUrl, fileName, type, uploadedAt];
}
