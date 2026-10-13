import 'package:flutter/material.dart';

import '../../features/addtrip/screens/trip_creation_data.dart';
import '../enums/trip_step.dart';
import '../extensions/context_l10n.dart';

class TripStepValidator {
  static bool isValid({
    required TripStep step,
    required TripCreationData data,
  }) {
    switch (step) {
      case TripStep.destination:
        return data.destination.text.isNotEmpty && data.tripType != null;

      case TripStep.dateBudget:
        return data.startDate != null &&
            data.endDate != null &&
            data.budget.text.isNotEmpty;

      case TripStep.preferences:
        return data.interests.isNotEmpty && data.companion.isNotEmpty;

      case TripStep.travelDetails:
        return data.accommodation.isNotEmpty &&
            data.transport.isNotEmpty &&
            data.pace.isNotEmpty &&
            data.food.isNotEmpty;
      case TripStep.review:
        return true;
    }
  }

  static String validationMessage({
    required BuildContext context,
    required TripStep step,
    required TripCreationData data,
  }) {
    switch (step) {
      case TripStep.destination:
        if (data.destination.text.isEmpty) {
          return context.l10n.validationEnterDestination;
        }
        if (data.tripType == null) {
          return context.l10n.validationSelectTripType;
        }
        return '';

      case TripStep.dateBudget:
        if (data.startDate == null) {
          return context.l10n.validationSelectStartDate;
        }
        if (data.endDate == null) {
          return context.l10n.validationSelectEndDate;
        }
        if (data.budget.text.isEmpty) {
          return context.l10n.validationEnterBudget;
        }
        return '';

      case TripStep.preferences:
        if (data.interests.isEmpty) {
          return context.l10n.validationSelectInterest;
        }
        if (data.companion.isEmpty) {
          return context.l10n.validationSelectCompanion;
        }
        return '';

      case TripStep.travelDetails:
        if (data.accommodation.isEmpty) {
          return context.l10n.validationSelectAccommodation;
        }
        if (data.transport.isEmpty) {
          return context.l10n.validationSelectTransport;
        }
        if (data.pace.isEmpty) {
          return context.l10n.validationSelectPace;
        }
        if (data.food.isEmpty) {
          return context.l10n.validationSelectFood;
        }
        return '';
      case TripStep.review:
        return '';
    }
  }
}
