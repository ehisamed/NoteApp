// lib/features/notes/repository/note_repository.dart

import 'package:note_app_practice1/features/notes/model/note_model.dart';
import 'package:sqflite/sqflite.dart';

class NoteRepository {
  final Database db;

  NoteRepository(this.db);

  Future<List<NoteModel>> getAllNotes() async {
    final result = await db.query('notes', orderBy: 'updated_at DESC');
    return result.map((e) => NoteModel.fromMap(e)).toList();
  }

  Future<void> insertNote(NoteModel note) async {
    await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateNote(NoteModel note) async {
    if (note.id == null) {
      throw ArgumentError('Cannot update note without ID');
    }

    await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteNote(int id) async {
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
