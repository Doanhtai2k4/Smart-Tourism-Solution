import 'package:flutter/material.dart';

import '../common/app_snackbar.dart';


extension ContextSnackBar on BuildContext {
  void showSuccessSnack(String message) {
    AppSnackBar.show(this, message: message, type: SnackType.success);
  }

  void showErrorSnack(String message) {
    AppSnackBar.show(this, message: message, type: SnackType.error);
  }

  void showInfoSnack(String message) {
    AppSnackBar.show(this, message: message, type: SnackType.info);
  }
}
