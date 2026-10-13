import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'expense_model.g.dart';

enum ExpenseCategory {
  food,
  transport,
  accommodation,
  shopping,
  entertainment,
  other
}

@JsonSerializable()
class ExpenseModel extends Equatable {
  final String id;
  final String tripId;
  final String payerId;
  final String payerName;
  final String title;
  final double amount;
  final ExpenseCategory category;
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime date;
  final List<String> splitWith; // Danh sách ID người cùng chia sẻ khoản chi này

  const ExpenseModel({
    required this.id,
    required this.tripId,
    required this.payerId,
    required this.payerName,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.splitWith = const [],
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => _$ExpenseModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);

  static DateTime _dateTimeFromTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static Timestamp _dateTimeToTimestamp(DateTime date) => Timestamp.fromDate(date);

  @override
  List<Object?> get props => [id, tripId, payerId, payerName, title, amount, category, date, splitWith];
}
