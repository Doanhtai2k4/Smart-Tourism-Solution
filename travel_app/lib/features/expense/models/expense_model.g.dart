// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) => ExpenseModel(
  id: json['id'] as String,
  tripId: json['tripId'] as String,
  payerId: json['payerId'] as String,
  payerName: json['payerName'] as String,
  title: json['title'] as String,
  amount: (json['amount'] as num).toDouble(),
  category: $enumDecode(_$ExpenseCategoryEnumMap, json['category']),
  date: ExpenseModel._dateTimeFromTimestamp(json['date']),
  splitWith:
      (json['splitWith'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$ExpenseModelToJson(ExpenseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'payerId': instance.payerId,
      'payerName': instance.payerName,
      'title': instance.title,
      'amount': instance.amount,
      'category': _$ExpenseCategoryEnumMap[instance.category]!,
      'date': ExpenseModel._dateTimeToTimestamp(instance.date),
      'splitWith': instance.splitWith,
    };

const _$ExpenseCategoryEnumMap = {
  ExpenseCategory.food: 'food',
  ExpenseCategory.transport: 'transport',
  ExpenseCategory.accommodation: 'accommodation',
  ExpenseCategory.shopping: 'shopping',
  ExpenseCategory.entertainment: 'entertainment',
  ExpenseCategory.other: 'other',
};
