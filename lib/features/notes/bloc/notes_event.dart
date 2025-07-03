// lib/features/notes/bloc/notes_event.dart
part of 'notes_bloc.dart';

class NotesEvent {}

class LoadNotesList extends NotesEvent {}

class AddNote extends NotesEvent {
  final NoteModel note;

  AddNote(this.note);
}

class UpdateNote extends NotesEvent {
  final NoteModel note;

  UpdateNote(this.note);
}

class DeleteNote extends NotesEvent {
  final int noteId;

  DeleteNote(this.noteId);
}