// lib/features/notes/bloc/notes_bloc.dart
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_practice1/features/notes/data/repository/note_repository.dart';
import 'package:note_app_practice1/features/notes/model/note_model.dart';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NoteRepository noteRepository;

  NotesBloc(this.noteRepository) : super(NotesInitial()) {
    on<LoadNotesList>(_onLoadNotesList);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onLoadNotesList(
    LoadNotesList event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading());
    try {
      final notes = await noteRepository.getAllNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError('Ошибка при загрузке заметок: $e'));
    }
  }

  Future<void> _onAddNote(
    AddNote event,
    Emitter<NotesState> emit,
  ) async {
    log('▶ Добавление заметки: ${event.note.title}');
    try {
      await noteRepository.insertNote(event.note);
      add(LoadNotesList()); // Обновить список
    } catch (e) {
      emit(NotesError('Ошибка при добавлении заметки: $e'));
    }
  }

  Future<void> _onUpdateNote(
    UpdateNote event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await noteRepository.updateNote(event.note);
      add(LoadNotesList());
    } catch (e) {
      emit(NotesError('Ошибка при обновлении заметки: $e'));
    }
  }

  Future<void> _onDeleteNote(
    DeleteNote event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await noteRepository.deleteNote(event.noteId);
      add(LoadNotesList());
    } catch (e) {
      emit(NotesError('Ошибка при удалении заметки: $e'));
    }
  }
}
