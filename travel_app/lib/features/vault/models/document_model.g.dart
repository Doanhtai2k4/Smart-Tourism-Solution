// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TravelDocumentModel _$TravelDocumentModelFromJson(Map<String, dynamic> json) =>
    TravelDocumentModel(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      title: json['title'] as String,
      fileUrl: json['fileUrl'] as String,
      fileName: json['fileName'] as String,
      type: $enumDecode(_$DocumentTypeEnumMap, json['type']),
      uploadedAt: TravelDocumentModel._dateTimeFromTimestamp(
        json['uploadedAt'],
      ),
    );

Map<String, dynamic> _$TravelDocumentModelToJson(
  TravelDocumentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'tripId': instance.tripId,
  'title': instance.title,
  'fileUrl': instance.fileUrl,
  'fileName': instance.fileName,
  'type': _$DocumentTypeEnumMap[instance.type]!,
  'uploadedAt': TravelDocumentModel._dateTimeToTimestamp(instance.uploadedAt),
};

const _$DocumentTypeEnumMap = {
  DocumentType.ticket: 'ticket',
  DocumentType.passport: 'passport',
  DocumentType.hotel: 'hotel',
  DocumentType.visa: 'visa',
  DocumentType.insurance: 'insurance',
  DocumentType.other: 'other',
};
