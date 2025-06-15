import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:note_app_practice1/config/database/database_provider.dart';
import 'package:note_app_practice1/features/notes/bloc/notes_bloc.dart';
import 'package:note_app_practice1/features/notes/data/repository/note_repository.dart';

class NotesBlocProvider extends StatelessWidget {
  final Widget child;

  const NotesBlocProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseProvider.database,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final db = snapshot.data!;
          final repository = NoteRepository(db);

          return BlocProvider(
            create: (_) => NotesBloc(repository)..add(LoadNotesList()),
            child: child,
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
