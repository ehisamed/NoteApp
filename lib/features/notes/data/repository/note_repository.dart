// lib/features/notes/repository/note_repository.dart

import 'package:sqflite/sqflite.dart';
import 'package:note_app_practice1/features/notes/model/note_model.dart';

class NoteRepository {
  final Database db;

  NoteRepository(this.db);

  Future<List<NoteModel>> getAllNotes() async {
    final result = await db.query('notes', orderBy: 'updated_at DESC');
    return result.map((e) => NoteModel.fromMap(e)).toList();
  }

  Future<NoteModel?> getNoteById(int id) async {
    final result = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return NoteModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> insertNote(NoteModel note) async {
    // При вставке убираем id, чтобы SQLite сгенерировал его сам
    final data = note.toMap();
    data.remove('id');
    return await db.insert(
      'notes',
      data,
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
