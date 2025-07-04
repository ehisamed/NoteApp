// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:note_app_practice1/config/database/database_provider.dart';
import 'package:note_app_practice1/features/categories/bloc/categories_bloc.dart';
import 'package:note_app_practice1/features/categories/data/repository/category_repository.dart';
import 'package:note_app_practice1/features/home/view/home_screen.dart';
import 'package:note_app_practice1/features/notes/bloc/notes_bloc.dart';
import 'package:note_app_practice1/features/notes/data/repository/note_repository.dart';
import 'theme/theme.dart';
import 'package:note_app_practice1/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await DatabaseProvider.database;

  final noteRepository = NoteRepository(db);
  final categoryRepository = CategoryRepository(db);

  runApp(
    MainApp(
      noteRepository: noteRepository,
      categoryRepository: categoryRepository,
    ),
  );
}

class MainApp extends StatelessWidget {
  final NoteRepository noteRepository;
  final CategoryRepository categoryRepository;

  const MainApp({
    super.key,
    required this.noteRepository,
    required this.categoryRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider<NotesBloc>(
          create: (_) => NotesBloc(noteRepository),
          // dispose не нужен, blocProvider сам закроет bloc
        ),
        BlocProvider<CategoriesBloc>(
          create: (_) => CategoriesBloc(categoryRepository),
        ),
      ],
      child: MaterialApp(
        theme: lightMode,
        darkTheme: darkMode,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,

        localizationsDelegates: const [
          quill.FlutterQuillLocalizations.delegate,
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ru')],
      ),
    );
  }
}
