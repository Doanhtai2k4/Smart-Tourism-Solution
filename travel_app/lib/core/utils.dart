import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

ImageProvider? getAvatarProvider(String? photoUrl) {
  if (photoUrl == null || photoUrl.isEmpty) return null;
  if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
    return NetworkImage(photoUrl);
  }
  try {
    final bytes = base64Decode(photoUrl);
    return MemoryImage(bytes);
  } catch (e) {
    return null;
  }
}

Widget buildAvatarImage(
  String? photoUrl, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  WidgetBuilder? placeholder,
}) {
  if (photoUrl == null || photoUrl.isEmpty) {
    return placeholder != null
        ? Builder(builder: placeholder)
        : const Icon(Icons.person);
  }
  if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
    return Image.network(
      photoUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: placeholder != null ? (context, error, stackTrace) => placeholder(context) : null,
    );
  }
  try {
    final bytes = base64Decode(photoUrl);
    return Image.memory(
      bytes,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: placeholder != null ? (context, error, stackTrace) => placeholder(context) : null,
    );
  } catch (e) {
    return placeholder != null ? Builder(builder: placeholder) : const Icon(Icons.person);
  }
}


void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

class NumberInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll(',', '');

    if (newText.isEmpty) return newValue;

    final number = int.tryParse(newText);
    if (number == null) return oldValue;

    final newFormatted = _formatter.format(number);
    final selectionIndex = newFormatted.length;

    return TextEditingValue(
      text: newFormatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

IconData getTripTypeIcon(String tripType) {
  switch (tripType.toLowerCase()) {
    case 'business':
      return Icons.business_center;
    case 'vacation':
      return Icons.beach_access;
    case 'romantic':
      return Icons.favorite;
    case 'adventure':
      return Icons.terrain;
    case 'roadtrip':
      return Icons.route;
    case 'other':
    default:
      return Icons.travel_explore;
  }
}