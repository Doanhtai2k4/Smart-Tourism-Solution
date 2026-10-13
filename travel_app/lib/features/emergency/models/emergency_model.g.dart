// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmergencyModel _$EmergencyModelFromJson(Map<String, dynamic> json) =>
    EmergencyModel(
      tripId: json['tripId'] as String,
      localNumbers:
          (json['localNumbers'] as List<dynamic>?)
              ?.map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      personalContacts:
          (json['personalContacts'] as List<dynamic>?)
              ?.map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      medicalInfo: json['medicalInfo'] == null
          ? null
          : MedicalInfo.fromJson(json['medicalInfo'] as Map<String, dynamic>),
      embassyInfo: json['embassyInfo'] as String?,
    );

Map<String, dynamic> _$EmergencyModelToJson(
  EmergencyModel instance,
) => <String, dynamic>{
  'tripId': instance.tripId,
  'localNumbers': instance.localNumbers.map((e) => e.toJson()).toList(),
  'personalContacts': instance.personalContacts.map((e) => e.toJson()).toList(),
  'medicalInfo': instance.medicalInfo?.toJson(),
  'embassyInfo': instance.embassyInfo,
};

EmergencyContact _$EmergencyContactFromJson(Map<String, dynamic> json) =>
    EmergencyContact(
      name: json['name'] as String,
      phone: json['phone'] as String,
      relation: json['relation'] as String?,
    );

Map<String, dynamic> _$EmergencyContactToJson(EmergencyContact instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'relation': instance.relation,
    };

MedicalInfo _$MedicalInfoFromJson(Map<String, dynamic> json) => MedicalInfo(
  bloodType: json['bloodType'] as String?,
  allergies: json['allergies'] as String?,
  chronicConditions: json['chronicConditions'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$MedicalInfoToJson(MedicalInfo instance) =>
    <String, dynamic>{
      'bloodType': instance.bloodType,
      'allergies': instance.allergies,
      'chronicConditions': instance.chronicConditions,
      'notes': instance.notes,
    };
