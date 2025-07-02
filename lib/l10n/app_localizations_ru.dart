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
  String get noteScreen_title => 'Заголовок';

  @override
  String get noteScreen_addToCategory => 'Добавить в категорию';

  @override
  String get noteScreen_startTyping => 'Начните ввод';

  @override
  String get noteScreen_reminder => 'Напоминание';

  @override
  String get noteScreen_save => 'Сохранить';
}
