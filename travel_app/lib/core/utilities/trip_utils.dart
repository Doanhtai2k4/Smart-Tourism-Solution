import 'package:flutter/material.dart';

import '../enums/trip_type.dart';

IconData getTripTypeIcon(TripType type) {
  switch (type) {
    case TripType.business:
      return Icons.business_center_outlined;
    case TripType.relaxation:
      return Icons.spa_outlined;
    case TripType.adventure:
      return Icons.hiking_outlined;
    case TripType.cultural:
      return Icons.museum_outlined;
    case TripType.romantic:
      return Icons.favorite_outline;
    case TripType.family:
      return Icons.family_restroom_outlined;
  }
}
