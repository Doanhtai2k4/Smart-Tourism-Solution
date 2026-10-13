// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageModel _$ChatMessageModelFromJson(Map<String, dynamic> json) =>
    ChatMessageModel(
      id: json['id'] as String,
      text: json['text'] as String,
      sender: $enumDecode(_$MessageSenderEnumMap, json['sender']),
      timestamp: _dateTimeFromTimestamp(json['timestamp']),
    );

Map<String, dynamic> _$ChatMessageModelToJson(ChatMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'sender': _$MessageSenderEnumMap[instance.sender]!,
      'timestamp': _dateTimeToTimestamp(instance.timestamp),
    };

const _$MessageSenderEnumMap = {
  MessageSender.user: 'user',
  MessageSender.ai: 'ai',
};
