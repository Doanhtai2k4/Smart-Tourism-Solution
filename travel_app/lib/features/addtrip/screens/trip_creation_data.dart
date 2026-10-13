import 'package:flutter/material.dart';

import '../../../core/enums/budget_type.dart';
import '../../../core/enums/currency.dart';
import '../../../core/enums/trip_type.dart';

class TripCreationData {
  final currentLocation = TextEditingController();
  final destination = TextEditingController();
  final startDateText = TextEditingController();
  final endDateText = TextEditingController();
  final budget = TextEditingController();
  final specialRequirements = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  TripType? tripType;
  Currency currency = Currency.usd;
  BudgetType budgetType = BudgetType.total;

  List<String> interests = [];
  String companion = '';
  String accommodation = '';
  String transport = '';
  String pace = '';
  String food = '';
  
  List<String> mustVisitPlaceIds = [];

  void dispose() {
    currentLocation.dispose();
    destination.dispose();
    startDateText.dispose();
    endDateText.dispose();
    budget.dispose();
    specialRequirements.dispose();
  }
}
