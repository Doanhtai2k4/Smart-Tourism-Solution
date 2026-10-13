import 'package:flutter/material.dart';

import '../extensions/context_l10n.dart';

enum TripFilter { all, favorite, thisMonth, lastMonth }

extension TripFilterExtension on TripFilter {
  String label(BuildContext context) {
    switch (this) {
      case TripFilter.all:
        return context.l10n.filterAll;
      case TripFilter.favorite:
        return context.l10n.filterFavorite;
      case TripFilter.thisMonth:
        return context.l10n.thisMonth;
      case TripFilter.lastMonth:
        return context.l10n.lastMonth;
    }
  }
}
