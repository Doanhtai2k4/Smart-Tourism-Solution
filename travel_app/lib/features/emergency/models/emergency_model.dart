import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'emergency_model.g.dart';

@JsonSerializable(explicitToJson: true)
class EmergencyModel extends Equatable {
  final String tripId;
  final List<EmergencyContact> localNumbers; // Cảnh sát, Cứu thương...
  final List<EmergencyContact> personalContacts; // Người thân
  final MedicalInfo? medicalInfo;
  final String? embassyInfo;

  const EmergencyModel({
    required this.tripId,
    this.localNumbers = const [],
    this.personalContacts = const [],
    this.medicalInfo,
    this.embassyInfo,
  });

  factory EmergencyModel.fromJson(Map<String, dynamic> json) => _$EmergencyModelFromJson(json);
  Map<String, dynamic> toJson() => _$EmergencyModelToJson(this);

  @override
  List<Object?> get props => [tripId, localNumbers, personalContacts, medicalInfo, embassyInfo];
}

@JsonSerializable(explicitToJson: true)
class EmergencyContact extends Equatable {
  final String name;
  final String phone;
  final String? relation;

  const EmergencyContact({required this.name, required this.phone, this.relation});

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => _$EmergencyContactFromJson(json);
  Map<String, dynamic> toJson() => _$EmergencyContactToJson(this);

  @override
  List<Object?> get props => [name, phone, relation];
}

@JsonSerializable(explicitToJson: true)
class MedicalInfo extends Equatable {
  final String? bloodType;
  final String? allergies;
  final String? chronicConditions;
  final String? notes;

  const MedicalInfo({this.bloodType, this.allergies, this.chronicConditions, this.notes});

  factory MedicalInfo.fromJson(Map<String, dynamic> json) => _$MedicalInfoFromJson(json);
  Map<String, dynamic> toJson() => _$MedicalInfoToJson(this);

  @override
  List<Object?> get props => [bloodType, allergies, chronicConditions, notes];
}
