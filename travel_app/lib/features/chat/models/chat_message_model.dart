import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_message_model.g.dart';

enum MessageSender { user, ai }

@JsonSerializable(explicitToJson: true)
class ChatMessageModel extends Equatable {
  final String id;
  final String text;
  final MessageSender sender;
  
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime timestamp;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);

  @override
  List<Object?> get props => [id, text, sender, timestamp];
}

DateTime _dateTimeFromTimestamp(dynamic timestamp) {
  try {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) {
      final parsed = DateTime.tryParse(timestamp);
      return parsed ?? DateTime.now();
    }
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
  } catch (e) {
    print('Lỗi parse timestamp: $e, timestamp: $timestamp');
  }
  return DateTime.now();
}

Timestamp _dateTimeToTimestamp(DateTime date) => Timestamp.fromDate(date);
