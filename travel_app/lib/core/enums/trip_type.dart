import 'package:flutter/material.dart';

import '../extensions/context_l10n.dart';

enum TripType {
  adventure,
  relaxation,
  cultural,
  business,
  romantic,
  family;

  static TripType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'adventure':
        return TripType.adventure;
      case 'relaxation':
      case 'leisure':
        return TripType.relaxation;
      case 'cultural':
        return TripType.cultural;
      case 'business':
        return TripType.business;
      case 'romantic':
        return TripType.romantic;
      case 'family':
        return TripType.family;
      default:
        return TripType.adventure;
    }
  }

  String label(BuildContext context) {
    switch (this) {
      case TripType.adventure:
        return context.l10n.tripTypeAdventure;
      case TripType.relaxation:
        return context.l10n.tripTypeRelaxation;
      case TripType.cultural:
        return context.l10n.tripTypeCultural;
      case TripType.business:
        return context.l10n.tripTypeBusiness;
      case TripType.romantic:
        return context.l10n.tripTypeRomantic;
      case TripType.family:
        return context.l10n.tripTypeFamily;
    }
  }
}
