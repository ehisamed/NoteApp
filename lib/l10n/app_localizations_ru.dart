// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get notesScreen_noNotes => 'Нет заметок';

  @override
  String get notesScreen_title => 'Мои заметки';

  @override
  String get homeScreen_welcome => 'С возвращением!';

  @override
  String get homeScreen_subtitle => 'Вот ваши последние заметки';
}
