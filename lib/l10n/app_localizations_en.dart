// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get notesScreen_noNotes => 'No notes';

  @override
  String get notesScreen_title => 'My Notes';

  @override
  String get homeScreen_welcome => 'Welcome back!';

  @override
  String get homeScreen_subtitle => 'Here are your latest notes';
}
