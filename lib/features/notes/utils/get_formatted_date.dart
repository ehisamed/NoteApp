import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String getFormattedDate(BuildContext context) {
  final now = DateTime.now();
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMMd(locale).format(now);
}
