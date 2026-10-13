import 'package:flutter/material.dart';

import '../enums/trip_step.dart';
import '../extensions/context_l10n.dart';

class TripStepTitles {
  static String title(BuildContext context, TripStep step) {
    switch (step) {
      case TripStep.destination:
        return context.l10n.destination;
      case TripStep.dateBudget:
        return context.l10n.datesAndBudget;
      case TripStep.preferences:
        return context.l10n.preferences;
      case TripStep.travelDetails:
        return context.l10n.travelDetails;
      case TripStep.review:
        return context.l10n.tripOverview;
    }
  }
}
