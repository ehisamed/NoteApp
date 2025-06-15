// lib/features/notes/bloc/notes_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_practice1/features/notes/data/repository/note_repository.dart';
import 'package:note_app_practice1/features/notes/model/note_model.dart';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc(this.noteRepository) : super(NotesInitial()) {
    on<LoadNotesList>(_onLoadNotesList);
  }

  final NoteRepository noteRepository;

  Future<void> _onLoadNotesList(
    LoadNotesList event,
    Emitter<NotesState> emit,
  ) async {
    // print('Loading notes...');
    try {
      final notes = await noteRepository.getAllNotes();
      // print('Loaded ${notes.length} notes');
      emit(NotesLoaded(notes));
    } catch (e) {
      // print('Error loading notes: $e');
      emit(NotesError('Ошибка при загрузке заметок: $e'));
    }
  }
}
