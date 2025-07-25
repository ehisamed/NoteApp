import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_practice1/features/notes/bloc/notes_bloc.dart';
import 'package:note_app_practice1/features/notes/components/note_card.dart';
import 'package:note_app_practice1/features/notes/view/note_screen.dart';
import 'package:note_app_practice1/l10n/app_localizations.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    context.read<NotesBloc>().add(LoadNotesList());

    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state is NotesInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotesLoaded) {
            final notes = state.notes;

            if (notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.notesScreen_noNotes,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      AppLocalizations.of(context)!.notesScreen_noNotes,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<NotesBloc>(),
                          child: NoteScreen(
                            contentJson: note.content,
                            title: note.title,
                            noteId: note.id,
                            createdAt: note.createdAt,
                          ),
                        ),
                      ),
                    );
                  },
                  child: NoteCard(
                    note: note,
                    onDelete: () {
                      final id = note.id;
                      if (id != null) {
                        context.read<NotesBloc>().add(DeleteNote(id));
                      }
                    },
                  ),
                );
              },
            );
          } else if (state is NotesError) {
            return Center(child: Text('Ошибка: ${state.message}'));
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 20.0, bottom: 20.0),
        child: AnimatedScale(
          scale: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<NotesBloc>(),
                    child: NoteScreen(contentJson: '', title: ''),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.primary,
              ),
              foregroundColor: WidgetStateProperty.all(Colors.white),
              shape: WidgetStateProperty.all<OutlinedBorder>(CircleBorder()),
              iconSize: WidgetStateProperty.all(36.0),
            ),
          ),
        ),
      ),
    );
  }
}
